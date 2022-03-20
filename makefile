#Generic Library makefile for a shared library and driver.
#Assumes that driver will dynamically load library.


#### Often changed section ####

LIB_SRC_DYNAM = $(shell find ./src/ -type d ! \( -name test -o -name src -o -name driver \) )
LIB_NAME  = $(shell find ./src/ -type d ! \( -name test -o -name src -o -name driver \) | sed 's/.\/src\/\///g' )

LIB_SRC = $(PWD)/$(LIB_SRC_DYNAM)
DRIVER_SRC = $(PWD)/src/driver
TEST_SRC= $(PWD)/src/test


DRIVER_FILES=$(shell ls -p $(DRIVER_SRC) | grep -v / | grep .cpp | tr '\n' ' ')
TEST_FILES=$(shell ls -p $(TEST_SRC) | grep -v / | grep .cpp | tr '\n' ' ')
LIB_FILES=$(shell ls -p $(LIB_SRC) | grep -v / | grep .cpp | tr '\n' ' ')



#### Project Changed ####



DRIVER_CFLAGS =-g -std=c++2a -I $(PWD)/src -I $(PWD)/build/deps/include
LIB_CFLAGS =-g -fPIC -std=c++2a -I $(PWD)/src -I $(PWD)/build/deps/include
TEST_CFLAGS=-g -std=c++2a -I $(PWD)/src -I $(PWD)/build/deps/include

DRIVER_LDFLAGS=-L$(PWD)/build/deps/lib -L$(PWD)/build/bin $(PWD)/build/deps/lib/libboost_regex.a $(PWD)/build/deps/lib/libmysl.a
LIB_LDFLAGS=-L$(PWD)/build/deps/lib $(PWD)/build/deps/lib/libmysl.a
TEST_LDFLAGS=-L$(PWD)/build/deps/lib -L$(PWD)/build/bin $(PWD)/build/deps/lib/libboost_regex.a $(PWD)/build/deps/lib/libboost_unit_test_framework.a $(PWD)/build/deps/lib/libmysl.a

UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		TEST_LDFLAGS += -Wl,-rpath='$$ORIGIN/'
	endif
	ifeq ($(UNAME_S),Darwin)

	endif



DRIVER_LIBS = 
LIB_LIBS = -lpthread

DYNAMIC_LOAD = 1

#### Rarely Changed ###


BUILDDIR = $(PWD)/build
OUTDIR = $(BUILDDIR)/bin
TEMPDIR = $(BUILDDIR)/tmp

DRIVER_TARGET = driver
LIB_TARGET = lib$(LIB_NAME).so
TEST_TARGET = testlib

#### Almost Never Changed ####
CXX = g++
MKDIR_CMD = mkdir -p
RM_CMD = rm -f

#### Never Changed (never say never:) ####
SUFFIXES += .dd .ld .lo .do .to .td




DRIVER_OBJECTS = $(patsubst %.cpp,$(TEMPDIR)/%.do,$(DRIVER_FILES))
DRIVER_DEPS    = $(patsubst %.cpp,$(TEMPDIR)/%.dd,$(DRIVER_FILES))


LIB_OBJECTS    = $(patsubst %.cpp,$(TEMPDIR)/%.lo,$(LIB_FILES))
LIB_DEPS       = $(patsubst %.cpp,$(TEMPDIR)/%.ld,$(LIB_FILES))


TEST_OBJECTS    = $(patsubst %.cpp,$(TEMPDIR)/%.to,$(TEST_FILES))
TEST_DEPS       = $(patsubst %.cpp,$(TEMPDIR)/%.td,$(TEST_FILES))



.PHONY: directories clean run

$(TEMPDIR)/%.do: $(TEMPDIR)/%.dd
	$(CXX) $(DRIVER_CFLAGS) -c $(DRIVER_SRC)/$*.cpp -o $@

$(TEMPDIR)/%.lo: $(TEMPDIR)/%.ld
	$(CXX) $(LIB_CFLAGS) -c $(LIB_SRC)/$*.cpp -o $@

$(TEMPDIR)/%.to: $(TEMPDIR)/%.td
	$(CXX) $(TEST_CFLAGS) -c $(TEST_SRC)/$*.cpp -o $@


$(TEMPDIR)/%.ld: $(LIB_SRC)/%.cpp
	$(CXX) $(LIB_CFLAGS) -M -MT $(TEMPDIR)/$*.lo $< -o $@

$(TEMPDIR)/%.dd: $(DRIVER_SRC)/%.cpp
	$(CXX) $(DRIVER_CFLAGS) -M -MT $(TEMPDIR)/$*.do $< -o $@

$(TEMPDIR)/%.td: $(TEST_SRC)/%.cpp
	$(CXX) $(TEST_CFLAGS) -M -MT $(TEMPDIR)/$*.to $< -o $@


$(OUTDIR)/$(LIB_TARGET): $(LIB_OBJECTS)
	$(CXX) -shared  $(LIB_OBJECTS) $(LIB_LDFLAGS) -o $(OUTDIR)/$(LIB_TARGET)


ifeq ($(DYNAMIC_LOAD),0)
$(OUTDIR)/$(TEST_TARGET): $(TEST_OBJECTS)
	$(CXX)  $(TEST_OBJECTS) $(LIB_OBJECTS) $(TEST_LDFLAGS) -o $(OUTDIR)/$(TEST_TARGET)
endif
ifeq ($(DYNAMIC_LOAD),1)
$(OUTDIR)/$(TEST_TARGET): library $(TEST_OBJECTS)
	$(CXX) $(TEST_OBJECTS) -l $(LIB_NAME) $(TEST_LDFLAGS) -o $(OUTDIR)/$(TEST_TARGET) -ldl
endif

ifeq ($(DYNAMIC_LOAD),0)
$(OUTDIR)/$(DRIVER_TARGET): $(DRIVER_OBJECTS)
	$(CXX)  $(DRIVER_OBJECTS) $(LIB_OBJECTS) $(DRIVER_LDFLAGS) -o $(OUTDIR)/$(DRIVER_TARGET)
endif
ifeq ($(DYNAMIC_LOAD),1)
$(OUTDIR)/$(DRIVER_TARGET): library $(DRIVER_OBJECTS)
	$(CXX) $(DRIVER_OBJECTS) -l $(LIB_NAME) $(DRIVER_LDFLAGS) -o $(OUTDIR)/$(DRIVER_TARGET) -ldl
endif

ifneq ($(MAKECMDGOALS),clean)
-include $(DRIVER_DEPS)
-include $(LIB_DEPS)
-include $(TEST_DEPS)
endif

all: directories library driver test

test: directories $(OUTDIR)/$(TEST_TARGET)

driver: directories library $(OUTDIR)/$(DRIVER_TARGET)

library: directories  $(OUTDIR)/$(LIB_TARGET)


directories: $(OUTDIR) $(TEMPDIR)


boost:
	./build-tools/install-boost.sh

mysl:
	./build-tools/install-mysl.sh

$(OUTDIR): 
	$(MKDIR_CMD) $(OUTDIR)

$(TEMPDIR):
	$(MKDIR_CMD) $(TEMPDIR)

clean:
	$(RM_CMD) $(TEMPDIR)/* $(OUTDIR)/*

run: driver
	$(OUTDIR)/$(DRIVER_TARGET)
	@echo ""

tags:
	etags --exclude=build -f $(BUILDDIR)/TAGS -R -h ".hpp"

run-test: test
ifeq ($(strip $(unit-test)),)
	$(OUTDIR)/$(TEST_TARGET)
else
	$(OUTDIR)/$(TEST_TARGET) --run_test=$(unit-test)
endif
	@echo ""


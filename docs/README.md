# Lib

## Building
   First, run make boost and make mysl
   
## Running a specific unit test
   ./build/bin/testlib --run_test=<test_suite>/<test_name>

## Running a specific unit test with make
   make run-test unit-test="<test_suite>/<test_name>"

## Run lldb with parameters.
Use -- to seperate the command line you are running from lldb's options.
   lldb -- ./build/bin/testlib --run_test=<test_suite>/<test_name>

   gdb --args ./build/bin/testlib  --run_test=<test_suite>/<test_name>
   
## additional tips
Set an alias for make to run in parallel mode `make -j <number of threads>`

## Make Tags file
   make tags
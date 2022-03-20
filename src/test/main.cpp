
#define BOOST_TEST_MAIN
#include <boost/test/unit_test.hpp>

#include <iostream>

#include <mysl/mysl.hpp>




struct LoggerInit {
  LoggerInit() {
	  mysl::logging::setGlobalLogLevel(mysl::logging::error);
	  mysl::logging::setGlobalLogDisplaySourceLocation(false);
  }
  void setup() {
  
  }
  void teardown() {
  }
};

BOOST_TEST_GLOBAL_FIXTURE(LoggerInit);


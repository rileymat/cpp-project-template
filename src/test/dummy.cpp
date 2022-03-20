#include <boost/test/unit_test.hpp>
#include <iostream>
#include <mysl/mysl.hpp>


const std::string startRed = "\033[1;31m";
const std::string endRed = "\033[0m";

int add(int a, int b);
BOOST_AUTO_TEST_CASE(test_dummy_fail) {
	BOOST_CHECK_EQUAL(5, add(2, 3));
	BOOST_CHECK_NE(4, add(2, 3));
	std::cout << startRed <<"PLEASE DELETE THIS DUMMY TEST IN `src/test/dummy.cpp` THAT SHOWED THE COMPILE WORKED" << endRed <<std::endl;
	std::cout << startRed <<"ALSO delete `src/lib/dummy.cpp`" << endRed << std::endl;
}

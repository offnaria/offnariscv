// SPDX-License-Identifier: MIT

#include <print>

#include <catch2/catch_test_macros.hpp>

TEST_CASE("hello_world") {
    std::print("Hello, World!\n");
    REQUIRE(1 == 1);
    REQUIRE(1 == 0);
}

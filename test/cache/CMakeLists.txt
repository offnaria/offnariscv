# SPDX-License-Identifier: MIT

add_executable(cache_test cache_test.cpp)
target_include_directories(cache_test PRIVATE ${CMAKE_SOURCE_DIR}/test)
verilate(cache_test
  SOURCES
    ../../src/cache/cache_pkg.sv
    ../../src/cache/cache_if.sv
    ../../src/cache/cache_directory.sv
    cache_wrap.sv
  TOP_MODULE
    cache_wrap
  PREFIX
    Vcache)
target_link_libraries(cache_test PRIVATE Catch2::Catch2WithMain)
catch_discover_tests(cache_test)

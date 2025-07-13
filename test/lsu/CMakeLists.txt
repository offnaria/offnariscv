# SPDX-License-Identifier: MIT

add_executable(lsu_test lsu_test.cpp)
target_include_directories(lsu_test PRIVATE ${CMAKE_SOURCE_DIR}/test)
verilate(lsu_test
  SOURCES
    ../../src/riscv_pkg.sv
    ../../src/offnariscv_pkg.sv
    ../../src/cache/cache_pkg.sv
    ../../src/ace_if.sv
    ../../src/common/axis_if.sv
    ../../src/common/axis_slice.sv
    ../../src/cache/cache_if.sv
    ../../src/cache/cache_directory.sv
    ../../src/lsu/lsu.sv
    lsu_wrap.sv
  TOP_MODULE
    lsu_wrap
  PREFIX
    Vlsu)
target_link_libraries(lsu_test PRIVATE Catch2::Catch2WithMain)
catch_discover_tests(lsu_test)

# SPDX-License-Identifier: MIT

add_executable(pcgen_test pcgen_test.cpp)
target_include_directories(pcgen_test PRIVATE ${CMAKE_SOURCE_DIR}/test)
verilate(pcgen_test
  SOURCES
    ../../src/offnariscv_pkg.sv
    ../../src/common/axis_if.sv
    ../../src/pcgen/pcgen.sv
    pcgen_wrap.sv
  TOP_MODULE
    pcgen_wrap
  PREFIX
    Vpcgen)
target_link_libraries(pcgen_test PRIVATE Catch2::Catch2WithMain)
catch_discover_tests(pcgen_test)

# SPDX-License-Identifier: MIT

add_executable(ifu_test ifu_test.cpp)
target_include_directories(ifu_test PRIVATE ${CMAKE_SOURCE_DIR}/test)
verilate(ifu_test
  SOURCES
    ../../src/riscv_pkg.sv
    ../../src/offnariscv_pkg.sv
    ../../src/cache/cache_pkg.sv
    ../../src/ace_if.sv
    ../../src/common/axis_if.sv
    ../../src/cache/cache_if.sv
    ../../src/cache/cache_directory.sv
    ../../src/common/axis_skid_buffer.sv
    ../../src/ifu/ifu.sv
    ifu_wrap.sv
  TOP_MODULE
    ifu_wrap
  PREFIX
    Vifu
  TRACE_FST TRACE_THREADS)
target_link_libraries(ifu_test PRIVATE Catch2::Catch2WithMain)
catch_discover_tests(ifu_test)

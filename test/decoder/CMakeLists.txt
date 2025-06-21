# SPDX-License-Identifier: MIT

add_executable(decoder_test decoder_test.cpp)
target_include_directories(decoder_test PRIVATE ${CMAKE_SOURCE_DIR}/test)
verilate(decoder_test
  SOURCES
    ../../src/riscv_pkg.sv
    ../../src/offnariscv_pkg.sv
    ../../src/common/axis_if.sv
    ../../src/decoder/decoder.sv
    decoder_wrap.sv
  TOP_MODULE
    decoder_wrap
  PREFIX
    Vdecoder
  TRACE_FST TRACE_THREADS)
target_link_libraries(decoder_test PRIVATE Catch2::Catch2WithMain)
catch_discover_tests(decoder_test)

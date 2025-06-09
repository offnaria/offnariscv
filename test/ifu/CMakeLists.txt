# SPDX-License-Identifier: MIT

add_executable(ifu_test ifu_test.cpp)
verilate(ifu_test
  SOURCES
    ../../src/riscv_pkg.sv
    ../../src/offnariscv_pkg.sv
    ../../src/ace_if.sv
    ../../src/common/axis_if.sv
    ../../src/common/axis_skid_buffer.sv
    ../../src/ifu/ifu.sv
    ifu_wrap.sv
  TOP_MODULE
    ifu_wrap)

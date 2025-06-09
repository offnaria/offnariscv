# SPDX-License-Identifier: MIT

add_executable(lsu_test lsu_test.cpp)
verilate(lsu_test
  SOURCES
    ../../src/riscv_pkg.sv
    ../../src/offnariscv_pkg.sv
    ../../src/ace_if.sv
    ../../src/lsu/lsu.sv
    lsu_wrap.sv
  TOP_MODULE
    lsu_wrap)

# SPDX-License-Identifier: MIT

add_executable(lsu_test lsu_test.cpp)
verilate(lsu_test SOURCES lsu_wrap.sv
  ../../src/offnariscv_pkg.sv
  ../../src/ace_if.sv
  ../../src/lsu/lsu.sv)

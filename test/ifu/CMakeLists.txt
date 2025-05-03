# SPDX-License-Identifier: MIT

add_executable(ifu_test ifu_test.cpp)
verilate(ifu_test SOURCES ifu_wrap.sv
  ../../src/ace_if.sv
  ../../src/ifu/ifu.sv)

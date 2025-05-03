# SPDX-License-Identifier: MIT

add_executable(main main.cpp)

find_package(verilator)
add_subdirectory(ifu)
add_subdirectory(lsu)

add_executable(offnariscv_core_test offnariscv_core_test.cpp)
verilate(offnariscv_core_test SOURCES offnariscv_core_wrap.sv
  ../src/ace_if.sv
  ../src/ifu/ifu.sv
  ../src/lsu/lsu.sv
  ../src/offnariscv_core.sv)

# SPDX-License-Identifier: MIT

add_executable(main main.cpp)

find_package(verilator)
add_subdirectory(ifu)
add_subdirectory(lsu)

add_executable(offnariscv_core_test offnariscv_core_test.cpp)
verilate(offnariscv_core_test
  SOURCES
    ../src/offnariscv_pkg.sv
    ../src/ace_if.sv
    ../src/ifu/ifu.sv
    ../src/lsu/lsu.sv
    ../src/offnariscv_core.sv
    offnariscv_core_wrap.sv
  TOP_MODULE
    offnariscv_core_wrap)
target_link_libraries(offnariscv_core_test PRIVATE Catch2::Catch2WithMain)

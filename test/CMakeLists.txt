# SPDX-License-Identifier: MIT

include(CTest)
include(${CMAKE_SOURCE_DIR}/ext/Catch2/extras/Catch.cmake)

add_executable(main main.cpp)

find_package(verilator)
add_subdirectory(ifu)
add_subdirectory(lsu)

add_executable(offnariscv_core_test offnariscv_core_test.cpp SimSpike.cpp)
add_dependencies(offnariscv_core_test riscv-isa-sim)
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
target_include_directories(offnariscv_core_test PRIVATE
  ../ext/riscv-isa-sim/riscv-isa-sim
  ../ext/riscv-isa-sim/riscv-isa-sim/riscv
  ${CMAKE_BINARY_DIR}/ext/riscv-isa-sim/riscv-isa-sim)
target_link_libraries(offnariscv_core_test
  PRIVATE
    ${CMAKE_BINARY_DIR}/ext/riscv-isa-sim/riscv-isa-sim/libdisasm.a
    ${CMAKE_BINARY_DIR}/ext/riscv-isa-sim/riscv-isa-sim/libfdt.a
    ${CMAKE_BINARY_DIR}/ext/riscv-isa-sim/riscv-isa-sim/libfesvr.a
    ${CMAKE_BINARY_DIR}/ext/riscv-isa-sim/riscv-isa-sim/libriscv.a
    ${CMAKE_BINARY_DIR}/ext/riscv-isa-sim/riscv-isa-sim/libsoftfloat.a
    ${CMAKE_BINARY_DIR}/ext/riscv-isa-sim/riscv-isa-sim/libspike_dasm.a
    ${CMAKE_BINARY_DIR}/ext/riscv-isa-sim/riscv-isa-sim/libspike_main.a)
catch_discover_tests(offnariscv_core_test)

# SPDX-License-Identifier: MIT

include(CTest)
include(${CMAKE_SOURCE_DIR}/ext/Catch2/extras/Catch.cmake)

add_executable(main main.cpp)

find_package(verilator)
add_subdirectory(cache)
add_subdirectory(common)
add_subdirectory(ifu)
add_subdirectory(lsu)
add_subdirectory(pcgen)

add_executable(offnariscv_core_test offnariscv_core_test.cpp)
target_include_directories(offnariscv_core_test PRIVATE ${CMAKE_SOURCE_DIR}/test)
verilate(offnariscv_core_test
  SOURCES
    ../src/riscv_pkg.sv
    ../src/offnariscv_pkg.sv
    ../src/cache/cache_pkg.sv
    ../src/ace_if.sv
    ../src/common/axis_if.sv
    ../src/csr/csr_if.sv
    ../src/cache/cache_if.sv
    ../src/cache/cache_directory.sv
    ../src/cache/cache_memory.sv
    ../src/common/axis_slice.sv
    ../src/common/axis_skid_buffer.sv
    ../src/common/ram_async.sv
    ../src/common/axis_sync_fifo.sv
    ../src/pcgen/pcgen.sv
    ../src/ifu/ifu.sv
    ../src/decoder/decoder.sv
    ../src/regfile/regfile.sv
    ../src/csr/csr.sv
    ../src/execute/dispatcher.sv
    ../src/execute/alu.sv
    ../src/execute/bru.sv
    ../src/execute/system.sv
    ../src/lsu/lsu.sv
    ../src/committer/committer.sv
    ../src/offnariscv_core.sv
    offnariscv_core_wrap.sv
  TOP_MODULE
    offnariscv_core_wrap
  PREFIX
    Voffnariscv_core)
target_link_libraries(offnariscv_core_test PRIVATE Catch2::Catch2WithMain)
target_link_libraries(offnariscv_core_test PRIVATE elfio)
catch_discover_tests(offnariscv_core_test)
# target_include_directories(offnariscv_core_test PRIVATE
#   ../ext/riscv-isa-sim/riscv-isa-sim
#   ../ext/riscv-isa-sim/riscv-isa-sim/riscv
#   ${CMAKE_BINARY_DIR}/ext/riscv-isa-sim/riscv-isa-sim)
# target_link_libraries(offnariscv_core_test
#   PRIVATE
#     ${CMAKE_BINARY_DIR}/ext/riscv-isa-sim/riscv-isa-sim/libdisasm.a
#     ${CMAKE_BINARY_DIR}/ext/riscv-isa-sim/riscv-isa-sim/libfdt.a
#     ${CMAKE_BINARY_DIR}/ext/riscv-isa-sim/riscv-isa-sim/libfesvr.a
#     ${CMAKE_BINARY_DIR}/ext/riscv-isa-sim/riscv-isa-sim/libriscv.a
#     ${CMAKE_BINARY_DIR}/ext/riscv-isa-sim/riscv-isa-sim/libsoftfloat.a
#     ${CMAKE_BINARY_DIR}/ext/riscv-isa-sim/riscv-isa-sim/libspike_dasm.a
#     ${CMAKE_BINARY_DIR}/ext/riscv-isa-sim/riscv-isa-sim/libspike_main.a)

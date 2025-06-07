# SPDX-License-Identifier: MIT

add_executable(axis_slice_test axis_slice_test.cpp)
target_include_directories(axis_slice_test PRIVATE ${CMAKE_SOURCE_DIR}/test)
verilate(axis_slice_test
  SOURCES
    ../../src/offnariscv_pkg.sv
    ../../src/common/axis_if.sv
    ../../src/common/axis_slice.sv
    axis_slice_wrap.sv
  TOP_MODULE
    axis_slice_wrap
  PREFIX
    Vaxis_slice)
target_link_libraries(axis_slice_test PRIVATE Catch2::Catch2WithMain)
catch_discover_tests(axis_slice_test)

add_executable(axis_skid_buffer_test axis_skid_buffer_test.cpp)
target_include_directories(axis_skid_buffer_test PRIVATE ${CMAKE_SOURCE_DIR}/test)
verilate(axis_skid_buffer_test
  SOURCES
    ../../src/offnariscv_pkg.sv
    ../../src/common/axis_if.sv
    ../../src/common/axis_skid_buffer.sv
    axis_skid_buffer_wrap.sv
  TOP_MODULE
    axis_skid_buffer_wrap
  PREFIX
    Vaxis_skid_buffer)
target_link_libraries(axis_skid_buffer_test PRIVATE Catch2::Catch2WithMain)
catch_discover_tests(axis_skid_buffer_test)

add_executable(axis_sync_fifo_test axis_sync_fifo_test.cpp)
target_include_directories(axis_sync_fifo_test PRIVATE ${CMAKE_SOURCE_DIR}/test)
verilate(axis_sync_fifo_test
  SOURCES
    ../../src/offnariscv_pkg.sv
    ../../src/common/axis_if.sv
    ../../src/common/axis_sync_fifo.sv
    ../../src/common/ram_async.sv
    axis_sync_fifo_wrap.sv
  TOP_MODULE
    axis_sync_fifo_wrap
  PREFIX
    Vaxis_sync_fifo)
target_link_libraries(axis_sync_fifo_test PRIVATE Catch2::Catch2WithMain)
catch_discover_tests(axis_sync_fifo_test)

add_executable(ram_sync_test ram_sync_test.cpp)
target_include_directories(ram_sync_test PRIVATE ${CMAKE_SOURCE_DIR}/test)
verilate(ram_sync_test
  SOURCES
    ../../src/common/ram_sync.sv
    ram_sync_wrap.sv
  TOP_MODULE
    ram_sync_wrap
  PREFIX
    Vram_sync)
target_link_libraries(ram_sync_test PRIVATE Catch2::Catch2WithMain)
catch_discover_tests(ram_sync_test)

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

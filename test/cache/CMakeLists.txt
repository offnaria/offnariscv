# SPDX-License-Identifier: MIT

add_executable(cache_si_test cache_si_test.cpp)
verilate(cache_si_test
  SOURCES
    ../../src/offnariscv_pkg.sv
    ../../src/cache/cache_if.sv
    ../../src/cache/cache_si.sv
    cache_si_wrap.sv
  TOP_MODULE
    cache_si_wrap
  PREFIX
    Vcache_si)
target_link_libraries(cache_si_test PRIVATE Catch2::Catch2WithMain)

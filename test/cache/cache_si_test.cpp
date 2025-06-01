// SPDX-License-Identifier: MIT

#include <verilated.h>

#include <catch2/catch_test_macros.hpp>
#include <catch2/generators/catch_generators.hpp>
#include <print>

#include "Dut.hpp"
#include "Vcache_si.h"

constexpr int BLOCK_SIZE = 128;  // 128 bits

static void init_dut(Dut<Vcache_si>& dut) {
  dut->rif_addr = 0;
  dut->wif_addr = 0;
  for (int i = 0; i < BLOCK_SIZE / 32; ++i) {
    dut->wif_data[i] = 0;
  }
  dut->wif_we = 0;

  dut.reset();
}

TEST_CASE("cache_si_initial_miss") {
  Dut<Vcache_si> dut;
  init_dut(dut);

  std::print("----- Read from cache\n");
  dut->rif_addr = 0x1000;
  std::print("rif_addr: {:#010x}\n", dut->rif_addr);
  dut->eval();  // Same clock cycle
  std::print("rif_hit: {}\n", dut->rif_hit);
  REQUIRE(dut->rif_hit == 0);
}

TEST_CASE("cache_si_refill_hit") {
  Dut<Vcache_si> dut;
  init_dut(dut);

  std::print("----- Write data to cache\n");
  dut->wif_addr = 0x1000;
  dut->wif_we = ~(-1 << (BLOCK_SIZE / 8));
  std::print("wif_addr: {:#010x}\n", dut->wif_addr);
  std::print("wif_we: {:#010x}\n", dut->wif_we);
  for (int i = 0; i < BLOCK_SIZE / 32; ++i) {
    dut->wif_data[i] = i + 1;
    std::print("wif_data[{}]: {:#010x}\n", i, dut->wif_data[i]);
  }
  dut.step();
  dut->wif_we = 0;

  std::print("----- Read from cache\n");
  std::print("rif_addr: {:#010x}\n", dut->rif_addr);
  dut->rif_addr = 0x1000;
  dut->eval();  // Same clock cycle
  std::print("rif_hit: {}\n", dut->rif_hit);
  REQUIRE(dut->rif_hit == 1);
  dut.step();  // Next clock cycle
  for (int i = 0; i < BLOCK_SIZE / 32; ++i) {
    std::print("rif_data[{}]: {:#010x}\n", i, dut->rif_data[i]);
    REQUIRE(dut->rif_data[i] == i + 1);
  }
}

TEST_CASE("cache_si_conflict_miss") {
  Dut<Vcache_si> dut;
  init_dut(dut);

  std::print("----- Write data to cache\n");
  dut->wif_addr = 0x1000;
  dut->wif_we = ~(-1 << (BLOCK_SIZE / 8));
  std::print("wif_addr: {:#010x}\n", dut->wif_addr);
  std::print("wif_we: {:#010x}\n", dut->wif_we);
  for (int i = 0; i < BLOCK_SIZE / 32; ++i) {
    dut->wif_data[i] = i + 1;
    std::print("wif_data[{}]: {:#010x}\n", i, dut->wif_data[i]);
  }
  dut.step();
  dut->wif_we = 0;

  std::print("----- Read from cache\n");
  dut->rif_addr = 0x1000;
  std::print("rif_addr: {:#010x}\n", dut->rif_addr);
  dut->eval();  // Same clock cycle
  std::print("rif_hit: {}\n", dut->rif_hit);
  REQUIRE(dut->rif_hit == 1);
  dut.step();  // Next clock cycle
  for (int i = 0; i < BLOCK_SIZE / 32; ++i) {
    std::print("rif_data[{}]: {:#010x}\n", i, dut->rif_data[i]);
    REQUIRE(dut->rif_data[i] == i + 1);
  }

  std::print("----- Overwrite data to the same index\n");
  dut->wif_addr = 0x10001000;
  dut->wif_we = ~(-1 << (BLOCK_SIZE / 8));
  std::print("wif_addr: {:#010x}\n", dut->wif_addr);
  std::print("wif_we: {:#010x}\n", dut->wif_we);
  for (int i = 0; i < BLOCK_SIZE / 32; ++i) {
    dut->wif_data[i] = i + 1;
    std::print("wif_data[{}]: {:#010x}\n", i, dut->wif_data[i]);
  }
  dut.step();
  dut->wif_we = 0;

  // Read from cache must miss
  dut->rif_addr = 0x1000;
  std::print("rif_addr: {:#010x}\n", dut->rif_addr);
  dut->eval();  // Same clock cycle
  std::print("rif_hit: {}\n", dut->rif_hit);
  REQUIRE(dut->rif_hit == 0);
}

TEST_CASE("cache_si_partial_refill") {
  Dut<Vcache_si> dut;
  init_dut(dut);

  std::print("----- Write partial data to cache\n");
  dut->wif_addr = 0x1000;
  dut->wif_we = 0b0000'0000'0000'1100;
  std::print("wif_addr: {:#010x}\n", dut->wif_addr);
  std::print("wif_we: {:#010x}\n", dut->wif_we);
  for (int i = 0; i < BLOCK_SIZE / 32; ++i) {
    dut->wif_data[i] = -1;
    std::print("wif_data[{}]: {:#010x}\n", i, dut->wif_data[i]);
  }
  dut.step();
  dut->wif_we = 0;

  std::print("----- Read from cache\n");
  dut->rif_addr = 0x1000;
  std::print("rif_addr: {:#010x}\n", dut->rif_addr);
  dut->eval();  // Same clock cycle
  std::print("rif_hit: {}\n", dut->rif_hit);
  REQUIRE(dut->rif_hit == 1);
  dut.step();  // Next clock cycle
  for (int i = 0; i < BLOCK_SIZE / 32; ++i) {
    if (i == 0)
      REQUIRE(dut->rif_data[i] == 0xffff0000);
    else
      REQUIRE(dut->rif_data[i] == 0);
    std::print("rif_data[{}]: {:#010x}\n", i, dut->rif_data[i]);
  }
}

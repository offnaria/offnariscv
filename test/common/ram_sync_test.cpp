// SPDX-License-Identifier: MIT

#include <verilated.h>

#include <catch2/catch_test_macros.hpp>
#include <catch2/generators/catch_generators.hpp>
#include <print>

#include "Dut.hpp"
#include "Vram_sync.h"

static void init_dut(Dut<Vram_sync>& dut) {
  dut->wdata = 0;
  dut->waddr = 0;
  dut->wvalid = 0;
  dut->wstrb = 0;
  dut->raddr = 0;
  dut->rvalid = 0;
  dut->oreg_cen = 0;

  dut.reset();
}

TEST_CASE("ram_sync_implement_me") {
  Dut<Vram_sync> dut;
  init_dut(dut);

  std::print("----- Implement me\n");
  REQUIRE(true);
}

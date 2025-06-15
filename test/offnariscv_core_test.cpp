// SPDX-License-Identifier: MIT

#include <verilated.h>

#include <catch2/catch_test_macros.hpp>
#include <catch2/generators/catch_generators.hpp>
#include <print>

#include "Dut.hpp"
#include "Voffnariscv_core.h"

static void init_dut(Dut<Voffnariscv_core>& dut) {
  dut->ifu_ace_arready = 0;
  dut->ifu_ace_rid = 0;
  for (int i = 0; i < 8; ++i) {
    // Assuming the block size is 256 bits (8 * 32 bits)
    dut->ifu_ace_rdata[i] = 0;
  }
  dut->ifu_ace_rresp = 0;
  dut->ifu_ace_rlast = 0;
  dut->ifu_ace_ruser = 0;
  dut->ifu_ace_rvalid = 0;
  dut->ifu_ace_acvalid = 0;
  dut->ifu_ace_acaddr = 0;
  dut->ifu_ace_acsnoop = 0;
  dut->ifu_ace_acprot = 0;
  dut->ifu_ace_crready = 0;
  dut->ifu_ace_cdready = 0;

  dut.reset();
}

TEST_CASE("offnariscv_core_implement_me") {
  Dut<Voffnariscv_core> dut;
  init_dut(dut);

  std::print("----- Implement me\n");
  REQUIRE(true);
}

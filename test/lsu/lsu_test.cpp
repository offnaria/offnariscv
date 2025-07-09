// SPDX-License-Identifier: MIT

#include <verilated.h>

#include <catch2/catch_test_macros.hpp>
#include <catch2/generators/catch_generators.hpp>
#include <print>

#include "Dut.hpp"
#include "Vlsu.h"

static void init_dut(Dut<Vlsu>& dut) {
  dut->lsu_ace_arready = 0;
  dut->lsu_ace_rid = 0;
  dut->lsu_ace_rresp = 0;
  dut->lsu_ace_rlast = 0;
  dut->lsu_ace_ruser = 0;
  dut->lsu_ace_rvalid = 0;
  dut->lsu_ace_acvalid = 0;
  dut->lsu_ace_acaddr = 0;
  dut->lsu_ace_acsnoop = 0;
  dut->lsu_ace_acprot = 0;
  dut->lsu_ace_crready = 0;
  dut->lsu_ace_cdready = 0;
  dut->invalidate = 0;

  dut.reset();
}

TEST_CASE("lsu_implement_me") {
  Dut<Vlsu> dut;
  init_dut(dut);

  std::print("----- Implement me\n");
  REQUIRE(true);
}

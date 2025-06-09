// SPDX-License-Identifier: MIT

#include <verilated.h>

#include <catch2/catch_test_macros.hpp>
#include <catch2/generators/catch_generators.hpp>
#include <print>

#include "Dut.hpp"
#include "Vpcgen.h"

static void init_dut(Dut<Vpcgen>& dut) {
  dut->next_pc_tready = 0;
  dut->current_pc_tdata = 0;
  dut->current_pc_tvalid = 0;
  dut->bru_tdata = 0;
  dut->bru_tvalid = 0;

  dut.reset();
}

TEST_CASE("pcgen_implement_me") {
  Dut<Vpcgen> dut;
  init_dut(dut);

  std::print("----- Implement me\n");
  REQUIRE(true);
}

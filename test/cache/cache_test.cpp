// SPDX-License-Identifier: MIT

#include <verilated.h>

#include <catch2/catch_test_macros.hpp>
#include <catch2/generators/catch_generators.hpp>
#include <print>

#include "Dut.hpp"
#include "Vcache.h"

static void init_dut(Dut<Vcache>& dut) {
  // TODO
  dut.reset();
}

TEST_CASE("cache_implement_me") {
  Dut<Vcache> dut;
  init_dut(dut);

  std::print("----- Implement me\n");
  REQUIRE(true);
}

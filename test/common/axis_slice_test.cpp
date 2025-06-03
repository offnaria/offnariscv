// SPDX-License-Identifier: MIT

#include <verilated.h>

#include <catch2/catch_test_macros.hpp>
#include <catch2/generators/catch_generators.hpp>
#include <print>

#include "Dut.hpp"
#include "Vaxis_slice.h"

static void init_dut(Dut<Vaxis_slice>& dut) {
  dut->sif_tvalid = 0;
  dut->sif_tdata = 0;
  dut->mif_tready = 0;

  dut.reset();
}

TEST_CASE("axis_slice_ready") {
  Dut<Vaxis_slice> dut;
  init_dut(dut);

  std::print("----- Wait for ready signal to be asserted\n");
  REQUIRE(dut->mif_tvalid == 0);
  for (int i = 0; i < 8; ++i) {
    // Wait for the ready signal to be asserted, since its reset value is 0
    std::print("i={}: sif_tready={}\n", i, dut->sif_tready);
    if (dut->sif_tready == 1) break;
    dut.step();
  }
  REQUIRE(dut->sif_tready == 1);
}

TEST_CASE("axis_slice_pass") {
  Dut<Vaxis_slice> dut;
  init_dut(dut);

  std::print("----- Pass data\n");
  dut->mif_tready = 1;
  int i;
  for (i = 0; i < 8; ++i) {
    dut->sif_tvalid = 1;
    dut->sif_tdata = i;
    std::print(
        "i={}: sif_tvalid={}, sif_tdata={}, mif_tvalid={}, mif_tdata={}\n", i,
        dut->sif_tvalid, dut->sif_tdata, dut->mif_tvalid, dut->mif_tdata);
    dut.step();
    REQUIRE(dut->mif_tvalid == 1);
    REQUIRE(dut->mif_tdata == i);
  }
  dut->sif_tvalid = 0;
  dut->sif_tdata = 0;
  dut.step();
  std::print("----- Finished passing data\n");
  std::print("mif_tvalid={}, mif_tdata={}\n", dut->mif_tvalid, dut->mif_tdata);
  REQUIRE(dut->mif_tvalid == 0);
  // REQUIRE(dut->mif_tdata == i - 1);  // NOTE: i = 8
}

TEST_CASE("axis_slice_hold_and_pass") {
  Dut<Vaxis_slice> dut;
  init_dut(dut);

  std::print("----- Hold data\n");
  dut->sif_tvalid = 1;
  dut->sif_tdata = 1;
  dut.step();
  std::print("mif_tvalid={}, mif_tdata={}\n", dut->mif_tvalid, dut->mif_tdata);
  REQUIRE(dut->mif_tvalid == 1);
  REQUIRE(dut->mif_tdata == 1);
  dut->sif_tvalid = 1;
  dut->sif_tdata = 2;
  dut.step();
  std::print("mif_tvalid={}, mif_tdata={}\n", dut->mif_tvalid, dut->mif_tdata);
  REQUIRE(dut->mif_tvalid == 1);  // Still holding the previous data
  REQUIRE(dut->mif_tdata == 1);

  std::print("----- Pass data\n");
  dut->mif_tready = 1;
  dut.step();
  std::print("mif_tvalid={}, mif_tdata={}\n", dut->mif_tvalid, dut->mif_tdata);
  REQUIRE(dut->mif_tvalid == 1);
  REQUIRE(dut->mif_tdata == 2);
}

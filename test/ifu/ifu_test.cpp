// SPDX-License-Identifier: MIT

#include <verilated.h>
#include <verilated_fst_c.h>

#include <catch2/catch_test_macros.hpp>
#include <catch2/generators/catch_generators.hpp>
#include <print>

#include "Dut.hpp"
#include "Vifu.h"

static void init_dut(Dut<Vifu>& dut) {
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
  dut->next_pc_tdata = 0;
  dut->next_pc_tvalid = 0;
  dut->current_pc_tready = 0;
  dut->inst_tready = 0;
  dut->invalidate = 0;

  dut.reset();
}

TEST_CASE("ifu_load") {
  Dut<Vifu> dut;
  Verilated::traceEverOn(true);
  VerilatedFstC* tfp = new VerilatedFstC;
  dut->trace(tfp, 100);
  tfp->open("simx.fst");
  init_dut(dut);

  std::print("----- First step\n");
  for (int i = 0; i < 10; ++i) {
    std::print("next_pc_tready={}\n", dut->next_pc_tready);
    if (dut->next_pc_tready == 1) break;
    dut.step();
  }
  REQUIRE(dut->next_pc_tready == 1);
  dut->next_pc_tvalid = 1;
  dut->next_pc_tdata = 0;
  dut.step();

  std::print("----- Wait for the first instruction load\n");
  for (int i = 0; i < 10; ++i) {
    std::print("arvalid={}, araddr=0x{:08x}, rready={}\n", dut->ifu_ace_arvalid,
               dut->ifu_ace_araddr, dut->ifu_ace_rready);
    if (dut->ifu_ace_arvalid == 1) break;
    dut.step();
  }
  REQUIRE(dut->ifu_ace_arvalid == 1);
  REQUIRE(dut->ifu_ace_araddr ==
          0x00000000);  // Assuming the reset vector is 0x00000000
  REQUIRE(dut->inst_tvalid == 0);

  std::print("----- Respond on AR channel\n");
  dut->ifu_ace_arready = 1;
  dut.step();
  std::print("arvalid={}, rready={}\n", dut->ifu_ace_arvalid,
             dut->ifu_ace_rready);
  REQUIRE(dut->ifu_ace_arvalid == 0);
  REQUIRE(dut->ifu_ace_rready == 1);
  REQUIRE(dut->inst_tvalid == 0);

  std::print("----- Respond on R channel\n");
  dut->ifu_ace_arready = 0;
  dut->ifu_ace_rdata[0] = 0x12345678;
  dut->ifu_ace_rdata[1] = 0x9abcdef0;
  dut->ifu_ace_rdata[2] = 0x11223344;
  dut->ifu_ace_rdata[3] = 0x55667788;
  dut->ifu_ace_rdata[4] = 0x99aabbcc;
  dut->ifu_ace_rdata[5] = 0xddeeff00;
  dut->ifu_ace_rdata[6] = 0xdeadbeef;
  dut->ifu_ace_rdata[7] = 0xfeedface;
  dut->ifu_ace_rresp = 0;  // OKAY
  dut->ifu_ace_rvalid = 1;
  dut.step();
  std::print("arvalid={}, rready={}\n", dut->ifu_ace_arvalid,
             dut->ifu_ace_rready);
  REQUIRE(dut->ifu_ace_arvalid == 0);
  REQUIRE(dut->ifu_ace_rready == 0);
  std::print("inst_tvalid={}, inst_tdata=0x{:08x}\n", dut->inst_tvalid,
             dut->ifid_tdata_inst);
  REQUIRE(dut->inst_tvalid == 1);
  REQUIRE(dut->ifid_tdata_inst == 0x12345678);
}

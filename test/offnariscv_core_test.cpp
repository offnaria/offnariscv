// SPDX-License-Identifier: MIT

#include <verilated.h>

#include <catch2/catch_test_macros.hpp>
#include <catch2/generators/catch_generators.hpp>
#include <cstdint>
#include <elfio/elfio.hpp>
#include <filesystem>
#include <fstream>
#include <print>
#include <string>
#include <unordered_map>
#include <vector>

#include "Dut.hpp"
#include "Voffnariscv_core.h"

constexpr int PAGE_SIZE = 4096;
constexpr int PAGE_OFFSET_MASK = PAGE_SIZE - 1;
constexpr int PAGE_NUMBER_MASK = ~PAGE_OFFSET_MASK;

constexpr int BLOCK_BYTES = 32;  // Assuming each block is 32 bytes (256 bits)
constexpr int BLOCK_MASK = ~(BLOCK_BYTES - 1);

class Tester {
  Dut<Voffnariscv_core> dut;
  std::unordered_map<std::uint32_t, std::vector<std::uint8_t>> memory;
  bool kanata_log_enabled;
  std::ofstream kanata_log;
  std::uint32_t tohost_addr;

  void init_dut();

 public:
  Tester(const std::string& test);
  void step();
  bool tohost_written;
  std::uint32_t tohost_data;
};

void Tester::init_dut() {
  dut->core_ace_arready = 0;
  dut->core_ace_rid = 0;
  for (int i = 0; i < 8; ++i) {
    // Assuming the block size is 256 bits (8 * 32 bits)
    dut->core_ace_rdata[i] = 0;
  }
  dut->core_ace_rresp = 0;
  dut->core_ace_rlast = 0;
  dut->core_ace_ruser = 0;
  dut->core_ace_rvalid = 0;
  dut->core_ace_acvalid = 0;
  dut->core_ace_acaddr = 0;
  dut->core_ace_acsnoop = 0;
  dut->core_ace_acprot = 0;
  dut->core_ace_crready = 0;
  dut->core_ace_cdready = 0;

  dut.reset();
}

Tester::Tester(const std::string& test) {
  auto my_parent_path = std::filesystem::read_symlink("/proc/self/exe").parent_path();
  auto test_path = my_parent_path / "../ext/riscv-tests/riscv-tests/isa" / test;
  auto test_path_str = test_path.string();
  std::print("Test path: {}\n", test_path_str);
  REQUIRE(std::filesystem::exists(test_path));

  ELFIO::elfio reader;
  REQUIRE(reader.load(test_path_str));

  REQUIRE(reader.get_class() == ELFIO::ELFCLASS32);
  REQUIRE(reader.get_machine() == ELFIO::EM_RISCV);

  uint32_t text_init;
  for (const auto& section : reader.sections) {
    if ((section->get_flags() & ELFIO::SHF_ALLOC) != ELFIO::SHF_ALLOC) continue;
    auto addr = section->get_address();
    auto size = section->get_size();
    if (size == 0) continue;  // Skip empty sections
    if (section->get_name().find(".text.init") != std::string::npos) {
      text_init = addr;
      std::print("Found .text.init section at address: {:#010x}\n", addr);
    } else if (section->get_name().find(".tohost") != std::string::npos) {
      tohost_addr = addr;
      std::print("Found .tohost section at address: {:#010x}\n", addr);
    }
    auto data = section->get_data();
    auto end_data = data + size;
    for (auto p = data; p < end_data; p += PAGE_SIZE) {
      // Assuming each section starts at a page-aligned address
      // and never crosses a page boundary
      auto ppn = addr & PAGE_NUMBER_MASK;
      memory.emplace(ppn, std::vector<std::uint8_t>(p, std::min(p + PAGE_SIZE, end_data)));
      if (p + PAGE_SIZE != end_data) {
        // Fill the last page with zeros if it is not fully filled
        memory[ppn].resize(PAGE_SIZE);
      }
      addr += PAGE_SIZE;
    }
  }
  REQUIRE(!memory.empty());
  REQUIRE(!memory.contains(0));
  REQUIRE(text_init == 0x80000000);  // Assuming text_init is at this address

  memory.emplace(0, std::vector<std::uint8_t>(PAGE_SIZE));
  auto& init_data = memory[0];
  // lui x1, 0x80000000
  init_data[0] = 0xb7;
  init_data[1] = 0x00;
  init_data[2] = 0x00;
  init_data[3] = 0x80;
  // jalr x0, 0(x1); Jump to text_init
  init_data[4] = 0x67;
  init_data[5] = 0x80;
  init_data[6] = 0x00;
  init_data[7] = 0x00;

  // // Dump memory
  // for (const auto& [ppn, data] : memory) {
  //   std::print("Memory at {:#010x}:\n", ppn);
  //   for (int i = 0; i < data.size(); i += 4) {
  //     std::print("{} {:#010x}\n", i,
  //                *reinterpret_cast<const uint32_t*>(&data[i]));
  //   }
  // }

  // Set up Kanata log
  kanata_log_enabled = true;  // Change this to false to disable Kanata logging
  if (kanata_log_enabled) {
    kanata_log.open(test + ".kanata.log");
    REQUIRE(kanata_log.is_open());
    std::print(kanata_log,
               "Kanata\t0004\n"
               "C=\t0\n"
               "I\t0\t0\t0\n"
               "S\t0\t0\tPC\n"
               "L\t0\t0\t00000000\n");
  }

  tohost_written = false;

  init_dut();
}

void Tester::step() {
  // NOTE: This method might not work, if there is a load/store queue
  auto rready = dut->core_ace_rready;
  dut->core_ace_arready = 1;
  if (dut->core_ace_arvalid) {
    auto araddr = dut->core_ace_araddr;
    dut->core_ace_rvalid = 1;
    auto ppn = araddr & PAGE_NUMBER_MASK;
    if (memory.contains(ppn)) {
      std::print("araddr: {:#010x}\n", araddr);
      std::print("rdata:");
      auto offset = araddr & PAGE_OFFSET_MASK & BLOCK_MASK;  // e.g. araddr[11:6]
      for (int i = 0; i < BLOCK_BYTES / 4; ++i) {
        dut->core_ace_rdata[i] = *reinterpret_cast<const uint32_t*>(&memory[ppn][offset + 4 * i]);
        std::print(" {:#010x}", dut->core_ace_rdata[i]);
      }
      std::print("\n");
      dut->core_ace_rresp = 0;  // OKAY
    } else {
      std::print("Read from uninitialized memory at {:#010x}\n", araddr);
      dut->core_ace_rresp = 2;  // SLVERR
    }
  }

  auto bready = dut->core_ace_bready;
  dut->core_ace_awready = 1;
  dut->core_ace_wready = 1;
  if (dut->core_ace_awvalid) {
    auto awaddr = dut->core_ace_awaddr;
    dut->core_ace_bvalid = 1;
    auto ppn = awaddr & PAGE_NUMBER_MASK;
    if (memory.contains(ppn)) {
      std::print("awaddr: {:#010x}\n", awaddr);
      std::print("wdata:");
      auto offset = awaddr & PAGE_OFFSET_MASK & BLOCK_MASK;
      for (int i = 0; i < BLOCK_BYTES; ++i) {
        if ((dut->core_ace_wstrb >> i) & 1) {
          memory[ppn][offset + i] = dut->core_ace_wdata[i / 4] >> (8 * (i % 4));
        }
        std::print(" {:#04x}", memory[ppn][offset + i]);
      }
      std::print("\n");
      std::print("wstrb: {:#010x}\n", dut->core_ace_wstrb);
    }
  }

  if (dut->core_lsu_store && (dut->core_lsu_addr == tohost_addr)) {
    tohost_written = true;
    tohost_data = dut->core_lsu_wdata;
    std::print("tohost written: {:#010x}\n", tohost_data);
  }

  dut->clk = 0;
  dut->eval();

  // To observe the internal state of the DUT, we should do it between
  // negedge evaluation and posedge evaluation

  //  Update Kanata log
  if (kanata_log_enabled) {
    const char* kanata_log_buf;
    svSetScope(svGetScopeFromName("TOP.offnariscv_core_wrap"));
    dut->kanata_log_dut(&kanata_log_buf);
    std::print(kanata_log,
               "{}"
               "C\t1\n",
               kanata_log_buf);
  }

  dut->clk = 1;
  dut->eval();

  if (rready) {
    dut->core_ace_rvalid = 0;
  }

  if (bready) {
    dut->core_ace_bvalid = 0;
  }
}

static int run_simulation(Tester& tester) {
  for (int i = 0; i < 3000; ++i) {
    if (tester.tohost_written) {
      return tester.tohost_data;
    }
    tester.step();
  }
  return 0;
}

static int runner(const std::string& test) {
  std::print(
      "-------------------------------------------------------------------------------\n");
  std::print("{}\n", test);
  std::print(
      "-------------------------------------------------------------------------------\n");
  Tester tester(test);
  auto return_code = run_simulation(tester);
  if (return_code == 1) {
    std::print("Test for {} passed!\n", test);
  } else {
    std::print("Test for {} failed!\n", test);
  }
  return return_code;
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-simple") {
  REQUIRE(runner("rv32ui-p-simple") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-add") {
  REQUIRE(runner("rv32ui-p-add") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-addi") {
  REQUIRE(runner("rv32ui-p-addi") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-and") {
  REQUIRE(runner("rv32ui-p-and") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-andi") {
  REQUIRE(runner("rv32ui-p-andi") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-auipc") {
  REQUIRE(runner("rv32ui-p-auipc") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-beq") {
  REQUIRE(runner("rv32ui-p-beq") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-bge") {
  REQUIRE(runner("rv32ui-p-bge") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-bgeu") {
  REQUIRE(runner("rv32ui-p-bgeu") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-blt") {
  REQUIRE(runner("rv32ui-p-blt") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-bltu") {
  REQUIRE(runner("rv32ui-p-bltu") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-bne") {
  REQUIRE(runner("rv32ui-p-bne") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-fence_i") {
  REQUIRE(runner("rv32ui-p-fence_i") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-jal") {
  REQUIRE(runner("rv32ui-p-jal") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-jalr") {
  REQUIRE(runner("rv32ui-p-jalr") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-lb") {
  REQUIRE(runner("rv32ui-p-lb") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-lbu") {
  REQUIRE(runner("rv32ui-p-lbu") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-ld_st") {
  REQUIRE(runner("rv32ui-p-ld_st") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-lh") {
  REQUIRE(runner("rv32ui-p-lh") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-lhu") {
  REQUIRE(runner("rv32ui-p-lhu") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-lui") {
  REQUIRE(runner("rv32ui-p-lui") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-lw") {
  REQUIRE(runner("rv32ui-p-lw") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-or") {
  REQUIRE(runner("rv32ui-p-or") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-ori") {
  REQUIRE(runner("rv32ui-p-ori") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-sb") {
  REQUIRE(runner("rv32ui-p-sb") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-sh") {
  REQUIRE(runner("rv32ui-p-sh") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-sll") {
  REQUIRE(runner("rv32ui-p-sll") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-slli") {
  REQUIRE(runner("rv32ui-p-slli") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-slt") {
  REQUIRE(runner("rv32ui-p-slt") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-slti") {
  REQUIRE(runner("rv32ui-p-slti") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-sltiu") {
  REQUIRE(runner("rv32ui-p-sltiu") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-sltu") {
  REQUIRE(runner("rv32ui-p-sltu") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-sra") {
  REQUIRE(runner("rv32ui-p-sra") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-srai") {
  REQUIRE(runner("rv32ui-p-srai") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-srl") {
  REQUIRE(runner("rv32ui-p-srl") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-srli") {
  REQUIRE(runner("rv32ui-p-srli") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-st_ld") {
  REQUIRE(runner("rv32ui-p-st_ld") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-sub") {
  REQUIRE(runner("rv32ui-p-sub") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-sw") {
  REQUIRE(runner("rv32ui-p-sw") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-xor") {
  REQUIRE(runner("rv32ui-p-xor") == 1);
}

TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-xori") {
  REQUIRE(runner("rv32ui-p-xori") == 1);
}

// TEST_CASE("offnariscv_core/riscv-tests/isa/rv32ui-p-ma_data", "[ma_data]") {
//   REQUIRE(runner("rv32ui-p-ma_data") == 1);
// }

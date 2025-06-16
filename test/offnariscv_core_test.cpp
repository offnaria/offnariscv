// SPDX-License-Identifier: MIT

#include <verilated.h>

#include <catch2/catch_test_macros.hpp>
#include <catch2/generators/catch_generators.hpp>
#include <cstdint>
#include <elfio/elfio.hpp>
#include <filesystem>
#include <print>
#include <string>
#include <unordered_map>
#include <vector>

#include "Dut.hpp"
#include "Voffnariscv_core.h"

constexpr int PAGE_SIZE = 4096;
constexpr int PAGE_OFFSET_MASK = PAGE_SIZE - 1;
constexpr int PAGE_NUMBER_MASK = ~PAGE_OFFSET_MASK;

class Tester {
  Dut<Voffnariscv_core> dut;
  std::unordered_map<std::uint32_t, std::vector<std::uint8_t>> memory;

  void init_dut();

 public:
  Tester(const std::string& test);
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
  auto my_parent_path =
      std::filesystem::read_symlink("/proc/self/exe").parent_path();
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
    }
    auto data = section->get_data();
    auto end_data = data + size;
    for (auto p = data; p < end_data; p += PAGE_SIZE) {
      // Assuming each section starts at a page-aligned address
      // and never crosses a page boundary
      auto ppn = addr & PAGE_NUMBER_MASK;
      memory.emplace(
          ppn, std::vector<std::uint8_t>(p, std::min(p + PAGE_SIZE, end_data)));
      // if (p + PAGE_SIZE - 1 > end_addr) {
      //   // Fill the last page with zeros if it is not fully filled
      //   memory[ppn].resize(PAGE_SIZE, 0);
      // }
    }
  }
  REQUIRE(!memory.empty());
  REQUIRE(!memory.contains(0));
  REQUIRE(text_init == 0x80000000);  // Assuming text_init is at this address

  memory.emplace(
      0, std::vector<std::uint8_t>({
             0xb7, 0x00, 0x00, 0x80,  // lui x1, 0x80000000
             0x67, 0x80, 0x00, 0x00,  // jalr x0, 0(x1); Jump to text_init
         }));

  init_dut();
}

static int run_simulation(Tester& tester) {
  std::print("hoge\n");
  return 1;
}

static int runner(const std::string& test) {
  std::print(
      "-----------------------------------------------------------------"
      "--------------\n");
  std::print("{}\n", test);
  std::print(
      "-----------------------------------------------------------------"
      "--------------\n");
  Tester tester(test);
  auto return_code = run_simulation(tester);
  return return_code;
}

TEST_CASE("offnariscv_core_riscv-tests/isa/rv32ui-p") {
  auto test = GENERATE(
      "rv32ui-p-simple", "rv32ui-p-add", "rv32ui-p-addi", "rv32ui-p-and",
      "rv32ui-p-andi", "rv32ui-p-auipc", "rv32ui-p-beq", "rv32ui-p-bge",
      "rv32ui-p-bgeu", "rv32ui-p-blt", "rv32ui-p-bltu", "rv32ui-p-bne",
      "rv32ui-p-fence_i", "rv32ui-p-jal", "rv32ui-p-jalr", "rv32ui-p-lb",
      "rv32ui-p-lbu", "rv32ui-p-ld_st", "rv32ui-p-lh", "rv32ui-p-lhu",
      "rv32ui-p-lui", "rv32ui-p-lw", "rv32ui-p-or", "rv32ui-p-ori",
      "rv32ui-p-sb", "rv32ui-p-sh", "rv32ui-p-sll", "rv32ui-p-slli",
      "rv32ui-p-slt", "rv32ui-p-slti", "rv32ui-p-sltiu", "rv32ui-p-sltu",
      "rv32ui-p-sra", "rv32ui-p-srai", "rv32ui-p-srl", "rv32ui-p-srli",
      "rv32ui-p-st_ld", "rv32ui-p-sub", "rv32ui-p-sw", "rv32ui-p-xor",
      "rv32ui-p-xori"  //, "rv32ui-p-ma_data"
  );
  REQUIRE(runner(test) == 1);
}

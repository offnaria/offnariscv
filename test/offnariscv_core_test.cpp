// SPDX-License-Identifier: MIT

#include <catch2/catch_test_macros.hpp>
#include <catch2/generators/catch_generators.hpp>
#include <cstdio>
#include <memory>
#include <print>
#include <string>
#include <vector>

#include "cachesim.h"
#include "cfg.h"
#include "config.h"
#include "extension.h"
#include "sim.h"

sim_t* s;

void init_spike() {
  bool debug = false;
  bool halted = false;
  bool histogram = false;
  bool log = false;
  bool UNUSED socket = false;
  bool dump_dts = false;
  bool dtb_enabled = true;
  const char* kernel = NULL;
  reg_t kernel_offset, kernel_size;
  std::vector<device_factory_sargs_t> plugin_device_factories;
  std::unique_ptr<icache_sim_t> ic;
  std::unique_ptr<dcache_sim_t> dc;
  std::unique_ptr<cache_sim_t> l2;
  bool log_cache = false;
  bool log_commits = false;
  const char* log_path = nullptr;
  std::vector<std::function<extension_t*()>> extensions;
  const char* initrd = NULL;
  const char* dtb_file = NULL;
  uint16_t rbb_port = 0;
  bool use_rbb = false;
  unsigned dmi_rti = 0;
  reg_t blocksz = 64;
  std::optional<unsigned long long> instructions;
  debug_module_config_t dm_config;
  cfg_arg_t<size_t> nprocs(1);

  cfg_t cfg;

  FILE* cmd_file = NULL;
  std::vector<std::string> htif_args;
  std::vector<std::pair<reg_t, abstract_mem_t*>> mems;

  s = new sim_t(&cfg, halted, mems, plugin_device_factories, htif_args,
                dm_config, log_path, dtb_enabled, dtb_file, socket, cmd_file,
                instructions);
}

void cleanup_spike() { delete s; }

int runner(const std::string& test) {
  std::print(
      "-----------------------------------------------------------------"
      "--------------\n");
  std::print("{}\n", test);
  init_spike();
  // TODO
  cleanup_spike();
  return 0;
}

TEST_CASE("riscv-tests/isa/rv32ui-p") {
  auto test = GENERATE(
      "rv32ui-p-simple", "rv32ui-p-add", "rv32ui-p-addi", "rv32ui-p-and",
      "rv32ui-p-andi", "rv32ui-p-auipc", "rv32ui-p-beq", "rv32ui-p-bge",
      "rv32ui-p-bgeu", "rv32ui-p-blt", "rv32ui-p-bltu", "rv32ui-p-bne",
      "rv32ui-p-fence_i", "rv32ui-p-jal", "rv32ui-p-jalr", "rv32ui-p-lb",
      "rv32ui-p-lbu", "rv32ui-p-ld_st", "rv32ui-p-lh", "rv32ui-p-lhu",
      "rv32ui-p-lui", "rv32ui-p-lw", "rv32ui-p-ma_data", "rv32ui-p-or",
      "rv32ui-p-ori", "rv32ui-p-sb", "rv32ui-p-sh", "rv32ui-p-sll",
      "rv32ui-p-slli", "rv32ui-p-slt", "rv32ui-p-slti", "rv32ui-p-sltiu",
      "rv32ui-p-sltu", "rv32ui-p-sra", "rv32ui-p-srai", "rv32ui-p-srl",
      "rv32ui-p-srli", "rv32ui-p-st_ld", "rv32ui-p-sub", "rv32ui-p-sw",
      "rv32ui-p-xor", "rv32ui-p-xori");
  REQUIRE(runner(test) == 0);
}

/*
TEST_CASE("riscv-tests/isa/rv32um-p") {
  auto test = GENERATE("rv32um-p-div", "rv32um-p-divu", "rv32um-p-mul",
                       "rv32um-p-mulh", "rv32um-p-mulhsu", "rv32um-p-mulhu",
                       "rv32um-p-rem", "rv32um-p-remu");
  REQUIRE(runner(test) == 0);
}

TEST_CASE("riscv-tests/isa/rv32ua-p") {
  auto test =
      GENERATE("rv32ua-p-amoadd_w", "rv32ua-p-amoand_w", "rv32ua-p-amomax_w",
               "rv32ua-p-amomaxu_w", "rv32ua-p-amomin_w", "rv32ua-p-amominu_w",
               "rv32ua-p-amoor_w", "rv32ua-p-amoswap_w", "rv32ua-p-amoxor_w",
               "rv32ua-p-lrsc");
  REQUIRE(runner(test) == 0);
}

TEST_CASE("riscv-tests/isa/rv32mi-p") {
  auto test =
      GENERATE("rv32mi-p-breakpoint", "rv32mi-p-csr", "rv32mi-p-illegal",
               "rv32mi-p-instret_overflow", "rv32mi-p-lh-misaligned",
               "rv32mi-p-lw-misaligned", "rv32mi-p-ma_addr",
               "rv32mi-p-ma_fetch", "rv32mi-p-mcsr", "rv32mi-p-pmpaddr",
               "rv32mi-p-sbreak", "rv32mi-p-scall", "rv32mi-p-sh-misaligned",
               "rv32mi-p-shamt", "rv32mi-p-sw-misaligned", "rv32mi-p-zicntr");
  REQUIRE(runner(test) == 0);
}

TEST_CASE("riscv-tests/isa/rv32si-p") {
  auto test = GENERATE("rv32si-p-csr", "rv32si-p-dirty", "rv32si-p-ma_fetch",
                       "rv32si-p-sbreak", "rv32si-p-scall", "rv32si-p-wfi");
  REQUIRE(runner(test) == 0);
}

TEST_CASE("riscv-tests/isa/rv32ui-v") {
  auto test = GENERATE(
      "rv32ui-v-simple", "rv32ui-v-add", "rv32ui-v-addi", "rv32ui-v-and",
      "rv32ui-v-andi", "rv32ui-v-auipc", "rv32ui-v-beq", "rv32ui-v-bge",
      "rv32ui-v-bgeu", "rv32ui-v-blt", "rv32ui-v-bltu", "rv32ui-v-bne",
      "rv32ui-v-fence_i", "rv32ui-v-jal", "rv32ui-v-jalr", "rv32ui-v-lb",
      "rv32ui-v-lbu", "rv32ui-v-ld_st", "rv32ui-v-lh", "rv32ui-v-lhu",
      "rv32ui-v-lui", "rv32ui-v-lw", "rv32ui-v-ma_data", "rv32ui-v-or",
      "rv32ui-v-ori", "rv32ui-v-sb", "rv32ui-v-sh", "rv32ui-v-sll",
      "rv32ui-v-slli", "rv32ui-v-slt", "rv32ui-v-slti", "rv32ui-v-sltiu",
      "rv32ui-v-sltu", "rv32ui-v-sra", "rv32ui-v-srai", "rv32ui-v-srl",
      "rv32ui-v-srli", "rv32ui-v-st_ld", "rv32ui-v-sub", "rv32ui-v-sw",
      "rv32ui-v-xor", "rv32ui-v-xori");
  REQUIRE(runner(test) == 0);
}

TEST_CASE("riscv-tests/isa/rv32um-v") {
  auto test = GENERATE("rv32um-v-div", "rv32um-v-divu", "rv32um-v-mul",
                       "rv32um-v-mulh", "rv32um-v-mulhsu", "rv32um-v-mulhu",
                       "rv32um-v-rem", "rv32um-v-remu");
  REQUIRE(runner(test) == 0);
}

TEST_CASE("riscv-tests/isa/rv32ua-v") {
  auto test =
      GENERATE("rv32ua-v-amoadd_w", "rv32ua-v-amoand_w", "rv32ua-v-amomax_w",
               "rv32ua-v-amomaxu_w", "rv32ua-v-amomin_w", "rv32ua-v-amominu_w",
               "rv32ua-v-amoor_w", "rv32ua-v-amoswap_w", "rv32ua-v-amoxor_w",
               "rv32ua-v-lrsc");
  REQUIRE(runner(test) == 0);
}
*/

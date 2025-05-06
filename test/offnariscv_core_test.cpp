// SPDX-License-Identifier: MIT

#include <catch2/catch_test_macros.hpp>
#include <catch2/generators/catch_generators.hpp>
#include <print>
#include <string>

int runner(const std::string &test) {
  std::print(
      "-----------------------------------------------------------------"
      "--------------\n");
  std::print("{}\n", test);
  return 0;
}

TEST_CASE("riscv-tests/isa/rv32ui-p") {
  auto test = GENERATE(
      "rv32ui-p-add", "rv32ui-p-addi", "rv32ui-p-and", "rv32ui-p-andi",
      "rv32ui-p-auipc", "rv32ui-p-beq", "rv32ui-p-bge", "rv32ui-p-bgeu",
      "rv32ui-p-blt", "rv32ui-p-bltu", "rv32ui-p-bne", "rv32ui-p-fence_i",
      "rv32ui-p-jal", "rv32ui-p-jalr", "rv32ui-p-lb", "rv32ui-p-lbu",
      "rv32ui-p-ld_st", "rv32ui-p-lh", "rv32ui-p-lhu", "rv32ui-p-lui",
      "rv32ui-p-lw", "rv32ui-p-ma_data", "rv32ui-p-or", "rv32ui-p-ori",
      "rv32ui-p-sb", "rv32ui-p-sh", "rv32ui-p-simple", "rv32ui-p-sll",
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
*/

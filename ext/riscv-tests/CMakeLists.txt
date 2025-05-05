# SPDX-License-Identifier: MIT

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/ext/riscv-tests/riscv-tests)
add_custom_target(riscv-tests-isa ALL WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/ext/riscv-tests/riscv-tests
  # COMMAND autoconf -o configure ${CMAKE_CURRENT_SOURCE_DIR}/riscv-tests/configure.ac
  COMMAND CC=riscv32-unknown-elf-gcc ${CMAKE_CURRENT_SOURCE_DIR}/riscv-tests/configure --with-xlen=32
  COMMAND make -j`nproc` isa
  COMMENT "Building riscv-tests/isa")

# SPDX-License-Identifier: MIT

add_custom_target(riscv-tests-isa ALL WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/riscv-tests
  COMMAND autoconf
  COMMAND CC=riscv32-unknown-elf-gcc ./configure --with-xlen=32
  COMMAND make -j`nproc` isa
  COMMAND install -p -m 644 -D -t ${CMAKE_BINARY_DIR}/riscv-tests/riscv-tests/isa `find isa -maxdepth 1 -type f`
  COMMENT "Building riscv-tests/isa")

add_custom_target(riscv-tests-clean WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/riscv-tests
  COMMAND make clean
  COMMENT "Cleaning riscv-tests/isa")

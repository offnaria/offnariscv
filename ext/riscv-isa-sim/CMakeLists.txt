# SPDX-License-Identifier: MIT

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/ext/riscv-isa-sim/riscv-isa-sim)
add_custom_target(riscv-isa-sim WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/ext/riscv-isa-sim/riscv-isa-sim
  COMMAND CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} ${CMAKE_CURRENT_SOURCE_DIR}/riscv-isa-sim/configure --with-arch=riscv --with-abi=ilp32
  COMMAND make -j`nproc` mcppbs-CPPFLAGS="-stdlib=libc++" LDFLAGS="-stdlib=libc++"
  COMMENT "Building riscv-isa-sim")

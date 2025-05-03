# SPDX-License-Identifier: MIT

add_executable(main main.cpp)

find_package(verilator)
add_subdirectory(ifu)
add_subdirectory(lsu)

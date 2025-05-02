# SPDX-License-Identifier: MIT

cmake_minimum_required(VERSION 3.12)
set(CMAKE_CXX_COMPILER clang++-19)
set(CMAKE_CXX_STANDARD 23)

project(offnariscv CXX)
set(CMAKE_CXX_FLAGS "-march=native -O3 -stdlib=libc++")
set(CMAKE_EXE_LINKER_FLAGS "-fuse-ld=mold")

add_subdirectory(test)

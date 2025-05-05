FROM amd64/ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root

# Verilator

RUN apt update
RUN apt install -y git help2man perl python3 make
RUN apt install -y clang-19 libc++-19-dev libc++abi-19-dev
RUN apt install -y libfl2 libfl-dev  zlib1g zlib1g-dev
RUN apt install -y ccache mold libgoogle-perftools-dev numactl
RUN apt install -y autoconf flex bison
RUN apt install -y cmake ninja-build
RUN apt install -y device-tree-compiler

RUN git clone https://github.com/verilator/verilator
RUN cd verilator && \
    git pull && \
    git checkout v5.030 && \
    autoconf && \
    CC=clang-19 CXX=clang++-19 ./configure && \
    make -j`nproc` && \
    make install

# riscv-gnu-toolchain

RUN apt install -y automake autotools-dev curl python3-pip python3-tomli \
    libmpc-dev libmpfr-dev libgmp-dev gawk build-essential texinfo \
    gperf libtool patchutils bc libexpat-dev libglib2.0-dev libslirp-dev

ENV ARCH=rv32ima_zicsr_zifencei_zicntr
ENV RISCV=/opt/riscv
ENV PATH=$PATH:${RISCV}/bin

RUN git clone https://github.com/riscv/riscv-gnu-toolchain
RUN cd riscv-gnu-toolchain && \
    git pull && \
    git checkout 2025.05.01 && \
    ./configure --prefix=${RISCV} --with-arch=riscv --with-abi=ilp32 && \
    make -j`nproc`

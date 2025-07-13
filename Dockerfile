FROM amd64/ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root

RUN apt update && \
    apt install -y \
        git \
        help2man \
        perl \
        python3 \
        make \
        clang-19 \
        libc++-19-dev \
        libc++abi-19-dev \
        libfl2 \
        libfl-dev \
        zlib1g \
        zlib1g-dev \
        ccache \
        mold \
        libgoogle-perftools-dev \
        numactl \
        autoconf \
        flex \
        bison \
        cmake \
        ninja-build \
        device-tree-compiler \
        automake \
        autotools-dev \
        curl \
        python3-pip \
        python3-tomli \
        libmpc-dev \
        libmpfr-dev \
        libgmp-dev \
        gawk \
        build-essential \
        texinfo \
        gperf \
        libtool \
        patchutils \
        bc \
        libexpat-dev \
        libglib2.0-dev \
        libslirp-dev

# Verilator
RUN git clone https://github.com/verilator/verilator && \
    cd verilator && \
    git pull && \
    git checkout v5.038 && \
    autoconf && \
    CC=clang-19 CXX=clang++-19 ./configure && \
    make -j`nproc` && \
    make install

# riscv-gnu-toolchain
ENV ARCH=rv32ima_zicsr_zifencei_zicntr
ENV RISCV=/opt/riscv
ENV PATH=$PATH:${RISCV}/bin
RUN git clone https://github.com/riscv/riscv-gnu-toolchain && \
    cd riscv-gnu-toolchain && \
    git pull && \
    git checkout 2025.05.01 && \
    ./configure --prefix=${RISCV} --with-arch=${ARCH} --with-abi=ilp32 && \
    make -j`nproc`

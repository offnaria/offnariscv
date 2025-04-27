FROM amd64/ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt install -y git help2man perl python3 make
RUN apt install -y clang-19 libc++-19-dev libc++abi-19-dev
RUN apt install -y libfl2 libfl-dev  zlib1g zlib1g-dev
RUN apt install -y ccache mold libgoogle-perftools-dev numactl
RUN apt install -y autoconf flex bison
RUN apt install -y cmake ninja-build

WORKDIR /root

RUN git clone https://github.com/verilator/verilator
RUN cd verilator && \
    git pull && \
    git checkout v5.030 && \
    autoconf && \
    CC=clang-19 CXX=clang++-19 ./configure && \
    make -j$(((nproc)/2+1)) && \
    make install

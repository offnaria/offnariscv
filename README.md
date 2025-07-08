# offnariscv

This is the ~~n-th~~ first RISC-V processor designed and implemented by offNaria.

## Features

- CPU core
    - [x] RV32I Base Integer Instruction Set, Version 2.1
    - [ ] "M" Standard Extension for Integer Multiplication and Division, Version 2.0
    - [ ] "A" Standard Extension for Atomic Instructions, Version 2.1
    - [x] "Zicsr", Control and Status Register (CSR) Instructions, Version 2.0
    - [x] "Zifencei" Instruction-Fetch Fence, Version 2.0
    - [ ] "Zicntr" Standard Extension for Base Counters and Timers
    - [ ] "Zihpm" Standard Extension for Hardware Performance Counters
- Memory system
    - Cache
        - Basics
            - [x] L1 Instruction cache
            - [ ] L1 Data cache
            - [ ] L2
        - Coherency
            - [ ] SI protocol
            - [ ] MSI protocol
            - [ ] MESI protocol
            - [ ] MOESI protocol
    - Virtual memory
        - [ ] Sv32 page walker
            - [ ] Svade extension, v1.0
            - [ ] Svadu extension, v1.0
        - [ ] L1I TLB
        - [ ] L1D TLB
- SoC integration
    - [ ] Porting to LiteX
    - [ ] Implementing CLINT
    - [ ] Implementing PLIC
- Verification and evaluation
    - [x] Verilator
        - [x] CMake
    - [x] [Spike](https://github.com/riscv-software-src/riscv-isa-sim)
    - [x] [Konata](https://github.com/shioyadan/Konata)
    - [ ] GitHub Actions

## Prerequisites

> [!NOTE]
> I'm using Ubuntu 22.04.5 LTS on WSL2, Windows 11.
> The kernel version is `5.15.167.4-microsoft-standard-WSL2`.

Install the Docker Engine.

```bash
sudo apt update
# sudo apt upgrade -y
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

## Getting started

Clone the repository **recursively** and enther the directory.
Don't forget `--recursive`!!!!

```bash
git clone --recursive git@github.com:offnaria/offnariscv.git # Don't forget --recursive!!!!
cd offnariscv
# git submodule update --init --recursive # Do this, if you forgot --recursive at cloning the repo.
```

Set up the Docker container.
This will take for a while.
Then, enter the container.

```bash
sudo docker build . -t offnariscv
sudo docker run -it -d -v `pwd`:/root/offnariscv --name i_offnariscv offnariscv
sudo docker exec -it i_offnariscv bash
```

Or if the container exists, start it and then attach.
I also provide a make rule to execute it.

```bash
sudo docker start i_offnariscv
sudo docker attach i_offnariscv
# sudo make docker-start # This command executes two commands above.
```

Now you're in the docker container.
Type the following command to enter the repo directory and check where you are.

```bash
cd offnariscv
pwd # /root/offnariscv
```

Build the project in `build` subdirectory.

```bash
mkdir build
cd build
cmake -GNinja ..
ninja
```

Or you can simply execute `make` command.

```bash
make
cd build
```

NOTE: You can remove the container and the image by executing following commands.

```bash
sudo docker rm i_offnariscv -f
sudo docker rmi offnariscv
```

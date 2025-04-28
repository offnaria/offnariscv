# offnariscv

This is the ~~n-th~~ first RISC-V processor designed and implemented by offNaria.

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

Clone the repository and enther the directory.

```bash
git clone git@github.com:offnaria/offnariscv.git
cd offnariscv
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

```bash
sudo docker start i_offnariscv
sudo docker attach i_offnariscv
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

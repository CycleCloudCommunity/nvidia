#! /bin/bash

# Install CUDA libraries
wget http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda_7.5.18_linux.run
chmod +x cuda_7.5.18_linux.run
./cuda_7.5.18_linux.run --silent --toolkit --toolkitpath=/shared/opt/cuda-7.5.18
source /etc/cluster-setup.sh
# Configure GPU complex for SGE
qconf -Mc /mnt/cluster-init/scratch/gpucomplex
qconf -Mconf /mnt/cluster-init/scratch/global
chmod 777 /local

# Runs on all hosts
yum install -y gcc-c++ gcc-gfortran vim
chmod +x /mnt/cluster-init/nvidia/execute/files/prolog.sh
chmod +x /mnt/cluster-init/nvidia/execute/files/epilog.sh

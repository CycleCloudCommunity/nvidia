#!/bin/bash

# get build tools needed to compile nvidia driver
yum groupinstall -y "Development tools"
yum install -y gcc-c++ gcc-gfortran vim

# get and build the driver
wget http://us.download.nvidia.com/XFree86/Linux-x86_64/352.99/NVIDIA-Linux-x86_64-352.99.run
chmod +x NVIDIA-Linux-x86_64-352.99.run
./NVIDIA-Linux-x86_64-352.99.run -s -z --no-cc-version-check
# Tune NVIDIA settings
nvidia-smi -pm 1
nvidia-smi -acp 0
nvidia-smi --auto-boost-permission=0
nvidia-smi -ac 2505,875
# Install cron job to update GPU info
cp /mnt/cluster-init/scratch/gpucron /etc/cron.d/
chmod +x /mnt/cluster-init/scratch/modify_gpu_count.cron.sh
chmod 777 /local

# Make the node available to sge
chmod +x /mnt/cluster-init/nvidia/execute/files/prolog.sh
chmod +x /mnt/cluster-init/nvidia/execute/files/epilog.sh

#! /bin/bash

NVIDIA_DRIVER_BUILD=$( jetpack config nvidia.driver.build 2> /dev/null )
NVIDIA_DRIVER_URL=$( jetpack config nvidia.driver.url 2> /dev/null )

if [ -z "${NVIDIA_DRIVER_BUILD}" ]; then
    NVIDIA_DRIVER_BUILD="375.26"
fi
if [ -z "${NVIDIA_DRIVER_URL}" ]; then
    NVIDIA_DRIVER_URL="http://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_DRIVER_BUILD}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_BUILD}.run"
fi

NVIDIA_DRIVER_INSTALLER=$( basename ${NVIDIA_DRIVER_URL} )

# get build tools needed to compile nvidia driver
if [ -n "$(command -v yum)" ]; then
   yum groupinstall -y "Development tools"
   yum install -y gcc-c++ gcc-gfortran vim
else
    apt-get -y install linux-headers-$(uname -r) build-essential
fi

cd /tmp

# get and build the driver
if [[ ${NVIDIA_DRIVER_URL} == http* ]]; then
    wget ${NVIDIA_DRIVER_URL}
else
    pogo get ${NVIDIA_DRIVER_URL} .
fi
chmod +x ${NVIDIA_DRIVER_INSTALLER}

sh ./${NVIDIA_DRIVER_INSTALLER} -s -z --no-cc-version-check

# Tune NVIDIA settings
nvidia-smi -pm 1
nvidia-smi -acp 0
nvidia-smi --auto-boost-permission=0
nvidia-smi -ac 2505,875

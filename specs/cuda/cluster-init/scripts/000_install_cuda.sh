#! /bin/bash -x

NVIDIA_DRIVER_BUILD=$( jetpack config nvidia.driver.build 2> /dev/null )

CUDA_DIR=$( jetpack config nvidia.cuda.dir 2> /dev/null )

CUDA_VERSION=$( jetpack config nvidia.cuda.version 2> /dev/null )

CUDA_BUILD=$( jetpack config nvidia.cuda.build 2> /dev/null )

CUDA_URL=$( jetpack config nvidia.cuda.url 2> /dev/null )


if [ -z "${CUDA_DIR}" ]; then
    # cuda is large and should often be installed to a second volume
    # We also generally want to share it so that we don't have to install on every
    # node.
    CUDA_DIR="/shared/nvidia"
fi
if [ -z "${CUDA_VERSION}" ]; then
    CUDA_VERSION="8.0"
fi
if [ -z "${NVIDIA_DRIVER_BUILD}" ]; then
    NVIDIA_DRIVER_BUILD="375.26"
fi
if [ -z "${CUDA_BUILD}" ]; then
    CUDA_BUILD="8.0.61_${NVIDIA_DRIVER_BUILD}_linux"
fi
if [ -z "${CUDA_URL}" ]; then
    CUDA_URL="http://developer.download.nvidia.com/compute/cuda/${CUDA_VERSION}/Prod2/local_installers/cuda_${CUDA_BUILD}.run"
    
    if [[ ${CUDA_VERSION} == 7* ]]; then
        # Older url format
        CUDA_URL="http://developer.download.nvidia.com/compute/cuda/${CUDA_VERSION}/Prod/local_installers/cuda_${CUDA_BUILD}.run"
    fi
fi

CUDA_INSTALLER=$( basename ${CUDA_URL} )

CUDA_HOME=$CUDA_DIR/cuda-${CUDA_VERSION}


if [ -n "$(command -v yum)" ]; then
   yum groupinstall -y "Development tools"
   yum install -y gcc-c++ gcc-gfortran vim
else
    apt-get -y install linux-headers-$(uname -r) build-essential
fi

if ! [ -a $CUDA_DIR/tmp ]; then
  mkdir -p $CUDA_DIR/tmp
fi

if ! [ -a  $CUDA_HOME ]; then
  mkdir -p $CUDA_HOME
fi

cd /tmp

if [[ ${CUDA_URL} == http* ]]; then
    wget ${CUDA_URL}
else
    pogo get ${CUDA_URL} .
fi

chmod a+x ${CUDA_INSTALLER}

# Auto-install the driver as well...
# sh ./${CUDA_INSTALLER} --driver --toolkit --silent --tmpdir=${CUDA_DIR}/tmp --toolkitpath=${CUDA_HOME}

# Install just the toolkit (can be installed on a non-GPU node)
sh ./${CUDA_INSTALLER} --toolkit --silent --tmpdir=${CUDA_DIR}/tmp --toolkitpath=${CUDA_HOME}
EXIT_CODE=$?

echo "CUDA installation completed (status: ${EXIT_CODE})"
exit ${EXIT_CODE}

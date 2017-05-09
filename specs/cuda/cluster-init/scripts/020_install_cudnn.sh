#! /bin/bash -x


. /etc/profile.d/cuda-env.sh

CUDA_INSTALL_CUDNN=$( jetpack config nvidia.cuda.cudnn.install_cudnn 2> /dev/null | tr '[:upper:]' '[:lower:]')

CUDA_CUDNN_VERSION=$( jetpack config nvidia.cuda.cudnn.version 2> /dev/null )

if [ -z "${CUDA_INSTALL_CUDNN}" ]; then
    CUDA_INSTALL_CUDNN="true"
fi
if [ -z "${CUDA_CUDNN_VERSION}" ]; then
    # Currently, 5.1 is the default version for tensorflow-gpu
    CUDA_CUDNN_VERSION="5.1"
fi

if [ "${CUDA_INSTALL_CUDNN}" != "true" ]; then
    echo "Skipping cuDNN installation..."
    exit 0
fi

CUDA_CUDNN_URL="s3://com.cyclecomputing.chef-repo.common.us-east-1/nvidia/cudnn-${CUDA_VERSION}-linux-x64-v${CUDA_CUDNN_VERSION}.tgz"
CUDA_CUDNN_INSTALLER=$( basename ${CUDA_CUDNN_URL} )

set -e

cd $CUDA_DIR/tmp

if [[ ${CUDA_CUDNN_URL} == http* ]]; then
    wget ${CUDA_CUDNN_URL}
else
    pogo --config=/opt/cycle/jetpack/config/chef-pogo.ini get ${CUDA_CUDNN_URL} .
fi

mkdir ./cudnn
tar xzf ${CUDA_CUDNN_INSTALLER} -C ./cudnn --strip-components=1

cp -a ./cudnn/* ${CUDA_HOME}/

echo "CUDNN installed."


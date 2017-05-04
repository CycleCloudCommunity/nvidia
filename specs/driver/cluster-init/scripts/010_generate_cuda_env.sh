#!/bin/bash
# Speculatively generate a cuda env.
# Assumes that some node in the cluster installs cuda in a shared location or on this node.

CUDA_PROFILE_DISABLED=$( jetpack config nvidia.cuda.disable_profile 2> /dev/null )
if [ "${CUDA_PROFILE_DISABLED}" == "true" ]; then
    echo "Skipping cuda profile generation."
    exit 0
else

    CUDA_DIR=$( jetpack config nvidia.cuda.dir 2> /dev/null )

    CUDA_VERSION=$( jetpack config nvidia.cuda.version 2> /dev/null )

    if [ -z "${CUDA_DIR}" ]; then
        # cuda is large and should often be installed to a second volume
        # We also generally want to share it so that we don't have to install on every
        # node.
        CUDA_DIR="/shared/nvidia"
    fi
    if [ -z "${CUDA_VERSION}" ]; then
        CUDA_VERSION="8.0"
    fi

    CUDA_HOME=$CUDA_DIR/cuda-${CUDA_VERSION}
    
    cat <<EOF > /etc/profile.d/cuda-env.sh
#!/bin/bash

export CUDA_DIR=${CUDA_DIR}
export CUDA_HOME=${CUDA_HOME}
export CUDA_VERSION=${CUDA_VERSION}

export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:\${LD_LIBRARY_PATH}

EOF
    chmod 755 /etc/profile.d/cuda-env.sh
fi



    

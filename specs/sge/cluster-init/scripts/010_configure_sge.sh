#! /bin/bash

source /etc/cluster-setup.sh

mkdir -p /etc/sge
chmod 755 /etc/sge


# Runs only on scheduler
if jetpack config roles | grep -q 'scheduler'; then

    # Configure GPU complex for SGE
    qconf -Mc ${CYCLECLOUD_SPEC_PATH}/files/gpucomplex
    qconf -Mconf ${CYCLECLOUD_SPEC_PATH}/files/global
    
else
    # Runs only on exec nodes
    
    # Install temporary cron job to update GPU info after node has been authorized by SGE
    cp ${CYCLECLOUD_SPEC_PATH}/files/modify_gpu_count.cron.sh /etc/sge
    chmod +x /etc/sge/modify_gpu_count.cron.sh 
    
    cp ${CYCLECLOUD_SPEC_PATH}/files/gpucron /etc/cron.d/
    chmod +x /etc/cron.d/gpucron
    
fi
    
# Runs on all hosts
cp ${CYCLECLOUD_SPEC_PATH}/files/prolog.sh /etc/sge/
cp ${CYCLECLOUD_SPEC_PATH}/files/epilog.sh /etc/sge/
chmod +x /etc/sge/prolog.sh
chmod +x /etc/sge/epilog.sh

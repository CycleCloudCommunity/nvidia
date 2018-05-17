#! /bin/bash
set -e

yum install -y gcc wget

if [ $(modinfo nvidia 2>%1 | grep -c version) -eq 0 ]
then
	cd /tmp
	wget -O NVIDIA-Linux-x86_64-grid.run https://go.microsoft.com/fwlink/?linkid=849941  
	chmod +x NVIDIA-Linux-x86_64-grid.run
	sh ./NVIDIA-Linux-x86_64-grid.run -s -z --no-cc-version-check
	EXIT_CODE=$?
	if [ "${EXIT_CODE}" -ne 0 ]; then
			echo "NVidia driver installation failed (status: ${EXIT_CODE}."
			exit ${EXIT_CODE}
	fi
fi

# Tune NVIDIA settings
nvidia-smi -pm 1
nvidia-smi -acp 0
nvidia-smi --auto-boost-permission=0
nvidia-smi -ac 2505,875


cp /etc/nvidia/gridd.conf.template /etc/nvidia/gridd.conf
echo "IgnoreSP=TRUE" >> /etc/nvidia/gridd.conf

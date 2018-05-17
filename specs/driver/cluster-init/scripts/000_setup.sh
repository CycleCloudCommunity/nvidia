#!/bin/bash
set -e

# Instructions taken from https://docs.microsoft.com/en-us/azure/virtual-machines/linux/n-series-driver-setup?toc=%2fazure%2fvirtual-machines%2flinux%2ftoc.json#install-grid-drivers-for-nv-series-vms


if [ $(grep -c -i centos /etc/os-release) -gt 0 ]
then
	echo 'blacklist nouveau' >> /etc/modprobe.d/blacklist.conf
	echo 'blacklist lbm-nouveau ' >> /etc/modprobe.d/blacklist.conf
	# kernel version needs to match one from the LIS/CentOS74/install.sh script
	KERNEL=$(jetpack config nvidia.kernel.target)
	if [ -z $KERNEL ]
	then
		KERNEL="3.10.0-693.21.1.el7"
	fi
	dracut /boot/initramfs-$KERNEL.img $KERNEL --force

	yum install -y kernel-$KERNEL kernel-devel-$KERNEL
	if [ $(uname -r | grep -c $KERNEL) -lt 1 ]
	then
		# Activate the new kernel before installing LIS
		reboot
	fi

	if [ $(rpm -qa microsoft-hyper-v | wc -l) -lt 1 ]
	then
		cd /tmp
		wget https://aka.ms/lis
		tar xvzf lis
		cd LISISO
		./install.sh
		if [ $? -eq 0 ]; 
		then
			reboot
		fi
	fi
fi

echo "Done with setup"

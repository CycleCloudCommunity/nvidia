#! /bin/bash

#cuda is large and should be installed to a second volume
cuda_dir="/media/nvidia_files"
cuda_version="cuda-8.0"


if ! [ -a $cuda_dir/tmp ]; then
  mkdir $cuda_dir/tmp
fi

if ! [ -a  $cuda_dir/$cuda_version ]; then
  mkdir $cuda_dir/$cuda_version
fi 

sh /mnt/cluster-init/nvidia/cuda/files/cuda_8.0.61_375.26_linux.run --driver --toolkit --silent --tmpdir=$cuda_dir --toolkitpath=$cuda_dir/$cuda_version


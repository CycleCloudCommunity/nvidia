nVIDIA
========

This project installs varios nVidia components

   
Pre-Requisites
--------------

You'll need to follow these steps to enable GPU support for various different functions. 
To this end, this project is broken into several specs. These are ``CUDA`` and ``driver``.
To enable either of these features, you'll need to start with a cluster template.

If you want to enable CUDA, you'll also need to download a copy of the CUDA library installer
from nVidia.


Usage
=====

A. Configuring the Project
--------------------------

The first step is to configure the project for use with your storage locker:

  1. Open a terminal session with the CycleCloud CLI enabled.

  2. Switch to the nvidia directory.

  3. Run ``cyclecloud project add_target my_locker`` (assuming the locker is named "my_locker").
     The locker name will generally be the same as the cloud provider you created when configuring
     CycleCloud. The expected output looks like this:::

       $ cyclecloud project add_target my_locker
       Name: nvidia
       Version: 1.0.0
       Targets:
          my_locker: {'default': 'true', 'is_locker': 'true'}

     NOTE: You may call add_target as many times as needed to add additional target lockers.

  4. If you need CUDA support, place the downloaded CUDA installer in the ``nvidia/specs/cuda/cluster-init/files``
     directory, and ensure that ``nvidia/specs/cuda/cluster-init/scripts/000_install_cuda.sh`` matches the
     version of CUDA you downloaded.

       
B. Deploying the Project
------------------------

To upload the project (including any local changes) to your target locker, run the
``cyclecloud project upload`` command from the project directory.  The expected output looks like
this:::

    $ cyclecloud project upload
    Sync completed!

*IMPORTANT*

For the upload to succeed, you must have a valid Pogo configuration for your target Locker.

C. Editing the Cluster Template
-------------------------------

To install just the driver, you'll need to add a new cluster-init section to your **nodearray** and,
if it's not the only **cluster-init** section, you'll need to give it an order between 1 and 1000 to 
install in. In this example, tensorflow is installed after the nvidia driver:

::
  [[nodearray execute-gpu]]
    [[[cluster-init driver]]]
    Project = nvidia
    Version = 1.0.0
    Spec = driver
    Order = 800

    [[[cluster-init tensorflow]]]
    Project = tensorflow
    Version = 1.0.0
    Spec = tensorflow
    Order = 900

The nVidia driver isn't terribly large, but the CUDA section is much larger than should fit on most
cloud node root volumes. To install CUDA, you'll need to add a second volume to your instances to
provide instalation space for the CUDA libraries. This volume must be mounted to **'nvidia_files'**.

::
  [[nodearray execute-gpu]]
    [[[cluster-init driver]]]
    Project = nvidia
    Version = 1.0.0
    Spec = driver
    Order = 800

    [[[cluster-init cuda]]]
    Project = nvidia
    Version = 1.0.0
    Spec = cuda
    Order = 850

    [[[cluster-init tensorflow]]]
    Project = tensorflow
    Version = 1.0.0
    Spec = tensorflow
    Order = 900

    [[[volume nvidia_files]]]
    mount = nvidia_files
    Size = 16


D. Importing the Cluster Template
---------------------------------

To import the cluster:

  1. Open a terminal session with the CycleCloud CLI enabled.

  2. Switch to the template directory of your project. In this example, I'm using tensorflow.
  
  3. Choose whether or not to include GPU support in the cluster, and import your modified template  

  4. Import your cluster template:
     Run ``cyclecloud import_template TensorFlowGPU -f templates/sge_tensorflow_gpu_template.txt``.  
     Where **TensorFlowGPU** is the name CycleCloud will use to reference clusters of this type. The
     expected output looks like this:::

       $ cyclecloud import_template TensorFlowGPU -f templates/sge_tensorflow_gpu_template.txt
       Importing template TensorFlowGPU....
       ----------------------
       TensorFlowGPU: *template*
       ----------------------
       Keypair: $keypair
       Cluster nodes:
           master: off
       Total nodes: 1


D. Creating GPU enabled Cluster
---------------------------

  1. Log in to your CycleCloud from your browser.

  2. Click the **"Clusters"** to navigate to the CycleCloud "Clusters" page, if
     you are not already there.

  3. Click the **"+"** button in the "Clusters" frame to create a new cluster.

  4. In the cluster creation page, click on the new cluster icon. In this example, the new
     icon will be named **TensorFlowGPU**

  5. Configure your cluster:
     a. select the Cloud Provider Credentials to use and enter a Name
     for the cluster
     c. Adjust MachineTypes as necessary or accept defaults
     d. Select a VPC subnet to instantiate the cluster into

  6. Click the **"Save"** button.


E. Starting and Stopping the TensorFlow Cluster
------------------------------------------

  1. Select the newly created cluster from the **Clusters**
     frame on the CycleCloud "Clusters" page

  2. To start the cluster, click the **Start** link in the cluster status
     frame.
     
  3. Later, to stop a started cluster, click the **Terminate** link in the
     cluster status frame.
     
F. Testing the GPU Cluster
----------------------------
  

1. Start the cluster and add an execute node
::

  $ cyclecloud show_cluster
  --------------------
  TensorFlowDemo : off
  --------------------
  Keypair: cyclecloud
  Cluster nodes:
      master: off
  Total nodes: 1

  $ cyclecloud start_cluster TensorFlowDemo
  Starting cluster TensorFlowDemo....
  ------------------------
  TensorFlowDemo : started
  ------------------------
  Keypair: cyclecloud
  Cluster nodes:
      master: Launching on-demand instances
  Total nodes: 1

  $ cyclecloud add_node TensorFlowDemo -t execute -c 1
  Adding nodes to cluster TensorFlowDemo....
  ------------------------
  TensorFlowDemo : started
  ------------------------
  Keypair: cyclecloud
  Cluster nodes:
      master:  Awaiting software installation i-003c640793966f691 ec2-54-235-54-155.compute-1.amazonaws.com (10.0.0.195)
  Cluster node arrays:
       execute: 1 instances, 2 cores, Allocation (Launching on-demand instances)
  Total nodes: 2
  

2. Connect to the execute node after it has converged 
::

  $ cyclecloud connect -c TensorFlowDemo execute-1
    
  nnecting to instance i-07216ffa13fc69d6e via SSH to ec2-52-90-232-221.compute-1.amazonaws.com as cyclecloud
  Warning: Permanently added 'ec2-52-90-232-221.compute-1.amazonaws.com,52.90.232.221' (RSA) to the list of known hosts.
  Last login: Mon Mar 27 21:06:12 2017 from 107.15.243.183

   __        __  |    ___       __  |    __         __|
  (___ (__| (___ |_, (__/_     (___ |_, (__) (__(_ (__|
          |

  Cluster: TensorFlowDemo
  Version: 6.5.3
  Run List: recipe[cyclecloud], role[sge_execute_role], recipe[cluster_init]


3.Ensure Driver and CUDA files are in place
::

  $ lsmod | grep -i nvidia
  $ cd /nvidia-files/

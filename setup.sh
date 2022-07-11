# LT 10/06/2022

## This script
# * sets up the RAID0 array 
# * builds the disk image: installs Intel MKL, builds and installs R

## TODO: separate the image buiding part, keep the RAID0 setup separated


sudo apt update

# create RAID 0 array
sudo apt install mdadm
# 2 drives
sudo mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/nvme0n1 /dev/nvme0n2
# for n drives, list them all.

# create filesystem, mount it and set auto-mount
sudo mkfs.ext4 -F /dev/md0
sudo mkdir -p /mnt/disks/ssd
sudo mount /dev/md0 /mnt/disks/ssd
sudo chmod a+w /mnt/disks/ssd
echo UUID=`sudo blkid -s UUID -o value /dev/md0` /mnt/disks/ssd ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab

# install wget
sudo apt install wget

# download the key to system keyring
wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null

# add signed entry to apt sources and configure the APT client to use Intel repository:
echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list

# update package list
sudo apt update

# install Intel MKL
sudo apt install intel-basekit

# install R build dependencies
sudo apt-get build-dep r-base

# download R source
export R_VERSION=4.2.0
curl -O https://cran.r-project.org/src/base/R-4/R-${R_VERSION}.tar.gz
tar -xzvf R-${R_VERSION}.tar.gz
cd R-${R_VERSION}

# get ready to build R with MKL
source /opt/intel/oneapi/setvars.sh intel64

MKL="-Wl,--no-as-needed -lmkl_gf_lp64 -Wl,--start-group -lmkl_gnu_thread  -lmkl_core  -Wl,--end-group -fopenmp  -ldl -lpthread -lm"

./configure \
    --prefix=/opt/R/${R_VERSION} \
    --enable-memory-profiling \
    --enable-R-shlib \
    --with-blas="$MKL" \
    --with-lapack

make
sudo make install
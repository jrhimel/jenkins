#!/bin/bash

#Variables for device (Edit according to your choices)
device=violet 			#For which device want to build
variant=userdebug 		#user/userdebug/eng

dt=https://github.com/CorvusRom-Devices/device_xiaomi_violet.git
dt_branch=10 			#Dt branch to use for build
dt_clone_location=device/xiaomi/violet

kt=https://github.com/DerpFest-Devices/kernel_xiaomi_sm6150.git
kt_branch=ten 			#Kernel branch to use for build
kt_clone_location=kernel/xiaomi/sm6150

vt=https://gitlab.com/ShivamKumar2002/vendor_xiaomi_violet.git
vt_branch=ten			#Vendor branch to use for build
vt_clone_location=vendor/xiaomi/violet

gapps_or_vanilla=vanilla	#gapps/vanilla
lunch_or_brunch=lunch 		#lunch/brunch
make_type=none			#none/installclean



#Do not touch below lines if you are using Apon77's jenkins.
rom_dir=~/corvus		#Space is not allowed(~ is home directory)
ccache_dir=~/corvus_ccache/$device 	#Space is not allowed
max_ccache=30G			 #30G is enough for  one divice



#Enough, no more variable except repo init url. So, no need to touch.
mkdir -p $rom_dir 		#Creates rom folder if not exists
cd $rom_dir			#Enters into rom folder
repo init -u https://github.com/Corvus-ROM/android_manifest.git -b 10
repo sync -j$(nproc --all) --force-sync --no-tags --no-clone-bundle
export USE_CCACHE=1
export CCACHE_DIR=$ccache_dir
export CCACHE_EXEC=$(which ccache)
export CCACHE_MAXSIZE=$max_ccache

#Clone dt,kt,vt(fetch & checkout to variable branch if already folder exists)

if [ -d "$dt_clone_location" ]
then
    cd $dt_clone_location
    git remote add jenkins_temp $dt
    git fetch jenkins_temp
    git checkout jenkins_temp/$dt_branch
    git remote remove jenkins_temp
    cd $rom_dir
else
    git clone $dt -b $dt_branch $dt_clone_location
fi

if [ -d "$kt_clone_location" ]
then
    cd $kt_clone_location
    git remote add jenkins_temp $kt
    git fetch jenkins_temp
    git checkout jenkins_temp/$kt_branch
    git remote remove jenkins_temp
    cd $rom_dir
else
    git clone $kt -b $kt_branch $kt_clone_location
fi

if [ -d "$vt_clone_location" ]
then
    cd $vt_clone_location
    git remote add jenkins_temp $vt
    git fetch jenkins_temp
    git checkout jenkins_temp/$vt_branch
    git remote remove jenkins_temp
    cd $rom_dir
else
    git clone $vt -b $vt_branch $vt_clone_location
fi



# Set up environment
cd $rom_dir
. build/envsetup.sh


# Choose a target and lunch
if [ "$lunch_or_brunch" == "brunch" ]
then
    brunch du_$device-$variant
else
    lunch du_$device-$variant
fi


# Build the ROM
if [ "$make_type" == "none" ]
then
  make -j$(nproc --all) corvus
elif [ "$make_type" == "installclean" ]
  make installclean
  make -j$(nproc --all) corvus
fi

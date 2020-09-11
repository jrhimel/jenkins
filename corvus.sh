#!/bin/bash

#Variables for device (Edit according to your choices)
trigger_no=1
device=santoni 			#For which device want to build
variant=userdebug 		#user/userdebug/eng

dt=https://github.com/jrhimel/new.git
dt_branch=10 		#Dt branch to use for build
dt_clone_location=device/xiaomi/santoni

kt=https://github.com/Bikram557/android_kernel_xiaomi_santoni_msm4.9.git
kt_branch=ten 		#Kernel branch to use for build
kt_clone_location=kernel/xiaomi/msm8937

vt=https://github.com/Bikram557/android_vendor_xiaomi_santoni.git
vt_branch=quartz		#Vendor branch to use for build
vt_clone_location=vendor/xiaomi

gapps_or_vanilla=vanilla	#gapps/vanilla
lunch_or_brunch=lunch 		#lunch/brunch
make_type=none			#none/installclean
timezone=Asia/Dhaka		#Select which timezone you live :D


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
export TZ=$timezone

if [ "$gapps_or_vanilla" == "gapps" ]
then
    export USE_GAPPS=true
else
    export USE_GAPPS=false
fi


#Remove problematic existing kernel dirs
rm -rf kernel/realme/sm6150
rm -rf kernel/xiaomi/sm6150



#Clone dt,kt,vt(fetch & force checkout to variable branch if already folder exists)

if [ -d "$dt_clone_location" ]
then
    cd $dt_clone_location
    git remote add jenkins_temp $dt
    git fetch jenkins_temp
    git checkout -f jenkins_temp/$dt_branch
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
    git checkout -f jenkins_temp/$kt_branch
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
    git checkout -f jenkins_temp/$vt_branch
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
fi
if [ "$make_type" == "installclean" ]
then
  make installclean
  make -j$(nproc --all) corvus
fi

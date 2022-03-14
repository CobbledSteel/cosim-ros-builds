#!/bin/bash
# set -x

# This is an example of the sort of thing you might want to do in an init script.
# Note that this script will be run exactly once on your image in qemu. 

# Note: you will see a bunch of fedora boot messages and possibly even a login
# prompt while building as this script runs. Don't worry about the login promt,
# your script is running in the background.

# In this case, we will use fedora's package manager to install something (the
# full-featured 'time' command to replace the shell builtin). We also use pip
# to install a python package used by one of the benchmarks. You can also
# download stuff, compile things that don't support cross-compilation, and/or
# configure your system in this script.

# Note that we call poweroff at the end. This is recomended because this script
# will be run automatically during the build process. If you leave it off, the
# build script will wait for you to interact with the booted image and shut
# down before it continues (which might be useful when debugging a workload).

dnf update -y
dnf install -y gcc-c++ python3-rosdep python3-rosinstall_generator python3-vcstool @buildsys-build
dnf install -y wget
dnf install -y cmake
# dnf install -y python3-empy
# dnf install -y boost-devel
rosdep init
rosdep update
# wget https://pari.math.u-bordeaux.fr/pub/pari/unix/pari-2.13.1.tar.gz
# tar -xvf pari-2.13.1.tar.gz
# cd pari-2.13.1/
# ./Configure
# make all
# make install
# cd ..
# dnf install -y libsvm fcgi ffcall libglade2 libpq
# wget http://fedora.riscv.rocks/kojifiles/packages/clisp/2.49.93/14.c26de78git.fc33/riscv64/clisp-2.49.93-14.c26de78git.fc33.riscv64.rpm
# rpm -i clisp-2.49.93-14.c26de78git.fc33.riscv64.rpm --nodeps
# git clone git://git.code.sf.net/p/sbcl/sbcl
# cd sbcl
# sh make.sh /usr/bin/clisp
# sh install.sh
# cd ..
mkdir ~/ros_catkin_ws
cd ~/ros_catkin_ws
rosinstall_generator ros_comm --rosdistro noetic --deps --tar > noetic-comm.rosinstall
mkdir ./src
vcs import --input noetic-comm.rosinstall ./src
packages=("roslisp" "genlisp" "genlisp" "genlisp")
files=("noetic-comm.rosinstall" "noetic-comm.rosinstall" "src/catkin/test/network_tests/test.rosinstall" "src/catkin/test/checks/test-nocatkin.rosinstall")
for i in ${!files[@]}; do
	cmd="awk '/${packages[$i]}/{for(x=NR-1;x<=NR+2;x++)d[x];}{a[NR]=\$0}END{for(i=1;i<=NR;i++)if(!(i in d))print a[i]}' ${files[$i]} > ${files[$i]}.temp && mv ${files[$i]}.temp ${files[$i]}"
	eval ${cmd}
done
sed -e s/genlisp//g -i src/message_generation/CMakeLists.txt
sed -e /sbcl/d -i src/roslisp/package.xml
rosdep install --from-paths ./src --ignore-packages-from-source --rosdistro noetic -y
./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release
poweroff

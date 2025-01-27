#!/bin/bash

# Software License Agreement (BSD License)
#
# Authors : Brighten Lee <shlee@roas.co.kr>
#
# Copyright (c) 2020, ROAS Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
#   1. Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#
#   2. Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
# THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
# AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
# THE POSSIBILITY OF SUCH DAMAGE.

helpFunction()
{
  echo "Usage: ./initial_setup -r <ros distro>"
  echo ""
  echo -e "  -r <ros distro>\tdefault=melodic"
  echo ""
  exit 1
}

ROS_DISTRO="melodic"

while getopts "r:h" opt
do
  case "$opt" in
    r) ROS_DISTRO="$OPTARG" ;;
    h) helpFunction ;;
    ?) helpFunction ;;
  esac
done


# Update repository and install dependencies
echo -e "\033[1;31mStarting PC setup ...\033[0m"
sudo apt update
sudo apt upgrade -y
sudo apt install -y curl ssh net-tools terminator chrony ntpdate vim git
sudo ntpdate ntp.ubuntu.com


# Install Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb -y


# Install ROS
echo -e "\033[1;31mStarting ROS $ROS_DISTRO installation ...\033[0m"
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo apt update
sudo apt install -y ros-$ROS_DISTRO-desktop-full

source /opt/ros/$ROS_DISTRO/setup.bash
sudo apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential python-rosdep ros-$ROS_DISTRO-rqt* ros-$ROS_DISTRO-ros-control ros-$ROS_DISTRO-ros-controllers ros-$ROS_DISTRO-navigation ros-$ROS_DISTRO-serial ros-$ROS_DISTRO-rosserial-*
sudo rosdep init
rosdep update


# Create the ROS enviornmnet file
if [ ! -f "$HOME/env.sh" ] && [ ! -f "/etc/ros/env.sh" ]; then
  echo -e "\nsource /etc/ros/env.sh" >> ~/.bashrc
fi

if [ -f "$HOME/env.sh" ]; then
 sudo rm $HOME/env.sh
fi

if [ -f "/etc/ros/env.sh" ]; then
 sudo rm /etc/ros/env.sh
fi

echo -e "#!/bin/bash

# Please write the ROS environment variables here

source /opt/ros/$ROS_DISTRO/setup.bash
source ~/catkin_ws/devel/setup.bash

export ROS_MASTER_URI=http://localhost:11311" >> $HOME/env.sh

sudo mv $HOME/env.sh /etc/ros/


# Create the ROS workspace
if [ ! -d "$HOME/catkin_ws" ]; then
  echo -e "\033[1;31mCreating ROS workspace ...\033[0m"
  mkdir -p ~/catkin_ws/src
  cd ~/catkin_ws/src
  catkin_init_workspace
  cd ~/catkin_ws
  catkin_make
fi


# ROS realsense camera package
sudo apt install -y ros-$ROS_DISTRO-realsense2-camera

# syntax=docker/dockerfile:experimental
FROM nvidia/cudagl:10.0-devel-ubuntu18.04
# FROM nvidia/cuda:10.0-devel-ubuntu18.04

ARG DEBIAN_FRONTEND=noninteractive
ARG UBUNTU_RELEASE=bionic

WORKDIR /usr/local

# cuDNN
# RUN --mount=type=bind,source=Installers/Nvidia/,target=/usr/local/Installers/Nvidia/ \
#     dpkg -i Installers/Nvidia/libcudnn7*

# TensorRT
# RUN --mount=type=bind,source=Installers/Nvidia/,target=/usr/local/Installers/Nvidia/ \
#     dpkg -i Installers/Nvidia/nv-tensorrt-repo-ubuntu1804-cuda10.0-trt7.0.0.11-ga-20191216_1-1_amd64.deb

# RUN apt-key add /var/nv-tensorrt-repo-cuda10.0-trt7.0.0.11-ga-20191216/7fa2af80.pub
# RUN apt-key add /var/nv-tensorrt-repo-cuda10.0-trt7.0.0.11-ga-20191216/*.pub

RUN rm /etc/apt/sources.list.d/nvidia-ml.list

# RUN apt-get update
RUN apt-get update --allow-insecure-repositories --allow-unauthenticated

# RUN apt-get install -y libnvinfer7=7.0.0-1+cuda10.0 libnvonnxparsers7=7.0.0-1+cuda10.0 libnvparsers7=7.0.0-1+cuda10.0 libnvinfer-plugin7=7.0.0-1+cuda10.0 libnvinfer-dev=7.0.0-1+cuda10.0 libnvonnxparsers-dev=7.0.0-1+cuda10.0 libnvparsers-dev=7.0.0-1+cuda10.0 libnvinfer-plugin-dev=7.0.0-1+cuda10.0  python3-libnvinfer=7.0.0-1+cuda10.0
# RUN apt-mark hold libnvinfer7 libnvonnxparsers7 libnvparsers7 libnvinfer-plugin7 libnvinfer-dev libnvonnxparsers-dev libnvparsers-dev libnvinfer-plugin-dev python3-libnvinfer python3-libnvinfer-dev

#RUN apt-get install -y tensorrt

# ROS
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $UBUNTU_RELEASE main" > /etc/apt/sources.list.d/ros-latest.list'

RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get update --allow-insecure-repositories --allow-unauthenticated && \
    apt-get install -y ros-melodic-desktop-full

RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential && \
    rosdep init && \
    rosdep update

RUN apt-get install -y python-pip && \
    pip install catkin_tools

# Gazebo Update
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable $UBUNTU_RELEASE main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN curl https://packages.osrfoundation.org/gazebo.key | apt-key add
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get update --allow-insecure-repositories --allow-unauthenticated && \
    apt-get install -y gazebo9

# MISC ROS
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get upgrade -y libignition-math2
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get install -y ros-melodic-tf2-sensor-msgs libgoogle-glog-dev ros-melodic-effort-controllers ros-melodic-position-controllers

# CMake
RUN mkdir -p /usr/local/Installers/CMake
WORKDIR /usr/local/Installers/CMake
RUN --mount=type=bind,source=Installers/CMake/,target=/usr/local/Installers/CMake/ \
    sh ./install_cmake.sh
WORKDIR /usr/local

ENV PATH=/opt/cmake/bin${PATH:+:${PATH}}

# OpenCV
RUN mkdir -p /usr/local/Installers/OpenCV
WORKDIR /usr/local/Installers/OpenCV
RUN --mount=type=bind,source=Installers/OpenCV/,target=/usr/local/Installers/OpenCV/,rw \
    sh ./opencv_build.sh
WORKDIR /usr/local

# Pylon
RUN --mount=type=bind,source=Installers/Pylon/,target=/usr/local/Installers/Pylon/ \
    apt-get install -y ./Installers/Pylon/pylon_6.1.1.19861-deb0_amd64.deb
RUN echo "source /opt/pylon/bin/pylon-setup-env.sh /opt/pylon" >> ~/.bashrc

# tkDNN
# RUN --mount=type=bind,source=Installers/tkDNN/,target=/usr/local/Installers/tkDNN/,rw \
#     cd /usr/local/Installers/tkDNN && \
#     sh ./install_tkDNN.sh

# Cleanup
RUN rm -r -f Installers && \
    ldconfig

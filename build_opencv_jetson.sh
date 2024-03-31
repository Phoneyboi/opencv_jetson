#!/usr/bin/env bash
# Enhanced script for building OpenCV on the Jetson platform

set -e

# Constants
PREFIX=/usr/local
CPUS=$(nproc)
JOBS=$((CPUS > 5 ? CPUS : 1))
BUILD_DIR=/tmp/build_opencv
readonly DEFAULT_VERSION=4.9.0  # Set your desired OpenCV version here

# Functions
cleanup() {
    echo "Cleaning up temporary build files..."
    rm -rf "$BUILD_DIR"
}

setup() {
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
}

git_source() {
    local version=$1
    echo "Cloning OpenCV and OpenCV Contrib repositories (version $version)..."
    git clone --depth 1 --branch "$version" https://github.com/opencv/opencv.git
    git clone --depth 1 --branch "$version" https://github.com/opencv/opencv_contrib.git
}

install_dependencies() {
    echo "Installing build dependencies..."
    sudo apt-get update
    sudo apt-get dist-upgrade -y --autoremove
    sudo apt-get install -y \
        build-essential \
        cmake \
        git \
        gfortran \
        libatlas-base-dev \
        libavcodec-dev \
        libavformat-dev \
        libavresample-dev \
        libcanberra-gtk3-module \
        libdc1394-22-dev \
        libeigen3-dev \
        libglew-dev \
        libgstreamer-plugins-base1.0-dev \
        libgstreamer-plugins-good1.0-dev \
        libgstreamer1.0-dev \
        libgtk-3-dev \
        libjpeg-dev \
        libjpeg8-dev \
        libjpeg-turbo8-dev \
        liblapack-dev \
        liblapacke-dev \
        libopenblas-dev \
        libpng-dev \
        libpostproc-dev \
        libswscale-dev \
        libtbb-dev \
        libtbb2 \
        libtesseract-dev \
        libtiff-dev \
        libv4l-dev \
        libxine2-dev \
        libxvidcore-dev \
        libx264-dev \
        pkg-config \
        python-dev \
        python-numpy \
        python3-dev \
        python3-numpy \
        python3-matplotlib \
        qv4l2 \
        v4l-utils \
        zlib1g-dev
}

configure() {
    local version=$1
    echo "Configuring OpenCV build (version $version)..."
    cd "$BUILD_DIR/opencv"
    mkdir -p build
    cd build
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=$PREFIX \
          -D OPENCV_EXTRA_MODULES_PATH="$BUILD_DIR/opencv_contrib/modules" \
          -D BUILD_EXAMPLES=OFF \
          -D BUILD_TESTS=OFF \
          -D BUILD_PERF_TESTS=OFF \
          -D WITH_CUDA=ON \
          -D WITH_CUDNN=ON \
          -D CUDA_ARCH_BIN=5.3,6.2,7.2,8.7 \
          -D CUDA_FAST_MATH=ON \
          -D WITH_CUBLAS=ON \
          -D WITH_LIBV4L=ON \
          -D WITH_GSTREAMER=ON \
          -D WITH_OPENGL=ON \
          -D OPENCV_DNN_CUDA=ON \
          -D ENABLE_FAST_MATH=1 \
          -D CUDA_FAST_MATH=1 \
          -D WITH_CUBLAS=1 \
          ..
}

build() {
    echo "Building OpenCV..."
    make -j"$JOBS"
}

install() {
    echo "Installing OpenCV..."
    sudo make install
}

verify_installation() {
    echo "Verifying OpenCV installation..."
    python3 -c "import cv2; print('OpenCV version:', cv2.__version__)"
}

main() {
    setup
    install_dependencies
    VERSION=${DEFAULT_VERSION}
    git_source "$VERSION"
    configure "$VERSION"
    build
    install
    verify_installation
    cleanup
}

main "$@"

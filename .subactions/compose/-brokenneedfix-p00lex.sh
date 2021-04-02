#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Copyright (c) 2020, MrDoob
# All rights reserved.
####################################
typed=plex
  container=$($(command -v docker) ps -aq --format '{{.Names}}' | grep -x ${typed})
  if [[ $container == ${typed} ]];then
     docker=${typed}
     for i in ${docker}; do
     $(command -v docker) exec $i bash -c "apt update -y"
     $(command -v docker) exec $i bash -c "apt -y install cmake pkg-config python ocl-icd-dev libegl1-mesa-dev ocl-icd-opencl-dev libdrm-dev libxfixes-dev libxext-dev llvm-7-dev clang-7 libclang-7-dev libtinfo-dev libedit-dev zlib1g-dev build-essential git"
     $(command -v docker) exec $i git clone --branch comet-lake https://github.com/rcombs/beignet.git
     $(command -v docker) exec $i bash -c "mkdir /beignet/build/ && cd /beignet/build && cmake -DLLVM_INSTALL_DIR=/usr/lib/llvm-7/bin .. && make -j8 && make install"
     done
  fi

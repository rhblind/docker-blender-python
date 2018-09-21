FROM        ubuntu:trusty

ENV         DEBIAN_FRONTEND noninteractive
ENV         BLENDER_INSTALL /usr/local/lib/python3.5/dist-packages
ENV         BLENDER_VERSION 2.79b

# Install build dependencies
RUN         apt-get update \
                && apt-get upgrade -y \
                && apt-get install -y --no-install-recommends \
                     software-properties-common \
                # Add PPA for Open Shading Language
                && add-apt-repository ppa:irie/openshadinglanguage \
                && apt-get update && apt-get install -y --no-install-recommends \
                    cmake build-essential python3.5-dev llvm-dev libx11-dev libxi-dev \
                    libsndfile1-dev libpng12-dev libjpeg-dev libfftw3-dev libopenexr-dev \
                    libopenjpeg-dev libopenal-dev libalut-dev libvorbis-dev libglu1-mesa-dev \
                    libsdl1.2-dev libfreetype6-dev libtiff5-dev libavdevice-dev libavformat-dev \
                    libavutil-dev libavcodec-dev libjack-dev libswscale-dev libx264-dev \
                    libmp3lame-dev libspnav-dev libtheora-dev libglew-dev libboost-all-dev \
                    libopenimageio-dev libopencolorio-dev libopenshadinglanguage-dev openshadinglanguage
RUN         apt-get purge -y --auto-remove \
                && rm -rf /var/lib/apt/lists/*

# Download, compile and install Blender
ADD         https://download.blender.org/source/blender-${BLENDER_VERSION}.tar.gz /usr/local/src/
RUN         tar zxf /usr/local/src/blender-${BLENDER_VERSION}.tar.gz -C /usr/local/src

WORKDIR     /usr/local/src/blender-${BLENDER_VERSION}/build
RUN         cmake -DCMAKE_INSTALL_PREFIX=${BLENDER_INSTALL} \
                -DWITH_PYTHON_INSTALL=OFF \
                -DWITH_PLAYER=OFF \
                -DWITH_PYTHON_MODULE=ON \
                -DCXXFLAGS=-std=c++11 .. \
            && make \
            && make install

# Download and install the glTF 2.0 exporter
ADD         https://github.com/KhronosGroup/glTF-Blender-Exporter/archive/master.tar.gz /usr/local/src
RUN         tar zxf /usr/local/src/master.tar.gz -C /usr/local/src \
                && cp -r /usr/local/src/glTF-Blender-Exporter-master/scripts/addons/io_scene_gltf2 \
                    ${BLENDER_INSTALL}/$(echo ${BLENDER_VERSION}|sed -e 's/[^0-9.]//g')/scripts/addons

# Keep image running while doing nothing
CMD         exec /bin/bash -c 'trap : TERM INT; sleep infinity & wait'

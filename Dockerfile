FROM ubuntu:disco

MAINTAINER Daniel Porto <daniel.porto@gmail.com>

RUN apt update && apt -y install \
                                # optional
                                vim \
                                # required for downloading external libraries
                                curl \ 
                                unzip \
                                # dependencies
                                git \
                                libopenal1\
                                libopenal-dev  \
                                libgl1-mesa-dev \
                                xorg-dev  \
                                libasound2-dev\
                                golang-1.12-go \
                                # cross compile for windows
                                tofrodos \
                                gcc-mingw-w64-i686 \
                                gcc-mingw-w64-x86-64 \
                                # cross compile for mac
                                clang-8 \
                                lldb-8 \
                                wget \
                                cmake


# cross compile mac dependencies
ENV OSXCROSS_SDK_VERSION 10.11
ENV OSXCROSS_SDK_URL https://github.com/apriorit/osxcross-sdks/raw/master/MacOSX${OSXCROSS_SDK_VERSION}.sdk.tar.xz

RUN ln -f -s /usr/bin/clang-8 /usr/bin/clang && ln -f -s /usr/bin/clang++-8 /usr/bin/clang++
RUN SDK_VERSION=$OSXCROSS_SDK_VERSION                           \
    mkdir /opt/osxcross &&                                      \
    cd /opt &&                                                  \
    git clone https://github.com/tpoechtrager/osxcross.git &&   \
    cd osxcross &&                                              \
    sed -i -e 's|-march=native||g' ./build_clang.sh ./wrapper/build.sh && \
    ./tools/get_dependencies.sh \
    && curl -L -o ./tarballs/MacOSX${OSXCROSS_SDK_VERSION}.sdk.tar.xz \
    ${OSXCROSS_SDK_URL} \
    && yes | PORTABLE=true ./build.sh &&                           \
    ./build_compiler_rt.sh


# cross compile windows dependencies
RUN cd /tmp \
         && curl -SLO https://kcat.strangesoft.net/openal-binaries/openal-soft-1.19.1-bin.zip \
         && unzip openal-soft-1.19.1-bin.zip \
         && mv /tmp/openal-soft-1.19.1-bin/include/AL /lib/gcc/x86_64-w64-mingw32/8.3-win32/include \
         && mv /tmp/openal-soft-1.19.1-bin/libs/Win64/libOpenAL32.dll.a /lib/gcc/x86_64-w64-mingw32/8.3-win32/libopenal32.dll.a \
         && mv /tmp/openal-soft-1.19.1-bin/bin/Win64/soft_oal.dll /lib/gcc/x86_64-w64-mingw32/8.3-win32/soft_oal.dll \
         && rm -rf openal-soft-1.19.1-bin.zip openal-soft-1.19.1-bin


# golang envs
ENV PATH=$PATH:/usr/lib/go-1.12/bin
ENV CGO_ENABLED=1

# mac cross compile envs
# ENV GOOS=darwin
# ENV GOARCH=amd64
# ENV CC=o64-clang 
# ENV CXX=o64-clang++
ENV PATH=$PATH:/opt/osxcross/target/bin

# windows crosscompile envs
# export CC=x86_64-w64-mingw32-gcc
# export CXX=x86_64-w64-mingw32-g++
CMD /bin/bash

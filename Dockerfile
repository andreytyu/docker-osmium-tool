FROM debian:jessie

MAINTAINER Andrey Tyukavin <geotyukavin@gmail.com>

ENV OSMIUM_VERSION 2.15.0
ENV OSMIUM_TOOL_VERSION 1.10.0

RUN apt-get update
RUN apt-get update && apt-get install -y \
    wget g++ cmake cmake-curses-gui make libexpat1-dev libgeos++-dev zlib1g-dev libbz2-dev libsparsehash-dev \
    libboost-program-options-dev libboost-dev libgdal-dev libproj-dev doxygen graphviz pandoc

RUN apt-get install -y git

RUN mkdir /var/install
WORKDIR /var/install

RUN git clone https://github.com/mapbox/protozero.git && \
    cd protozero && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make install

WORKDIR /var/install

RUN wget https://github.com/osmcode/libosmium/archive/v${OSMIUM_VERSION}.tar.gz && \
    tar xzvf v${OSMIUM_VERSION}.tar.gz && \
    rm v${OSMIUM_VERSION}.tar.gz && \
    mv libosmium-${OSMIUM_VERSION} libosmium

RUN wget https://github.com/osmcode/libosmium/archive/v${OSMIUM_VERSION}.tar.gz && \
    tar xzvf v${OSMIUM_VERSION}.tar.gz && \
    rm v${OSMIUM_VERSION}.tar.gz && \
    mv libosmium-${OSMIUM_VERSION} libosmium

RUN cd libosmium && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF .. && \
    make

RUN wget https://github.com/osmcode/osmium-tool/archive/v${OSMIUM_TOOL_VERSION}.tar.gz && \
    tar xzvf v${OSMIUM_TOOL_VERSION}.tar.gz && \
    rm v${OSMIUM_TOOL_VERSION}.tar.gz && \
    mv osmium-tool-${OSMIUM_TOOL_VERSION} osmium-tool

RUN cd osmium-tool && \
    mkdir build && cd build && \
    cmake -DOSMIUM_INCLUDE_DIR=/var/install/libosmium/include/ .. && \
    make

RUN mv /var/install/osmium-tool/build/src/osmium /usr/bin/osmium
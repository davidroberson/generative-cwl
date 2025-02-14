# Use Ubuntu 20.04 as a base image
FROM ubuntu:20.04

# Disable interactive frontend
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies: samtools, wget, build-essential and minimap2 dependencies
RUN apt-get update && apt-get install -y \
    samtools \
    wget \
    git \
    build-essential \
    zlib1g-dev \
    libncurses5-dev \
    libbz2-dev \
    liblzma-dev && \
    rm -rf /var/lib/apt/lists/*

# Install minimap2: clone repository and compile
RUN git clone --depth 1 https://github.com/lh3/minimap2.git && \
    cd minimap2 && make && \
    cp minimap2 /usr/local/bin/ && \
    cd .. && rm -rf minimap2


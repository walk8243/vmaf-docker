FROM centos:8

RUN dnf install autoconf automake bzip2 bzip2-devel cmake freetype-devel gcc gcc-c++ git libtool make mercurial pkgconfig zlib-devel -y

ARG BASE_DIR=/usr/local
ARG FFMPEG_BASE=${BASE_DIR}/ffmpeg
ARG FFMPEG_BIN=${BASE_DIR}/bin
ARG FFMPEG_BUILD=${FFMPEG_BASE}_build
ARG FFMPEG_SOURCE=${FFMPEG_BASE}_sources
RUN mkdir ${FFMPEG_SOURCE}

WORKDIR ${FFMPEG_SOURCE}

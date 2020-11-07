FROM centos:8

RUN dnf install autoconf automake bzip2 bzip2-devel cmake freetype-devel gcc gcc-c++ git libtool make mercurial pkgconfig zlib-devel -y

ARG BASE_DIR=/usr/local
ENV FFMPEG_BASE ${BASE_DIR}/ffmpeg
ENV FFMPEG_BIN ${BASE_DIR}/bin
ENV FFMPEG_BUILD ${FFMPEG_BASE}_build
ENV FFMPEG_SOURCE ${FFMPEG_BASE}_sources
RUN mkdir ${FFMPEG_SOURCE}

WORKDIR ${FFMPEG_SOURCE}

RUN curl -O -L https://www.nasm.us/pub/nasm/releasebuilds/2.14.02/nasm-2.14.02.tar.bz2 &&\
	tar xjvf nasm-2.14.02.tar.bz2 &&\
	cd nasm-2.14.02 &&\
	./autogen.sh &&\
	./configure --prefix="${FFMPEG_BUILD}" --bindir="${FFMPEG_BIN}" &&\
	make && make install

RUN curl -O -L https://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz &&\
	tar xzvf yasm-1.3.0.tar.gz &&\
	cd yasm-1.3.0 &&\
	./configure --prefix="${FFMPEG_BUILD}" --bindir="${FFMPEG_BIN}" &&\
	make && make install


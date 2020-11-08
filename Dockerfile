FROM centos:8

RUN dnf install autoconf automake bzip2 bzip2-devel cmake diffutils freetype-devel gcc gcc-c++ git libtool make mercurial pkgconfig zlib-devel -y

ARG BASE_DIR=/usr/local
ENV FFMPEG_BASE ${BASE_DIR}/ffmpeg
ENV FFMPEG_BIN ${BASE_DIR}/bin
ENV FFMPEG_BUILD ${FFMPEG_BASE}_build
ENV FFMPEG_SOURCE ${FFMPEG_BASE}_sources
RUN mkdir ${FFMPEG_SOURCE}

WORKDIR ${FFMPEG_SOURCE}

# アセンブラ周りのライブラリ
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

# H.264
RUN git clone --depth 1 https://code.videolan.org/videolan/x264.git &&\
	cd x264 &&\
	PKG_CONFIG_PATH="${FFMPEG_BUILD}/lib/pkgconfig" ./configure --prefix="${FFMPEG_BUILD}" --bindir="${FFMPEG_BIN}" --enable-static &&\
	make && make install

# H.265
RUN hg clone http://hg.videolan.org/x265 &&\
	cd x265/build/linux &&\
	cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${FFMPEG_BUILD}" -DENABLE_SHARED:bool=off ../../source &&\
	make && make install

# その他のライブラリ
RUN git clone --depth 1 https://github.com/mstorsjo/fdk-aac &&\
	cd fdk-aac &&\
	autoreconf -fiv &&\
	./configure --prefix="${FFMPEG_BUILD}" --disable-shared &&\
	make && make install
RUN curl -O -L https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz &&\
	tar xzvf lame-3.100.tar.gz &&\
	cd lame-3.100 &&\
	./configure --prefix="${FFMPEG_BUILD}" --bindir="${FFMPEG_BIN}" --disable-shared --enable-nasm &&\
	make && make install
RUN curl -O -L https://archive.mozilla.org/pub/opus/opus-1.3.1.tar.gz &&\
	tar xzvf opus-1.3.1.tar.gz &&\
	cd opus-1.3.1 &&\
	./configure --prefix="${FFMPEG_BUILD}" --disable-shared &&\
	make && make install
RUN git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git &&\
	cd libvpx &&\
	./configure --prefix="${FFMPEG_BUILD}" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm &&\
	make && make install

RUN curl -O -L https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 &&\
	tar xjvf ffmpeg-snapshot.tar.bz2

# VMAFのインストール
RUN dnf install python38 python38-devel python38-libs python38-pip -y &&\
	pip3 install meson cython numpy ninja &&\
	git clone --depth 1 https://github.com/Netflix/vmaf.git &&\
	cd vmaf &&\
	make &&\
	pip3 install -r python/requirements.txt &&\
	cd libvmaf &&\
	ninja -vC build install &&\
	ln -s /usr/local/lib64/pkgconfig/libvmaf.pc ${FFMPEG_BUILD}/lib/pkgconfig/libvmaf.pc

RUN cd ffmpeg &&\
	PKG_CONFIG_PATH="${FFMPEG_BUILD}/lib/pkgconfig" ./configure --prefix="${FFMPEG_BUILD}" --pkg-config-flags="--static" --extra-cflags="-I${FFMPEG_BUILD}/include" --extra-ldflags="-L${FFMPEG_BUILD}/lib" --extra-libs=-lpthread --extra-libs=-lm --bindir="${FFMPEG_BIN}" --enable-gpl --enable-libfdk_aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvpx --enable-libx264 --enable-libx265 --enable-libvmaf --enable-nonfree &&\
	make && make install

# ffmpeg本体
# RUN curl -O -L https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 &&\
# 	tar xjvf ffmpeg-snapshot.tar.bz2 &&\
# 	cd ffmpeg &&\
# 	PKG_CONFIG_PATH="${FFMPEG_BUILD}/lib/pkgconfig" ./configure --prefix="${FFMPEG_BUILD}" --pkg-config-flags="--static" --extra-cflags="-I${FFMPEG_BUILD}/include" --extra-ldflags="-L${FFMPEG_BUILD}/lib" --extra-libs=-lpthread --extra-libs=-lm --bindir="${FFMPEG_BIN}" --enable-gpl --enable-libfdk_aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvpx --enable-libx264 --enable-libx265 --enable-nonfree &&\
# 	make && make install
# RUN hash -d ffmpeg

# WORKDIR ${BASE_DIR}
# RUN rm -rf ${FFMPEG_SOURCE}

# Toolchain for DXXRebirth. DXX-Rebirth needs gcc 14 (C++23) and Python 3.10
# for its SConstruct, which the hybrid toolchain (Debian bullseye: gcc 10,
# Python 3.9) does not have. This image has both, and a gcc 14 cross compiler
# built against the C library of the hybrid toolchain (glibc 2.31, as on the
# MiSTer), so the binary and the libstdc++ linked into it need nothing newer.
#
# Built by build.sh after the hybrid toolchain image (mister-hybrid-tc).
FROM mister-hybrid-tc AS hybrid

FROM debian:trixie
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        gcc g++ libc6-dev binutils-arm-linux-gnueabihf \
        make cmake scons python3 pkg-config curl ca-certificates xz-utils gawk m4 perl file \
        libgmp-dev libmpfr-dev libmpc-dev \
    && rm -rf /var/lib/apt/lists/*

# The MiSTer's C library and headers as a sysroot. The linker scripts name
# the libraries by their path in the hybrid toolchain. Its gcc 10 runtime is
# left out.
COPY --from=hybrid /usr/arm-linux-gnueabihf/include /opt/mister-sysroot/usr/include
COPY --from=hybrid /usr/arm-linux-gnueabihf/lib /opt/mister-sysroot/usr/lib
RUN cd /opt/mister-sysroot \
    && ln -s usr/lib lib \
    && rm -rf usr/include/c++ usr/lib/libstdc++* usr/lib/libgcc_s* usr/lib/libatomic* usr/lib/libgomp* \
        usr/lib/libasan* usr/lib/libubsan* \
    && for f in usr/lib/*.so; do \
        if file -L "$f" | grep -q text; then sed -i 's|/usr/arm-linux-gnueabihf/lib/|/usr/lib/|g' "$f"; fi; \
    done

# Same defaults as Debian's cross compiler in the hybrid toolchain
RUN mkdir /tmp/gcc && cd /tmp/gcc \
    && curl -fsSL -o gcc.tar.xz https://ftp.gnu.org/gnu/gcc/gcc-14.3.0/gcc-14.3.0.tar.xz \
    && echo "e0dc77297625631ac8e50fa92fffefe899a4eb702592da5c32ef04e2293aca3a  gcc.tar.xz" | sha256sum -c - \
    && tar -xf gcc.tar.xz && mkdir build && cd build \
    && ../gcc-14.3.0/configure --prefix=/opt/gcc-mister --target=arm-linux-gnueabihf \
        --with-sysroot=/opt/mister-sysroot --enable-languages=c,c++ \
        --with-arch=armv7-a --with-fpu=vfpv3-d16 --with-float=hard --with-mode=thumb \
        --disable-multilib --disable-nls --disable-bootstrap --disable-werror \
        --disable-libsanitizer --disable-libgomp --disable-libitm --disable-libquadmath \
        --disable-libssp --disable-libvtv \
        --enable-checking=release --enable-threads=posix --enable-libstdcxx-time=yes \
        --with-default-libstdcxx-abi=new \
    && make -j"$(nproc)" > /tmp/gcc/build.log 2>&1 || { tail -50 /tmp/gcc/build.log; exit 1; } \
    && make install-strip > /dev/null \
    && cd / && rm -rf /tmp/gcc
# gcc looks for the binutils next to its own files
RUN mkdir -p /opt/gcc-mister/arm-linux-gnueabihf/bin \
    && for t in ar as ld ld.bfd nm objcopy objdump ranlib readelf strip; do \
        ln -s /usr/bin/arm-linux-gnueabihf-$t /opt/gcc-mister/arm-linux-gnueabihf/bin/$t; \
    done
# The game's version carries its git revision
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*
ENV PATH=/opt/gcc-mister/bin:$PATH
WORKDIR /src

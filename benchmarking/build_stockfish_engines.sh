#!/bin/zsh

##################################################################################
# usage: build_stockfish_engines.sh
#
# For reference, taken from Makefile:
# Supported architectures:
#
# x86-64-vnni512          > x86 64-bit with vnni support 512bit wide
# x86-64-vnni256          > x86 64-bit with vnni support 256bit wide
# x86-64-avx512           > x86 64-bit with avx512 support
# x86-64-avxvnni          > x86 64-bit with avxvnni support
# x86-64-bmi2             > x86 64-bit with bmi2 support
# x86-64-avx2             > x86 64-bit with avx2 support
# x86-64-sse41-popcnt     > x86 64-bit with sse41 and popcnt support
# x86-64-modern           > common modern CPU, currently x86-64-sse41-popcnt
# x86-64-ssse3            > x86 64-bit with ssse3 support
# x86-64-sse3-popcnt      > x86 64-bit with sse3 and popcnt support
# x86-64                  > x86 64-bit generic (with sse2 support)
# x86-32-sse41-popcnt     > x86 32-bit with sse41 and popcnt support
# x86-32-sse2             > x86 32-bit with sse2 support
# x86-32                  > x86 32-bit generic (with mmx and sse support)
# ppc-64                  > PPC 64-bit
# ppc-32                  > PPC 32-bit
# armv7                   > ARMv7 32-bit
# armv7-neon              > ARMv7 32-bit with popcnt and neon
# armv8                   > ARMv8 64-bit with popcnt and neon
# e2k                     > Elbrus 2000
# apple-silicon           > Apple silicon ARM64
# general-64              > unspecified 64-bit
# general-32              > unspecified 32-bit
#
# Supported compilers:
#
# gcc                     > Gnu compiler (default)
# mingw                   > Gnu compiler with MinGW under Windows
# clang                   > LLVM Clang compiler
# icc                     > Intel compiler
# ndk                     > Google NDK to cross-compile for Android
##################################################################################

VERSION=`git rev-parse --short HEAD`

# Potential architecture values to pass to `make`
# x86-64-avxvnni does not currently build and so it is skipped
# non-x86-64 are all skipped
ARCHS=(x86-64-vnni512 x86-64-vnni256 x86-64-avx512 x86-64-bmi2 x86-64-avx2 x86-64-sse41-popcnt x86-64-modern x86-64-ssse3 x86-64-sse3-popcnt x86-64)

# these are the only two compilers available to me
COMPILERS=(gcc clang)

for arch in $ARCHS; do
	for compiler in $COMPILERS; do
		echo -e "Compiling $arch using $compiler"
		make -j16 profile-build ARCH=$arch COMP=$compiler
		mv stockfish stockfish-$VERSION-$arch-$compiler
		make clean
	done
done


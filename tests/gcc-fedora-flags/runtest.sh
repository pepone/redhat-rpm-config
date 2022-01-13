#!/bin/bash

set -ex

default_cflags=$(rpm -E '%{build_cflags}')
default_cxxflags=$(rpm -E '%{build_cxxflags}')
default_ldflags=$(rpm -E '%{build_ldflags}')

cflags=$(rpm -D '%toolchain gcc' -E '%{build_cflags}')
cxxflags=$(rpm -D '%toolchain gcc' -E '%{build_cxxflags}')
ldflags=$(rpm -D '%toolchain gcc' -E '%{build_ldflags}')

test "$default_cflags" = "$cflags"
test "$default_cxxflags" = "$cxxflags"
test "$default_ldflags" = "$ldflags"

gcc $cflags -o hello.o -c hello.c
annocheck hello.o
gcc $cflags -o main.o -c main.c
gcc $ldflags -o hello main.o hello.o
annocheck hello
./hello | grep "Hello World"

g++ $cxxflags -o hello-cpp.o -c hello.cpp
annocheck hello-cpp.o
g++ $cxxflags -o main-cpp.o -c main.cpp
g++ $ldflags -o hello-cpp main-cpp.o hello-cpp.o
annocheck hello-cpp
./hello-cpp | grep "Hello World"

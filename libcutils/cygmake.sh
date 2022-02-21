#!/bin/bash
set -x -e
CC=clang
CPP=clang++
AR=ar
STRIP=strip
CFLAGS=-static

$CC $CFLAGS -stdlib=libc++ -I./include -I../base/include -I../liblog/include -c -D_GNU_SOURCE \
"hashmap.cpp" \
"multiuser.cpp" \
"ashmem-host.cpp" \
"config_utils.cpp" \
"canned_fs_config.cpp" \
"iosched_policy.cpp" \
"load_file.cpp" \
"native_handle.cpp" \
"record_stream.cpp" \
"strlcpy.c" \
"fs_config.cpp" \
"threads.cpp" 
ar rcs ../libs/libcutils.a *.o
rm -f *.o
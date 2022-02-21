#!/bin/bash
set -x -e
CC=clang
CPP=clang++
AR=ar
STRIP=strip
CFLAGS="-static"

$CPP -std=c++17 -stdlib=libc++ $CFLAGS -I../libcutils/include -Iinclude -I../base/include -D__linux__ -DLIBLOG_LOG_TAG=1006 -DSNET_EVENT_LOG_TAG=1397638484 "-includedeftype.h" -static -c \
log_event_list.cpp log_event_write.cpp logger_name.cpp logger_read.cpp logger_write.cpp logprint.cpp properties.cpp
$AR rcs ../libs/liblog.a *.o
rm -f *.o

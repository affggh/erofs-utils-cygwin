#!/bin/bash
set -x -e
CC=clang
CPP=clang++
AR=ar
STRIP=strip
CFLAGS="-static"

$CC $CFLAGS -I./include -I./lib -c lib/uuid/clear.c \
	lib/uuid/compare.c \
	lib/uuid/copy.c \
	lib/uuid/gen_uuid.c \
	lib/uuid/isnull.c \
	lib/uuid/pack.c \
	lib/uuid/parse.c \
	lib/uuid/unpack.c \
	lib/uuid/unparse.c \
	lib/uuid/uuid_time.c
$AR rcs ../libs/libext2_uuid.a *.o
rm -f *.o

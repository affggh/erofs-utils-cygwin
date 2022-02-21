#!/bin/bash
set -x -e
mkdir -p libs bin
CC=clang
CPP=clang++
AR=ar
STRIP=strip
author=affggh
build=cygwin64
MAKE=make

USECUSTOM_VERSION=true

# Not use on windows
#
#    -DHAVE_LINUX_TYPES_H 
#    -DHAVE_FALLOCATE
#
# End

CFLAGS="
    -Wall 
    -Werror 
    -Wno-ignored-qualifiers 
    -Wno-pointer-arith 
    -Wno-unused-parameter 
    -Wno-unused-function  
    -DHAVE_LIBSELINUX 
    -DHAVE_LIBUUID 
    -DLZ4_ENABLED 
    -DLZ4HC_ENABLED 
    -DWITH_ANDROID "

if [ "$USECUSTOM_VERSION"=="true" ]; then
PACKAGE_VERSION="#define PACKAGE_VERSION \"$(sed -n '1p' VERSION | tr -d '\n')-${author}-${build}\""
else
PACKAGE_VERSION=`sed -n '1p' VERSION | tr -d '\n' | sed 's/\\(.*\\)/#define PACKAGE_VERSION \"\\1\"/'`
fi

echo -e "${PACKAGE_VERSION}" > erofs-utils-version.h
CFLAGS="${CFLAGS} -includeerofs-utils-version.h"

static_library() {
# liberofs.a
$CC ${CFLAGS} -I./include -I./include/erofs -I./libselinux/include -I./base/include -I./libcutils/include -c lib/*.c
$AR rcs libs/liberofs.a *.o
rm -f *.o

# libbase.a
cd base
./cygmake.sh
cd ..

# libselinux.a
cd libselinux
./cygmake.sh
cd ..

# liblz4.a
cd lz4
$MAKE -j$(nproc --all) liblz4.a
mv lib/liblz4.a ../libs/liblz4.a
cd ..

# liblog.a
cd liblog
./cygmake.sh
cd ..

# libcutils.a
cd libcutils
./cygmake.sh
cd ..

# libext2_uuid.a
cd e2fsprogs
./cygmake.sh
cd ..

# libpcre2.a
# cd pcre2
# ./cygmake.sh
# cd ..
}

executable_binarys() {
# mkfs.erofs
$CC ${CFLAGS} \
 -I./include \
 -I./include/erofs \
 -I./libselinux/include \
 -I./base/include \
 -I./libcutils/include \
 -I./e2fsprogs/lib/uuid \
 -c mkfs/main.c
 
 $CPP ${CFLAGS} -stdlib=libc++ -o \
  bin/mkfs.erofs.exe main.o \
 -Llibs \
 -lerofs -lcutils -lext2_uuid -llog -llz4 -lselinux -lbase -lpcre
rm -f *.o

# fuse.erofs is rely on linux kernel support
# cannot compile at windows

# dump.erofs
$CC ${CFLAGS} \
 -I./include \
 -I./include/erofs \
 -I./libselinux/include \
 -I./base/include \
 -I./libcutils/include \
 -I./e2fsprogs/lib/uuid \
 -c dump/main.c
 
 $CPP ${CFLAGS} -stdlib=libc++ -o \
  bin/dump.erofs.exe main.o \
 -Llibs \
 -lerofs -lcutils -lext2_uuid -llog -llz4 -lselinux -lbase -lpcre
 
 # fsck.erofs
$CC ${CFLAGS} \
 -I./include \
 -I./include/erofs \
 -I./libselinux/include \
 -I./base/include \
 -I./libcutils/include \
 -I./e2fsprogs/lib/uuid \
 -c fsck/main.c
 
 $CPP ${CFLAGS} -stdlib=libc++ -o \
  bin/fsck.erofs.exe main.o \
 -Llibs \
 -lerofs -lcutils -lext2_uuid -llog -llz4 -lselinux -lbase -lpcre

}

copy_dll() {
DLLS="
/bin/cyggcc_s-seh-1.dll
/bin/cygwin1.dll
/bin/cygc++-1.dll
/bin/cygc++abi-1.dll
/bin/cygunwind-1.dll
/bin/cygpcre-1.dll
./mkerofsimage.sh
"

for i in $DLLS
do
  cp $i ./bin/
done
}

static_library
executable_binarys
copy_dll
#!/bin/bash

set -eu

SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

cd "$SCRIPT_DIR"

# Create archive with only required files
rm -rf zlib.tar.gz zlib
mkdir zlib
cp ../{*.c,*.h,zconf.h.cmakein,Changelog,README,LICENSE} zlib
cp CMakeLists.txt zlib
rm -f zlib/zconf.h

# apply custom patches
cd zlib
patch -p1 < ../0-apple-off64_t.patch
patch -p1 < ../1-apple-lseek64.patch
patch -p1 < ../2-win-gnu-z_off64_t.patch

cd ..

tar cf zlib.tar zlib/
gzip -9 -f zlib.tar

echo "created 0-chemfiles/zlib.tar.gz"

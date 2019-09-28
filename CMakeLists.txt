cmake_minimum_required(VERSION 2.8.12)
project(zlib C)

if (POLICY CMP0063)
    # Use of `<LANG>_VISIBILITY_PRESET` in OBJECT libraries
    cmake_policy(SET CMP0063 NEW)
endif()

set(VERSION "1.2.11-chemfiles")

# include(CheckTypeSize)
include(CheckFunctionExists)
include(CheckIncludeFile)
# include(CheckCSourceCompiles)

check_include_file(sys/types.h HAVE_SYS_TYPES_H)
check_include_file(stdint.h    HAVE_STDINT_H)
check_include_file(stddef.h    HAVE_STDDEF_H)

# Check for fseeko
check_function_exists(fseeko HAVE_FSEEKO)
# Check for unistd.h
check_include_file(unistd.h Z_HAVE_UNISTD_H)

# parse the full version number from zlib.h and include in ZLIB_FULL_VERSION
file(READ ${CMAKE_CURRENT_SOURCE_DIR}/zlib.h _zlib_h_contents)
string(REGEX REPLACE ".*#define[ \t]+ZLIB_VERSION[ \t]+\"([-0-9A-Za-z.]+)\".*"
    "\\1" ZLIB_FULL_VERSION ${_zlib_h_contents})

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/zconf.h.cmakein
	${CMAKE_CURRENT_BINARY_DIR}/zconf.h @ONLY
)

set(ZLIB_PUBLIC_HDRS
    ${CMAKE_CURRENT_BINARY_DIR}/zconf.h
    zlib.h
)
set(ZLIB_PRIVATE_HDRS
    crc32.h
    deflate.h
    gzguts.h
    inffast.h
    inffixed.h
    inflate.h
    inftrees.h
    trees.h
    zutil.h
)
set(ZLIB_SRCS
    adler32.c
    compress.c
    crc32.c
    deflate.c
    gzclose.c
    gzlib.c
    gzread.c
    gzwrite.c
    inflate.c
    infback.c
    inftrees.c
    inffast.c
    trees.c
    uncompr.c
    zutil.c
)

add_library(zlib OBJECT ${ZLIB_SRCS} ${ZLIB_PUBLIC_HDRS} ${ZLIB_PRIVATE_HDRS})

target_include_directories(zlib PUBLIC
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
)

if(NOT HAVE_FSEEKO)
    target_compile_options(zlib PUBLIC -DNO_FSEEKO)
endif()

# Require support for large (64-bit) files
target_compile_options(zlib PUBLIC -D_LARGEFILE64_SOURCE=1)

if(MSVC)
    target_compile_options(zlib PUBLIC -D_CRT_SECURE_NO_DEPRECATE)
    target_compile_options(zlib PUBLIC -D_CRT_NONSTDC_NO_DEPRECATE)
endif()

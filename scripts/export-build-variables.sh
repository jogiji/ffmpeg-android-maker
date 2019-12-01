function max() {
  [ $1 -ge $2 ] && echo "$1" || echo "$2"
}

export ANDROID_ABI=$1

if [ $ANDROID_ABI = "arm64-v8a" ] || [ $ANDROID_ABI = "x86_64" ] ; then
  # For 64bit we use value not less than 21
  export ANDROID_PLATFORM=$(max ${DESIRED_ANDROID_API_LEVEL} 21)
else
  export ANDROID_PLATFORM=${DESIRED_ANDROID_API_LEVEL}
fi

export TOOLCHAIN_PATH=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/${HOST_TAG}
export SYSROOT_PATH=${TOOLCHAIN_PATH}/sysroot

TARGET_TRIPLE_MACHINE_CC=
CPU_FAMILY=
export TARGET_TRIPLE_OS="android"

case $ANDROID_ABI in
  armeabi-v7a)
    #cc       armv7a-linux-androideabi16-clang
    #binutils arm   -linux-androideabi  -ld
    export TARGET_TRIPLE_MACHINE_BINUTILS=arm
    TARGET_TRIPLE_MACHINE_CC=armv7a
    export TARGET_TRIPLE_OS=androideabi
    ;;
  arm64-v8a)
    #cc       aarch64-linux-android21-clang
    #binutils aarch64-linux-android  -ld
    export TARGET_TRIPLE_MACHINE_BINUTILS=aarch64
    ;;
  x86)
    #cc       i686-linux-android16-clang
    #binutils i686-linux-android  -ld
    export TARGET_TRIPLE_MACHINE_BINUTILS=i686
    CPU_FAMILY=x86
    ;;
  x86_64)
    #cc       x86_64-linux-android21-clang
    #binutils x86_64-linux-android  -ld
    export TARGET_TRIPLE_MACHINE_BINUTILS=x86_64
    ;;
esac

# If the cc-specific variable isn't set, we fallback to binutils version
[ -z "${TARGET_TRIPLE_MACHINE_CC}" ] && TARGET_TRIPLE_MACHINE_CC=${TARGET_TRIPLE_MACHINE_BINUTILS}
export TARGET_TRIPLE_MACHINE_CC=$TARGET_TRIPLE_MACHINE_CC

[ -z "${CPU_FAMILY}" ] && CPU_FAMILY=${TARGET_TRIPLE_MACHINE_BINUTILS}
export CPU_FAMILY=$CPU_FAMILY

# Common prefix for ld, as, etc.
export CROSS_PREFIX=${TARGET_TRIPLE_MACHINE_BINUTILS}-linux-${TARGET_TRIPLE_OS}-
export CROSS_PREFIX_WITH_PATH=${TOOLCHAIN_PATH}/bin/${CROSS_PREFIX}

# Exporting Binutils paths, if passing just CROSS_PREFIX_WITH_PATH is not enough
export FAM_ADDR2LINE=${CROSS_PREFIX_WITH_PATH}addr2line
export        FAM_AR=${CROSS_PREFIX_WITH_PATH}ar
export        FAM_AS=${CROSS_PREFIX_WITH_PATH}as
export       FAM_DWP=${CROSS_PREFIX_WITH_PATH}dwp
export   FAM_ELFEDIT=${CROSS_PREFIX_WITH_PATH}elfedit
export     FAM_GPROF=${CROSS_PREFIX_WITH_PATH}gprof
export        FAM_LD=${CROSS_PREFIX_WITH_PATH}ld
export        FAM_NM=${CROSS_PREFIX_WITH_PATH}nm
export   FAM_OBJCOPY=${CROSS_PREFIX_WITH_PATH}objcopy
export   FAM_OBJDUMP=${CROSS_PREFIX_WITH_PATH}objdump
export    FAM_RANLIB=${CROSS_PREFIX_WITH_PATH}ranlib
export   FAM_READELF=${CROSS_PREFIX_WITH_PATH}readelf
export      FAM_SIZE=${CROSS_PREFIX_WITH_PATH}size
export   FAM_STRINGS=${CROSS_PREFIX_WITH_PATH}strings
export     FAM_STRIP=${CROSS_PREFIX_WITH_PATH}strip

export TARGET=${TARGET_TRIPLE_MACHINE_CC}-linux-${TARGET_TRIPLE_OS}${ANDROID_PLATFORM}
# The name for compiler is slightly different, so it is defined separatly.
export FAM_CC=${TOOLCHAIN_PATH}/bin/${TARGET}-clang
export FAM_CXX=${FAM_CC}++
# TODO consider abondaning this strategy of defining the name of the clang wrapper
# in favour of just passing -mstackrealign and -fno-addrsig depending on
# ANDROID_ABI and NDK's version

# Special variable for the yasm assembler
export FAM_YASM=${TOOLCHAIN_PATH}/bin/yasm

# A variable to which certain dependencies can add -l arguments during build.sh
export FFMPEG_EXTRA_LD_FLAGS=

export INSTALL_DIR=${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}

# Forcing FFmpeg and its dependencies to look for dependencies
# in a specific directory when pkg-config is used
export PKG_CONFIG_LIBDIR=${INSTALL_DIR}/lib/pkgconfig

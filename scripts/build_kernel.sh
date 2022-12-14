set -e
cd "$(dirname "$(readlink -f "$0")")"

# ******************** SCRIPT CONFIG ********************

NEED_CROSS_COMPILE=true
COMPILE_WORKERS=$((`nproc`+1)) # CPU cores +1

KERNEL_VERSION=4.19
KERNEL_CFG_NAME=mini_defconfig

# ******************** COMMON VARS ********************

ROOT_DIR="$(readlink -f "$PWD/..")"
BUILD_DIR=$ROOT_DIR/build
PACKAGE_DIR=$ROOT_DIR/packages

# ******************** LOCAL VARS ********************

TOOLCHAIN_DIR=$BUILD_DIR/toolchain
KERNEL_SRC_DIR=$BUILD_DIR/source/kernel/linux-$KERNEL_VERSION
KERNEL_CFG_DIR=$KERNEL_SRC_DIR/arch/arm64/configs

ORIGINAL_CFG=$BUILD_DIR/$KERNEL_CFG_NAME.original
ASC_SRC_PACKAGE=$PACKAGE_DIR/Ascend310-source-minirc.tar.gz
TOOLCHAIN_PACKAGE=$PACKAGE_DIR/gcc-*-x86_64_aarch64-linux-gnu.tar.xz
KERNEL_CFG_RELATIVE=source/kernel/linux-$KERNEL_VERSION/arch/arm64/configs/$KERNEL_CFG_NAME

ASC_SDK_URL='https://support.huawei.com/enterprise/zh/ascend-computing/atlas-200-pid-23464086/software'
TOOLCHAIN_URL='http://releases.linaro.org/components/toolchain/binaries/5.4-2017.05/aarch64-linux-gnu/gcc-linaro-5.4.1-2017.05-x86_64_aarch64-linux-gnu.tar.xz'

# ******************** FUNCTIONS ********************

# 输出错误信息
echoerr () {
    >&2 echo -e '[ERROR]' "$@"
}

# 将make命令包装
_make () {
    cmd=$1
    if [ $NEED_CROSS_COMPILE = true ]; then
        MAKE="make -j$COMPILE_WORKERS ARCH=arm64 CROSS_COMPILE=$TOOLCHAIN_DIR/bin/aarch64-linux-gnu-"
    else
        MAKE="make -j$COMPILE_WORKERS ARCH=arm64"
    fi
    bash -c "cd $KERNEL_SRC_DIR; $MAKE $cmd"
}

# 将build.sh脚本包装
_build_sh () {
    cmd=$1
    if [ $NEED_CROSS_COMPILE = true ]; then
        PATH=$PATH:$TOOLCHAIN_DIR/bin bash $BUILD_DIR/source/build.sh $cmd
    else
        bash $BUILD_DIR/source/build.sh $cmd
    fi
}

# 脚本初始化
init () {
    echo '正在初始化内核构建脚本...'

    if [ ! -d $BUILD_DIR ]; then
        echo '正在新建构建目录...'
        mkdir -p $BUILD_DIR
        echo '新建完成'
    fi

    if [ ! -d $KERNEL_SRC_DIR ]; then
        echo '正在解压Linux内核源码...'
        if [ -f $ASC_SRC_PACKAGE ]; then
            tar -xzf $ASC_SRC_PACKAGE --directory $BUILD_DIR
            echo '解压完成'
        else
            echoerr "找不到内核源码压缩包 $(basename $ASC_SRC_PACKAGE)\n请访问 $ASC_SDK_URL 下载所需版本的 Atlas-200-sdk_<版本号>.zip ，解压后将其中的 $(basename $ASC_SRC_PACKAGE) 放置在 $PACKAGE_DIR 目录下"
            exit -1
        fi
    fi

    if [ ! -f $ORIGINAL_CFG ]; then
        echo '正在备份原始内核配置文件...'
        if [ -f $ASC_SRC_PACKAGE ]; then
            dir_depth=$(echo $KERNEL_CFG_RELATIVE | grep -o '/' - | wc -l)
            tar -xzf $ASC_SRC_PACKAGE --directory $BUILD_DIR $KERNEL_CFG_RELATIVE --strip-components=$dir_depth
            mv $BUILD_DIR/$KERNEL_CFG_NAME $ORIGINAL_CFG
            echo '备份完毕'
        else
            echoerr "找不到内核源码压缩包 $(basename $ASC_SRC_PACKAGE)\n请访问 $ASC_SDK_URL 下载所需版本的 Atlas-200-sdk_<版本号>.zip ，解压后将其中的 $(basename $ASC_SRC_PACKAGE) 放置在 $PACKAGE_DIR 目录下"
            exit -1
        fi
    fi

    if [ $NEED_CROSS_COMPILE = true ]; then
        if [ ! -d $TOOLCHAIN_DIR ]; then
            echo '正在解压GCC ARM64交叉编译工具链...'
            if [ -f $TOOLCHAIN_PACKAGE ]; then
                mkdir -p $TOOLCHAIN_DIR
                tar -xJf $TOOLCHAIN_PACKAGE --directory $TOOLCHAIN_DIR --strip-components=1
                echo '解压完成'
            else
                echoerr "找不到交叉编译工具链压缩包 $(basename $TOOLCHAIN_PACKAGE)\n请访问 $TOOLCHAIN_URL 下载交叉编译工具链压缩包，然后直接将压缩包放置在 $PACKAGE_DIR 目录下"
                exit -1
            fi
        fi
    fi

    echo '初始化完成'
}

# 重置内核配置
reset_kernel_config () {
    echo '正在重置内核配置...'
    cp $ORIGINAL_CFG $KERNEL_CFG_DIR/$KERNEL_CFG_NAME
    _make $KERNEL_CFG_NAME
    echo '重置内核配置完成'
}

# 修改内核配置
change_kernel_config () {
    echo '正在修改内核配置...'
    tmp_cfg=$KERNEL_SRC_DIR/.config
    _make $KERNEL_CFG_NAME

    md5_before=$(md5sum "$tmp_cfg")
    trap '' INT
    _make menuconfig || true
    trap - INT
    md5_after=$(md5sum "$tmp_cfg")

    if [ ! "$md5_before" = "$md5_after" ]; then
        echo '内核配置已修改'
        cp $tmp_cfg $KERNEL_CFG_DIR/$KERNEL_CFG_NAME
    else
        echo '内核配置保持不变'
    fi
    echo '修改内核配置完成'
}

# 编译内核
build_kernel () {
    echo '正在编译内核...'
    _make mrproper
    _build_sh kernel
    _build_sh modules
    echo '编译内核完成'
}

# 清空编译结果
clear_build () {
    echo '正在清空编译结果...'
    _make clean
    rm -rf $BUILD_DIR/source/output $BUILD_DIR/source/kernel/out
    find $BUILD_DIR/source/repack/ -maxdepth 1 -type f -delete

    echo '清空编译结果完成'
}

# 清空编译结果后，重新配置并编译内核
do_all () {
    echo '清空编译结果后，重新配置并编译内核'
    clear_build
    reset_kernel_config
    change_kernel_config
    build_kernel
    echo '操作完成'
}

# 展示编译内核前需要安装的依赖
show_dep () {
    echo '编译内核前请确保已经安装如下依赖（以apt包管理器为例）：'
    echo 'sudo apt install -y python make gcc unzip bison flex libncurses-dev squashfs-tools bc'
}

# ******************** MAIN SCRIPT ********************

# 脚本初始化
init

echo -e '需要进行什么操作？\n'\
'    1. 展示编译内核前需要安装的依赖\n'\
'    2. 清空编译结果后，重新配置并编译内核（依次执行6-3-4-5）\n'\
'    3. 重置内核配置\n'\
'    4. 修改内核配置\n'\
'    5. 编译内核\n'\
'    6. 清空编译结果\n'\
'输入选项编号以继续：'
read selection

case $selection in
    1)
        # 展示编译内核前需要安装的依赖
        show_dep
        ;;
    2)
        # 清空编译结果后，重新配置并编译内核
        do_all
        ;;
    3)
        # 重置内核配置
        reset_kernel_config
        ;;
    4)
        # 修改内核配置
        change_kernel_config
        ;;
    5)
        # 编译内核
        build_kernel
        ;;
    6)
        # 清空编译结果
        clear_build
        ;;
esac
echo '内核构建脚本运行结束'

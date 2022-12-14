# Qingyun-tools
定制青云开发板系统，并将系统镜像烧录至SD卡的脚本工具，基于华为Atlas 200 AI加速模块的[开发文档](https://support.huawei.com/enterprise/zh/doc/EDOC1100221707/939091dd)。

## 编译系统内核
如果您需要特别定制自己的青云开发板系统，为系统添加一些自定义的功能，请遵循本节的步骤，配置并编译开发板的Linux系统内核。

本工具支持在青云开发板上直接编译，也支持使用x64 Linux服务器（含虚拟机与WSL）交叉编译。若要在青云开发板上直接编译，建议使用`Windows Terminal`、`MobaXterm`等现代终端模拟器，通过SSH连接青云的系统终端。

### 下载内核源代码压缩包
首先，请前往华为的技术支持网站，获取您所需版本的Atlas 200[软件包](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-200-pid-23464086/software)`Atlas-200-sdk_<版本号>.zip`。

> **⚠️注意**  
> 在下载前，华为会提示**需要注册成为它的商用客户才能获取软件包**。
> 1. 请小心地将青云开发板上的Atlas 200 AI加速模块拆下，**模块背面右下角的贴纸处**记录了产品的**序列号**——从第一行“SN:”字样后开始，到第三行结束，共16个字符。
> 2. 获取序列号后，请根据华为网站的引导，使用产品序列号注册成为华为的商业用户。您注册成功后即可获得软件包等资料的下载权限。

成功下载`Atlas-200-sdk_<版本号>.zip`压缩文件后，**将其中的`Ascend310-source-minirc.tar.gz`压缩包拷贝到本工具的`packages/`目录下**，内核源代码压缩包准备完毕。

### 下载交叉编译工具链
> **⚠️注意**  
> 仅供交叉编译参考。若是在开发板系统上直接编译，则不用执行此步骤。

请前往[该网站](http://releases.linaro.org/components/toolchain/binaries/5.4-2017.05/aarch64-linux-gnu/gcc-linaro-5.4.1-2017.05-x86_64_aarch64-linux-gnu.tar.xz)获取交叉编译工具链的压缩包`gcc-linaro-5.4.1-2017.05-x86_64_aarch64-linux-gnu.tar.xz`，然后将压缩包直接放置在`packages/`目录下。  
如果下载出现异常，可以使用国内天翼云盘链接下载：
```
https://cloud.189.cn/web/share?code=niquM3u6N3Ar（访问码：gjk1）
```

### 运行内核编译脚本
`scripts/build_kernel.sh`脚本用于配置并编译开发板的Linux系统内核。

> **⚠️注意**  
> 脚本默认处于交叉编译模式。如需在开发板系统上直接编译，请先打开脚本文件，修改配置：
> ```
> NEED_CROSS_COMPILE=false # 关闭交叉编译模式。若在x64 Linux服务器上编译则无需关闭
> ```

在仓库根目录下直接执行脚本，详细情况请阅读下面的`脚本说明`。
```
./scripts/build_kernel.sh
```

> **⚠️特别注意⚠️**  
> **开发板的USB XHCI使用了特殊的驱动！若要开发板上的USB正常工作，请务必保证在内核配置界面`USB_XHCI_HCD`的选项为`M`，并在打包时使用`drivers/xchi.tar.gz`里提供的特殊驱动代替编译出的XHCI驱动！**  
> 如果感到困惑，可以参考[使用预设的内核配置](#使用预设的内核配置)一节中所提到的**预设配置文件**。`configs/`目录下列举了适用于“不同SDK版本”的，“开启了不同功能”的预设内核配置。

**📘脚本说明**
1. 脚本执行时会首先进行初始化。初始化时脚本将查看系统源代码、编译工具链等文件是否存在，最终相应文件会被解压至新建的`build/`目录中。

2. 初始化完毕后，脚本会在终端中输出操作菜单。用户键入相应的菜单项数字后，回车即可执行。

3. 首次运行脚本时，建议先选择执行`展示编译内核前需要安装的依赖`，安装相关依赖。依赖满足后，建议执行`清空编译结果后，重新配置并编译内核`，完整走一遍内核编译的流程。

4. 编译完毕后，内核镜像与系统模块将输出至`build/source/output/`目录，同时也会生成用于驱动打包的`build/source/repack/`目录。编译过程中生成的其它文件位于`build/source/kernel/out/`目录。

5. `清空编译结果`会删除`build/source/output/`与`build/source/kernel/out/`目录，但**并不会修改`build/source/repack/`目录**。在“更新配置文件”和“重构驱动包”时请**特别注意该目录下文件的修改日期**，不要将旧文件误打包了。

### 使用预设的内核配置
`configs/`目录下准备了适用于特定版本SDK的（版本号参照`Atlas-200-sdk_<版本号>.zip`，尚未测试版本号不匹配的情况），开启了不同功能的内核配置文件。  
如`configs/Ascend310_21.0.4.9/usb_camera_serial/mini_defconfig`配置文件，它适用于21.0.4.9版本的SDK，且预先开启了USB支持、USB摄像头支持以及某些USB串口芯片支持。详情请见对应配置文件旁的`README.md`和`userfilelist.csv`。

- 如需使用上述配置作为内核的**临时配置文件**，请执行以下操作
```
cp configs/Ascend310_21.0.4.9/usb_camera_serial/mini_defconfig build/source/kernel/linux-4.19/arch/arm64/configs/mini_defconfig
```
然后执行`./scripts/build_kernel.sh`，选择`编译内核`即可开始编译。若要恢复SDK源码中的默认内核配置，选择`重置内核配置`即可恢复默认配置。

- 如需使用上述配置作为内核的**默认配置文件**，请执行以下操作
```
cp configs/Ascend310_21.0.4.9/usb_camera_serial/mini_defconfig build/mini_defconfig.original
```
然后执行`./scripts/build_kernel.sh`，选择`重置内核配置`即可将指定预设配置作为内核的默认配置。若要恢复SDK源码中的默认内核配置，删除文件`build/mini_defconfig.original`后重新执行`./scripts/build_kernel.sh`，选择`重置内核配置`即可恢复默认配置。

## 更新配置文件
## 重构驱动包
## 制作启动镜像包

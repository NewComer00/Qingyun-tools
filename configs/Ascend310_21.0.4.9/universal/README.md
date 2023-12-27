# 支持设备列表

## 设备树
设备树源文件位于`dtb/`目录下。额外添加的启动参数如下
- 系统串口 `console=ttyAMA0,115200`
- cgroup v1 `systemd.unified_cgroup_hierarchy=0`

### 系统调试串口
`0`号串口`/dev/ttyAMA0`可以作为青云的系统调试串口，连接至用户的终端。

#### 使用方法
1. 保持青云断电，使用串口模块和杜邦线将青云开发板的`0`号串口连接到电脑。
2. 在电脑上打开终端模拟器（如`MobaXterm`）或串口助手软件，将串口连接属性设置为`115200 8N1`，建立连接。
3. 给青云上电，此时终端模拟器或串口助手将依次输出`引导日志`，`系统启动日志`与`登录提示`。
4. 输入用户名和密码，即可通过串口登录系统。
5. 如果在系统启动后建立串口连接，在终端模拟器或串口助手中发送新行字符（按下回车键），即可看到`登录提示`。

### cgroup
**cgroup**用于限制Linux中的进程组资源，有两个版本`cgroup v1`和`cgroup v2`，后者旨在取代前者。青云目前支持`cgroup v1`。

## USB 3.0
通用设备

在“重构驱动包”时，USB相关驱动与固件位于`drivers/`目录下的`xhci.tar.xz`驱动包中。解压驱动包，参考本目录下或xhci驱动包中的`userfilelist.csv`，将所需驱动和固件放置到规定位置。

## USB 2.0
通用设备

## USB 1.1
通用设备

## USB摄像头
通用设备

## USB蓝牙适配器
通用设备

## USB声卡
通用设备

## USB串口芯片
### CP210X
✅ [已测试]
### CH341
✅ [已测试]

## USB无线网卡芯片
芯片固件请前往如下网址获取。详情请参考本目录下的`userfilelist.csv`。
```
https://anduin.linuxfromscratch.org/sources/linux-firmware/
```
### Realtek

#### RTL8192CU
✅ [已测试]

芯片固件`rtl8192cufw_TMSC.bin`请前往如下网址获取
```
https://anduin.linuxfromscratch.org/sources/linux-firmware/rtlwifi/rtl8192cufw_TMSC.bin
```

#### RTL8188CU
✅ [已测试]

芯片固件`rtl8192cufw_TMSC.bin`请前往如下网址获取
```
https://anduin.linuxfromscratch.org/sources/linux-firmware/rtlwifi/rtl8192cufw_TMSC.bin
```

#### RTL8811CU/RTL8821CU
✅ [已测试]

编译好的驱动程序`8821cu.ko`位于`drivers/rtl8821cu.tar.xz`压缩包中。如果需要使用该网卡驱动，在重构驱动包时将`8821cu.ko`复制到指定路径下即可。也可在运行中的系统上执行`insmod <ko文件位置>`来加载该驱动。

驱动源代码请前往如下网址获取
```
https://github.com/brektrou/rtl8821CU
```

#### RTL8192EU
✅ [已测试]

编译好的驱动程序`8192eu.ko`位于`drivers/rtl8192eu.tar.xz`压缩包中。如果需要使用该网卡驱动，在重构驱动包时将`8192eu.ko`复制到指定路径下即可。也可在运行中的系统上执行`insmod <ko文件位置>`来加载该驱动。

驱动源代码请前往如下网址获取
```
https://github.com/Mange/rtl8192eu-linux-driver
```

### MediaTek

#### MT7601U
✅ [已测试]

芯片固件`mt7601u.bin`请前往如下网址获取
```
https://anduin.linuxfromscratch.org/sources/linux-firmware/mediatek/mt7601u.bin
```

#### MT76x0U
芯片固件`mt7610u.bin`请前往如下网址获取
```
https://anduin.linuxfromscratch.org/sources/linux-firmware/mediatek/mt7610u.bin
```

#### MT76x2U
芯片固件`mt7662u.bin`请前往如下网址获取
```
https://anduin.linuxfromscratch.org/sources/linux-firmware/mediatek/mt7662u.bin
```

## USB转CAN模块
### Cando_pro
✅ [已测试]

## RNDIS设备
用户可以将安卓手机的USB网络共享打开，然后用USB数据线连接手机与开发板的TypeA USB接口。此时，开发板系统中应当识别到一个新的网络接口。

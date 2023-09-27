# 支持设备列表

## USB 3.0
通用设备

内核编译完毕后，需要用到的USB芯片驱动为`xhci-pci-renesas.ko`与`xhci-pci.ko`
```
cp build/source/output/xhci-pci-renesas.ko build/source/repack/
cp build/source/output/xhci-pci.ko build/source/repack/
```

此外，芯片固件请按如下方式获取
```
wget 'https://github.com/NewComer00/uPD72020x-Firmware/raw/master/UPDATE.mem%202.0.2.0' -O build/source/repack/renesas_usb_fw.mem
```

## USB 2.0
通用设备

## USB 1.1
通用设备

## USB摄像头
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

OpenWrt for Xiaomi AC2100

A repo from https://p3terx.com build Openwrt for Xiaomi AC2100/Redmi AC2100

说明
- 代码来源：[![Lean](https://img.shields.io/badge/Lede-Lean-ff69b4.svg?style=flat&logo=appveyor)](https://github.com/coolsnowwolf/lede) [![P3TERX](https://img.shields.io/badge/OpenWrt-P3TERX-blueviolet.svg?style=flat&logo=appveyor)](https://github.com/P3TERX/Actions-OpenWrt)
- 项目使用 Github Actions 拉取 [Lean](https://github.com/coolsnowwolf/lede) 的 Openwrt 源码仓库进行云编译
- 固件默认管理地址：`192.168.2.1` 默认用户：`root` 默认密码：`password`
- 默认超频1100MHz
- 内核使用5.4系列，该系列内核在AC2100运行负载略低
- 提供适配于 Xiaomi AC2100/Redmi AC2100
- 固件在 [Releases](https://github.com/hwliu11/R2100/releases) 内进行下载
- 项目编译的固件插件为最新版本，最新版插件可能有 BUG，如果之前使用稳定则无需追新
- 第一次使用请采用全新安装，避免出现升级失败以及其他一些可能的 BUG

只包含以下插件 
onliner	[https://github.com/kiddin9/openwrt-packages](https://github.com/kiddin9/openwrt-packages)  
luci-app-poweroff	[https://github.com/esirplayground/luci-app-poweroff](https://github.com/esirplayground/luci-app-poweroff)  
serverchan	[https://github.com/tty228/luci-app-serverchan](https://github.com/tty228/luci-app-serverchan "openwrt-18.06分支")  
SmartDNS	[https://github.com/pymumu/luci-app-smartdns](https://github.com/pymumu/luci-app-smartdns "lede分支")  
luci-app-wrtbwmon	[https://github.com/kiddin9/openwrt-packages](https://github.com/kiddin9/openwrt-packages)  
wrtbwmon	[https://github.com/kiddin9/openwrt-packages](https://github.com/kiddin9/openwrt-packages)  
luci-theme-argon	[https://github.com/kiddin9/openwrt-packages](https://github.com/kiddin9/openwrt-packages)  
luci-app-argon-config	[https://github.com/kiddin9/openwrt-packages](https://github.com/kiddin9/openwrt-packages)  
luci-theme-opentopd	[https://github.com/sirpdboy/luci-theme-opentopd](https://github.com/sirpdboy/luci-theme-opentopd)  
luci-theme-kucat	[https://github.com/sirpdboy/luci-theme-kucat](https://github.com/sirpdboy/luci-theme-kucat "main分支")  



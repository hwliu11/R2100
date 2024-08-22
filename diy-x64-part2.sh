#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

#clone to package
function pull_from_github()
{
	echo "+++++++++++++++++++++++++++++++++++++++++"
	echo -e "\033[35m use git get source from https://github.com/$1/$2 \033[0m"
	if [ ! -d "./package/$2" ]; then
		echo -e "\033[36m pull $2 source \033[0m"
		if [ $# -lt 3 ]; then
			git clone --depth 1 https://github.com/$1/$2 package/$2
		else
			git clone --depth 1 -b $3 https://github.com/$1/$2 package/$2
		fi
	else
		cd ./package/$2
		echo -e "\033[36m udapte $2 source \033[0m"
		git pull
		if [ $? -ne 0 ]; then
				echo -e "\033[31m pull $2 source failed \033[0m"
		else
				echo "surcessful at $(date) "
		fi
		cd ../../
	fi
	if [ ! -d "./package/$2" ]; then
		echo "------------------------------------------"
		echo -e "\033[31m get source $2 failed \033[0m"
		echo "------------------------------------------"
	fi
}
#clone sub directory to package
function git_clone_path() {
          branch="$1" rurl="$2" localdir="./package/git-temp" && shift 2
		  [ -e $localdir ] && rm -rf $localdir
          git clone -b $branch --depth 1 --filter=blob:none --sparse $rurl $localdir
          if [ "$?" != 0 ]; then
            echo "error on $rurl"
            return 0
          fi
          cd $localdir
          git sparse-checkout init --cone
	  for pname in "$@"
	  do
          	 git sparse-checkout set $pname
          	 echo get source for $pname
          	 if [ -e ../$pname ]; then rm -rf ../$pname; fi
		 mv -f $pname ../ || cp -rf $pname ../$(dirname "$pname")/
	  done
          cd ../..
	  rm -rf $localdir
}
# 添加额外软件包
git_clone_path master https://github.com/kiddin9/openwrt-packages luci-app-adguardhome luci-app-netdata luci-app-filebrowser luci-app-dockerman luci-app-docker brook v2ray-geodata chinadns-ng dns2socks dns2tcp hysteria ipt2socks microsocks naiveproxy pdnsd-alt ssocks tcping trojan-go trojan-plus simple-obfs v2ray-core v2ray-plugin shadowsocks-rust shadowsocksr-libev xray-core lua-neturl trojan redsocks2 v2ray-plugin luci-theme-edge luci-theme-argon luci-app-argon-config luci-app-mosdns mosdns luci-app-wrtbwmon wrtbwmon luci-app-alist alist luci-app-wizard luci-app-onliner luci-app-netspeedtest speedtest-web homebox cpulimit luci-app-cpulimit luci-app-v2ray-server xray-plugin luci-app-store ffmpeg-remux luci-lib-taskd luci-lib-xterm taskd lua-neturl simple-obfs naiveproxy hysteria redsocks2 microsocks luci-app-bypass luci-app-openclash luci-app-passwall luci-app-passwall2 luci-app-ssr-plus tuic-client shadowsocks-rust shadow-tls gn
pull_from_github destan19 OpenAppFilter
pull_from_github tty228 luci-app-serverchan
pull_from_github pymumu luci-app-smartdns

pull_from_github esirplayground luci-app-poweroff
#alist makefile缺少libfuse依赖
#sed -i 's/(GO_ARCH_DEPENDS)/(GO_ARCH_DEPENDS) libfuse/' package/alist/Makefile

# 设置向导
sed -i 's/"admin"/"admin", "system"/g' package/luci-app-wizard/luasrc/controller/wizard.lua

grep -n "refresh_interval=2s" package/lean/default-settings/files/zzz-default-settings
if [ $? -ne 0 ]; then
	sed -i '/bin\/sh/a\uci set nlbwmon.@nlbwmon[0].refresh_interval=2s' package/lean/default-settings/files/zzz-default-settings
	sed -i '/nlbwmon/a\uci commit nlbwmon' package/lean/default-settings/files/zzz-default-settings
fi

if [ -d "package/luci-app-onliner/root/usr/share/onliner" ]; then
	chmod -R 755 package/luci-app-onliner/root/usr/share/onliner/*
fi

pull_from_github sirpdboy luci-theme-kucat main


#npm config set registry https://registry.npmmirror.com/

#speedtest-web upx
if [[ -d "./package/speedtest-web" ]]; then
	grep "upx/host" ./package/speedtest-web/Makefile
	if [ $? -ne 0 ]; then
		sed -i 's/golang\/host/golang\/host upx\/host/' package/speedtest-web/Makefile
	fi
fi

# 修改版本为编译日期
grep "by Hwliu" package/lean/default-settings/files/zzz-default-settings
if [ $? -ne 0 ]; then
	date_version=$(date +"%Y.%m.%d")
	orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
	sed -i "s/${orig_version}/R${date_version} by Hwliu/g" package/lean/default-settings/files/zzz-default-settings
fi

# 调整 x86 型号只显示 CPU 型号
sed -i '/h=${g}.*/d' package/lean/autocore/files/x86/autocore
sed -i 's/(dmesg.*/{a}${b}${c}${d}${e}${f}/g' package/lean/autocore/files/x86/autocore
sed -i 's/echo $h/echo $g/g' package/lean/autocore/files/x86/autocore

# 修改 Makefile
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/include\ \.\.\/\.\.\/luci\.mk/include \$(TOPDIR)\/feeds\/luci\/luci\.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/include\ \.\.\/\.\.\/lang\/golang\/golang\-package\.mk/include \$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang\-package\.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=\@GHREPO/PKG_SOURCE_URL:=https:\/\/github\.com/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=\@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload\.github\.com/g' {}

# 删除主题强制默认
find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;

# 调整 V2ray服务器 到 VPN 菜单
sed -i 's/services/vpn/g' package/luci-app-v2ray-server/luasrc/controller/*.lua
sed -i 's/services/vpn/g' package/luci-app-v2ray-server/luasrc/model/cbi/v2ray_server/*.lua
sed -i 's/services/vpn/g' package/luci-app-v2ray-server/luasrc/view/v2ray_server/*.htm

# 调整 CONTROL 到 服务 菜单
sed -i 's/control/services/g' package/luci-app-cpulimit/luasrc/controller/*.lua
sed -i 's/control/services/g' package/luci-app-cpulimit/luasrc/model/cbi/*.lua


./scripts/feeds update -a

# 移除重复软件包
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-netgear
rm -rf feeds/luci/applications/luci-app-netdata
rm -rf feeds/luci/applications/luci-app-wrtbwmon
rm -rf feeds/luci/applications/luci-app-dockerman
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/packages/net/pdnsd-alt
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/luci/applications/luci-app-serverchan
rm -rf feeds/luci/applications/luci-app-v2ray-server


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
          	 if [ -e ../$pname ]; then rm -rf ../$pname; fi
		 mv -f $pname ../ || cp -rf $pname ../$(dirname "$pname")/
	  done
          cd ../..
	  rm -rf $localdir
}

# 添加额外软件包
#R2100/RM2100资源限制无法正常使用
#git_clone_path main https://github.com/sirpdboy/sirpdboy-package luci-app-adguardhome
pull_from_github tty228 luci-app-serverchan openwrt-18.06
pull_from_github esirplayground luci-app-poweroff
pull_from_github pymumu luci-app-smartdns lede
pull_from_github sirpdboy luci-theme-opentopd
pull_from_github sirpdboy luci-theme-kucat main
# 在线用户
git_clone_path master https://github.com/kiddin9/openwrt-packages luci-app-wrtbwmon wrtbwmon luci-app-onliner luci-theme-argon luci-app-argon-config

grep -n "refresh_interval=2s" package/lean/default-settings/files/zzz-default-settings
if [ $? -ne 0 ]; then
	sed -i '/bin\/sh/a\uci set nlbwmon.@nlbwmon[0].refresh_interval=2s' package/lean/default-settings/files/zzz-default-settings
	sed -i '/nlbwmon/a\uci commit nlbwmon' package/lean/default-settings/files/zzz-default-settings
fi

if [ -d "package/luci-app-onliner/root/usr/share/onliner" ]; then
	chmod -R 755 package/luci-app-onliner/root/usr/share/onliner/*
fi

# 修改版本为编译日期
grep "by Hwliu" package/lean/default-settings/files/zzz-default-settings
if [ $? -ne 0 ]; then
	date_version=$(date +"%Y.%m.%d")
	orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
	sed -i "s/${orig_version}/R${date_version} by Hwliu/g" package/lean/default-settings/files/zzz-default-settings
else
	date_version=$(date +"%Y.%m.%d")
	sed -i "s/'R2.*by Hwliu/'R${date_version} by Hwliu/g" package/lean/default-settings/files/zzz-default-settings
fi

# 修改 Makefile
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/include\ \.\.\/\.\.\/luci\.mk/include \$(TOPDIR)\/feeds\/luci\/luci\.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/include\ \.\.\/\.\.\/lang\/golang\/golang\-package\.mk/include \$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang\-package\.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=\@GHREPO/PKG_SOURCE_URL:=https:\/\/github\.com/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=\@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload\.github\.com/g' {}

# 删除主题强制默认
find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;


# 移除重复软件包
#rm -rf feeds/packages/net/mosdns
#rm -rf feeds/luci/themes/luci-theme-argon
#rm -rf feeds/luci/themes/luci-theme-netgear
rm -rf feeds/luci/applications/luci-app-netdata
rm -rf feeds/luci/applications/luci-app-wrtbwmon
rm -rf feeds/luci/applications/luci-app-dockerman
#rm -rf feeds/luci/applications/luci-app-argon-config
#rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/luci/applications/luci-app-serverchan
rm -rf feeds/luci/applications/luci-app-smartdns
#超频 
#0x362=1100MHz
#0x312=1000MHz
#0x3B2=1200MHz
grep "rt_memc_w32(pll,MEMC_REG_CPU_PLL);" ./target/linux/ramips/patches-5.4/102-mt7621-fix-cpu-clk-add-clkdev.patch
if [ $? -ne 0 ]; then
echo fix over clock
sed -i 's/-111,49 +111,89/-111,49 +111,93/' ./target/linux/ramips/patches-5.4/102-mt7621-fix-cpu-clk-add-clkdev.patch
sed -i 's/u32 xtal_clk, cpu_clk, bus_clk;/u32 xtal_clk, cpu_clk, bus_clk,i;/' ./target/linux/ramips/patches-5.4/102-mt7621-fix-cpu-clk-add-clkdev.patch
sed -i '157i+		pll &= ~(0x7ff);' ./target/linux/ramips/patches-5.4/102-mt7621-fix-cpu-clk-add-clkdev.patch
sed -i '158i+		pll |=  (0x362);' ./target/linux/ramips/patches-5.4/102-mt7621-fix-cpu-clk-add-clkdev.patch
sed -i '159i+		rt_memc_w32(pll,MEMC_REG_CPU_PLL);' ./target/linux/ramips/patches-5.4/102-mt7621-fix-cpu-clk-add-clkdev.patch
sed -i '160i+		for(i=0;i<1024;i++);' ./target/linux/ramips/patches-5.4/102-mt7621-fix-cpu-clk-add-clkdev.patch
fi

grep "sleep 2s" ./package/base-files/files/etc/rc.local
if [ $? -ne 0 ]; then
sed -i '3i\
\
sleep 2s\
\# 启动2.4g 和 5g 信号\
ip link set ra0 up\
ip link set rai0 up\
\
\# 桥接网卡\
brctl addif br-lan ra0\
brctl addif br-lan rai0\
\
\# Lan Check\
lanCheck=`uci get network.lan.ifname`\
if [ $? -eq 0 ]; then\
    echo $lanCheck | grep rai0 > /dev/null\
    if [ $? -ne 0 ]; then\
        uci set network.lan.ifname="$lanCheck rai0 ra0"\
        uci commit\
        echo "Updated wireless config of LAN Interface"\
    fi\
    echo "No need to update wireless config of LAN Interface"\
else\
    echo "wireless config of LAN Interface check failed. Interface may renamed." >&2\
fi' ./package/base-files/files/etc/rc.local
fi

#!/bin/bash

target=R2100
is_debug=0
if [ $# -gt 0 ]; then
	if [ "$1"="R2100" -o "$1"="RM2100" ]; then
		target=$1
	else
		target=R2100
	fi
fi
top_dir=$PWD
echo Build openwrt firmware for $target
yml_file=$top_dir/.github/workflows/build-openwrt-$target.yml
if [ ! -e $yml_file ]; then
	echo Yaml configure file not exist
	exit
fi
echo Read config from yml
#REPO_URL
config_data=$(grep REPO_URL: $yml_file)
repo_url=${config_data#*: }
echo Openwrt source repo URL: $repo_url
#REPO_BRANCH
config_data=$(grep REPO_BRANCH: $yml_file)
repo_branch=${config_data#*: }
echo Openwrt source branch: $repo_branch
#FEEDS_CONF
config_data=$(grep FEEDS_CONF: $yml_file)
feeds_conf=${config_data#*: }
echo Source Feeds conf: $feeds_conf
#DIY_P1_SH
config_data=$(grep DIY_P1_SH: $yml_file)
diy_p1_sh=${config_data#*: }
echo Diy shell script part1: $diy_p1_sh
#DIY_P2_SH
config_data=$(grep DIY_P2_SH: $yml_file)
diy_p2_sh=${config_data#*: }
echo Diy shell script part2: $diy_p2_sh
echo $top_dir
if [ ! -e $top_dir/workdir ]; then
	mkdir -p $top_dir/workdir
fi
if [ ! -e $top_dir/workdir/openwrt ]; then
	git clone $repo_url -b $repo_branch --depth 1 $top_dir/workdir/openwrt
else
	cd $top_dir/workdir/openwrt
	git pull
	cd $top_dir
fi
[ -e $feeds_conf ] && mv $feeds_conf $top_dir/workdir/openwrt/feeds.conf.default

chmod +x $diy_p1_sh
chmod +x $diy_p2_sh
cd $top_dir/workdir/openwrt
echo execute diy script $top_dir/$diy_p1_sh
. $top_dir/$diy_p1_sh
./scripts/feeds update -a
./scripts/feeds install -a
[ -e $top_dir/files ] && mv $top_dir/files ./files
[ -e $top_dir/configs/$target.config ] && cp $top_dir/configs/$target.config ./.config
echo execute diy script $top_dir/$diy_p1_sh
. $top_dir/$diy_p2_sh
		

make defconfig

echo -e "$(nproc) thread compile"
make download -j$(nproc)
if [ $is_debug -eq 1 ]; then
	make -j1 V=s
else
	make -j$(nproc) || make -j1 || make -j1 V=s
fi
cd $top_dir

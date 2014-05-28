#!/bin/bash

echo "=========================================================="
echo "Lunix tar backup tool! Written by badb0y"
echo "=========================================================="
echo "一个通过tar备份目录的工具!"
echo ""
echo "Web http://code.google.com/p/autosetup"
echo ""
echo "=========================================================="
if [ "$1" != "--help" ] ;then
	tar_dir="test"
	echo "请输入文件名:"
	read -p "(默认文件名为:test):" tar_dir
	if [ "$tar_dir" = "" ]; then
		tar_dir="test"
	fi
	
	if [ -s $tar_dir ]; then
	echo "$tar_dir [存在]"
	else
	echo ""
	echo "$tar_dir [不存在]"
	exit 0
	fi
tar zcvf - $tar_dir >$tar_dir.tar.gz
echo "$tar_dir压缩完成!!"
fi


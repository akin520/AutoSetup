#!/bin/bash

echo "=========================================================="
echo "Lunix tar backup tool! Written by badb0y"
echo "=========================================================="
echo "һ��ͨ��tar����Ŀ¼�Ĺ���!"
echo ""
echo "Web http://code.google.com/p/autosetup"
echo ""
echo "=========================================================="
if [ "$1" != "--help" ] ;then
	tar_dir="test"
	echo "�������ļ���:"
	read -p "(Ĭ���ļ���Ϊ:test):" tar_dir
	if [ "$tar_dir" = "" ]; then
		tar_dir="test"
	fi
	
	if [ -s $tar_dir ]; then
	echo "$tar_dir [����]"
	else
	echo ""
	echo "$tar_dir [������]"
	exit 0
	fi
tar zcvf - $tar_dir >$tar_dir.tar.gz
echo "$tar_dirѹ�����!!"
fi


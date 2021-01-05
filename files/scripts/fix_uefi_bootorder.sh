#!/bin/bash
#
# Workaround for Dell 14G Servers' boot order reset "feature" after OS install
# Set PXE device as first boot device, CentOS as number two.
#
servermodel=$( /sbin/dmidecode |grep ModelName )
[[ -f /sbin/efibootmgr  ]] || { echo "This server does not have UEFI boot enabled"; exit 1; }
[[ $servermodel =~ .(FC|[RTM])[1-9][4]. ]] || { echo "This is not a Dell 14G Server"; exit 2; }
pxedevice=$(/sbin/efibootmgr | grep -i "integrated NIC" | awk '{ print $1 }' | sed 's/[^0-9]*//g')
osdevice=$(/sbin/efibootmgr | grep -i "centos" | awk '{ print $1 }' | sed 's/[^0-9]*//g')
/sbin/efibootmgr --bootorder $pxedevice,$osdevice
exit 0

#!/bin/bash
#
# Workaround for Dell 14G Servers' boot order reset "feature" after OS install
# Set PXE device as first boot device, CentOS as number two.
#
#!/bin/bash
servermodel=$( /sbin/dmidecode |grep ModelName )
[[ -f /sbin/efibootmgr  ]] || { echo "This server does not have UEFI boot enabled"; exit 0; }
[[ $servermodel =~ .(FC|[RTM])[1-9][3-5]. ]] || { echo "This is not a Dell 13G or 14G Server"; exit 0; }
if [[ ($( echo $servermodel | grep "R630" )) ||\
($( echo $servermodel | grep "R640" )) ||\
($( echo $servermodel | grep "R740" ))  ]]; then niccard=Integrated; else niccard=Embedded; fi
pxedevice=$(/sbin/efibootmgr | grep -i "$niccard NIC" | awk '{ print $1 }' | sed 's/[^0-9]*//g')
osdevice=$(/sbin/efibootmgr | grep -i "almalinux" | awk '{ print $1 }' | sed 's/[^0-9]*//g')
/sbin/efibootmgr --bootorder $pxedevice,$osdevice
exit 0

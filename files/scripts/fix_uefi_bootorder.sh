#!/bin/bash
#
# Workaround for Dell 14G Servers' boot order reset "feature" after OS install
# Set PXE device as first boot device, AlmaLinux as number two.
#

# Set proper PATH
PATH=/sbin:/bin:/usr/sbin:/usr/bin
export PATH

# Exit if not UEFI boot
if [ ! -f /sbin/efibootmgr  ]; then
    echo "This server does not have UEFI boot enabled"
    exit 0
fi

# Get server model name
servermodel=$(dmidecode -s system-product-name)

# Exit if not Dell PowerEdge 13th gen or newer
if [[ ! $servermodel =~ .(FC|[RTM])[1-9][3-5]. ]]; then
    echo "This is not a Dell 13G / 14G / 15G Server"
    exit 0
fi

# Remove duplicate OS entries (from previous reinstalls)
entries_to_delete=()
for entry in $(efibootmgr | awk '/AlmaLinux/ {print $1}' | sed 's/[^0-9]*//g'); do
    entries_to_delete+=( $entry )
done
unset entries_to_delete[-1]
for entry in ${entries_to_delete[@]}; do
    efibootmgr --bootnum $entry --delete-bootnum
done

# Get efi boot numbers
pxe_number=$(efibootmgr | awk '/(Integrated|Embedded) NIC/ {print $1}' | sed 's/[^0-9]*//g')
os_number=$(efibootmgr | awk '/AlmaLinux/ {print $1}' | sed 's/[^0-9]*//g')

# Set correct boot order
efibootmgr --bootorder $pxe_number,$os_number

# Exit gracefully
exit 0

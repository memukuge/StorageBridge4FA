#!/bin/bash -l
cd `dirname $0`
export PATH=$PATH:/usr/local/bin
/sbin/rmmod g_mass_storage

#check whether card installed
if ls -l /dev/disk/by-uuid | grep 'sda1' > /dev/null  ; then
	#card already installed
	/sbin/modprobe g_mass_storage file=/dev/sda removable=1 stall=0
	echo 2 > /sys/bus/platform/devices/sunxi_usb_udc/otg_role
	echo "1" > ./isinserted #indicate card is inserted
else
	#card is not installed
	echo "0" > ./isinserted #indicate card isn't inserted
fi

#activates cyclic scripts.
sh ./removecheck.sh &
sh ./updatecheck.sh &

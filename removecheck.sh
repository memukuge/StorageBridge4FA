#!/bin/bash -l

#removecheck.sh
#check FlashAir is inserted to /dev/sda every 1 second.

interval=1

while true ; do
  inserted=`cat ./isinserted`
  if ls -l /dev/disk/by-uuid | grep 'sda1' > /dev/null  ; then
    if [ "0" = ${inserted} ] ; then # card is inserted
      modprobe g_mass_storage file=/dev/sda removable=1 stall=0
      echo 2 > /sys/bus/platform/devices/sunxi_usb_udc/otg_role
      #echo "inserted"
      echo "1" > ./isinserted
    fi
  else
    if [ "1" = ${inserted} ] ; then
      echo 0 > /sys/bus/platform/devices/sunxi_usb_udc/otg_role
      rmmod g_mass_storage
      #echo "removed"
      echo "0" > ./isinserted
    fi
  fi #else
  sleep $interval
#echo "removecheck"
done #while

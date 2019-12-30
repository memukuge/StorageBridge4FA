#!/bin/bash -l

#removecheck.sh
#check FlashAir is inserted to /dev/sda every 1 second.

interval=1

while true; do
  inserted=$(cat /tmp/isinserted)
  if ls -l /dev/disk/by-uuid | grep 'sda1' >/dev/null; then
    if [ "0" = ${inserted} ]; then # card is inserted

      dsksizGB=$(fdisk -l /dev/sda | grep "Disk /dev/sda" | cut -f 3 -d " ")
      echo $dsksizGB > /tmp/cardsize
      bootsec=$(hexdump -n 4 -s 454 -e '"%08d"' /dev/sda) #get 1st partition boot sector.
      bootByteOffset=$(expr $bootsec \* 512)              #get Boot Sector offset byte from disk head
      echo $bootByteOffset > /tmp/bootbyteoffset

      modprobe g_mass_storage file=/dev/sda removable=1 stall=0
      echo 2 >/sys/bus/platform/devices/sunxi_usb_udc/otg_role
      #echo "inserted"
      echo "1" > /tmp/isinserted
    fi
  else
    if [ "1" = ${inserted} ]; then
      echo 0 >/sys/bus/platform/devices/sunxi_usb_udc/otg_role
      rmmod g_mass_storage
      #echo "removed"
      echo "0" > /tmp/isinserted
    fi
  fi #else
  sleep $interval
  #echo "removecheck"
done #while

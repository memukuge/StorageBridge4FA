#!/bin/bash

#disk size on GB
while true; do
  inserted=$(cat /tmp/isinserted)
  echo $inserted

  if [ "1" = ${inserted} ]; then # if card is inserted

    dsksizGB=$(cat /tmp/cardsize)
    echo $dsksizGB
    bootByteOffset=$(cat /tmp/bootbyteoffset)
    echo $dsksizGB

    if [ "$(echo " $dsksizGB < 32" | bc)" -eq 1 ]; then # less than 32GB == FAT32
      #Offset for latest allocated Cluster Number
      AllocedClstByteOffset=$(expr $bootByteOffset + 512 + 492)
      echo $AllocedClstByteOffset
      AllocedClst=$(hexdump -n 4 -s $AllocedClstByteOffset -e '"%08d"' /dev/sda)
      WrittenkB=$(iostat sda | grep "sda" | sed 's/[\t ]\+/\t/g' | cut -f 6)
      echo $WrittenkB
      while true; do

        echo 3 >/proc/sys/vm/drop_caches
        inserted=$(cat /tmp/isinserted)
        if [ "1" = ${inserted} ]; then # if card is inserted
          newAllocedClst=$(hexdump -n 4 -s $AllocedClstByteOffset -e '"%08d"' /dev/sda)
          #		echo $newAllocedClst
          if [ $AllocedClst -ne $newAllocedClst ]; then
            newWrittenkB=$(iostat sda | grep "sda" | sed 's/[\t ]\+/\t/g' | cut -f 6)
            if [ $newWrittenkB -ne $WrittenkB ]; then
              #Written by SD HOST. do nothing.
              WrittenkB=$newWrittenkB
            else
              #updated by WLAN
              #echo "updated"
              echo 0 >/sys/bus/platform/devices/sunxi_usb_udc/otg_role
              rmmod g_mass_storage
              sleep 1
              modprobe g_mass_storage file=/dev/sda removable=1 stall=0
              echo 2 >/sys/bus/platform/devices/sunxi_usb_udc/otg_role
            fi
            AllocedClst=$newAllocedClst
          fi
        else
          break
        fi

        sleep 2
      done
    else # disk size is larger than 32GB == exFAT

      ClusterAreaFieldOffset=$(expr $bootByteOffset + 88)
      ClusterAreaSectOffset=$(hexdump -n 4 -s $ClusterAreaFieldOffset -e '"%08d"' /dev/sda)
      echo $ClusterAreaSectOffset
      WrittenkB=$(iostat sda | grep "sda" | sed 's/[\t ]\+/\t/g' | cut -f 6)
      echo $WrittenkB
      dd if=/dev/sda1 of=/tmp/bmp bs=512 count=256 skip=$ClusterAreaSectOffset
      while true; do

        echo 3 >/proc/sys/vm/drop_caches
        inserted=$(cat /tmp/isinserted)
        if [ "1" = ${inserted} ]; then # if card is inserted
          dd if=/dev/sda1 of=/tmp/bmp_new bs=512 count=256 skip=$ClusterAreaSectOffset

          #diff
          if [ "$(cmp /tmp/bmp /tmp/bmp_new)" ]; then
            newWrittenkB=$(iostat sda | grep "sda" | sed 's/[\t ]\+/\t/g' | cut -f 6)
            if [ $newWrittenkB -ne $WrittenkB ]; then
              #Written by SD HOST. do nothing.
              WrittenkB=$newWrittenkB
            else
              #updated by WLAN
              #echo "updated"
              echo 0 >/sys/bus/platform/devices/sunxi_usb_udc/otg_role
              rmmod g_mass_storage
              sleep 1
              modprobe g_mass_storage file=/dev/sda removable=1 stall=0
              echo 2 >/sys/bus/platform/devices/sunxi_usb_udc/otg_role
            fi
            mv /tmp/bmp_new /tmp/bmp
          fi
				else
					break
        fi
        sleep 2
      done
    fi #disk size
  fi
  sleep 1
done

# StorageBridge4FA
scripts for single board computers to bridge USB-OTG mass storage and USB-SD reader with FlashAir W-04


# install
just kick "initialscript.sh" to make the scripts sure to run.
and add following line to crontab (fix paths below)
@reboot bash /root/StorageBridge4FA/initialscript.sh > /root/errorlog.log 2>&1

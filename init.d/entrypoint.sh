#!/bin/bash +e
# catch signals as PID 1 in a container

#check if container is running in host mode
if [[ -z `grep "docker0" /proc/net/dev` ]]; then
  echo "Container not running in host mode. Sure you configured host network mode? Container stopped."
  exit 143
fi

#check if container is running in privileged mode
ip link add dummy0 type dummy >/dev/null 2>&1
if [[ -z `grep "dummy0" /proc/net/dev` ]]; then
  echo "Container not running in privileged mode. Sure you configured privileged mode? Container stopped."
  exit 143
else
  # clean the dummy0 link
  ip link delete dummy0 >/dev/null 2>&1
fi

pid=0

# SIGNAL-handler
term_handler() {
 
 echo "stopping bluetooth daemon ..."
 if [ $pid -ne 0 ]; then
        kill -SIGTERM "$pid"
        wait "$pid"
 fi

  echo "bring hci0 down ..."
  hciconfig hci0 down
 
  echo "terminating dbus ..."
  /etc/init.d/dbus stop
  
  echo "terminating ssh ..."
  /etc/init.d/ssh stop

  exit 143; # 128 + 15 -- SIGTERM
}

# on callback, stop all started processes in term_handler
trap 'kill ${!}; term_handler' SIGINT SIGKILL SIGTERM SIGQUIT SIGTSTP SIGSTOP SIGHUP

# run applications in the background
echo "starting ssh ..."
/etc/init.d/ssh start &

# start docker deamon
echo "starting dbus ..."
/etc/init.d/dbus start

#start bluetooth daemon
/usr/libexec/bluetooth/bluetoothd -d &
pid="$!"

#reset BCM chip (making sure get access even after container restart)
/opt/vc/bin/vcmailbox 0x38041 8 8 128 0  > /dev/null
sleep 1
/opt/vc/bin/vcmailbox 0x38041 8 8 128 1  > /dev/null 
sleep 1

#load firmware to BCM chip and attach to hci0
hciattach /dev/ttyAMA0 bcm43xx 115200 noflow

#create hci0 device
hciconfig hci0 up

# wait forever not to exit the container
while true
do
  tail -f /dev/null & wait ${!}
done

exit 0

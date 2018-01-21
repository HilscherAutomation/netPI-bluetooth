#!/bin/bash +e
# catch signals as PID 1 in a container

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

#start BCM chip
hciattach /dev/ttyAMA0 bcm43xx 921600 noflow

#create hci0 device
hciconfig hci0 up

#start bluetooth daemon
/usr/libexec/bluetooth/bluetoothd -d &
pid="$!"

# wait forever not to exit the container
while true
do
  tail -f /dev/null & wait ${!}
done

exit 0

## Bluetooth

Made for Raspberry Pi 3B architecture based devices and compatibles

### Docker repository

https://hub.docker.com/r/hilschernetpi/netpi-bluetooth/

### Container features

The image provided hereunder deploys a container with latest bluetooth protocol stack to enable bluetooth communications in a container.

Base of this image builds [debian](https://www.balena.io/docs/reference/base-images/base-images/) with enabled [SSH](https://en.wikipedia.org/wiki/Secure_Shell), a source code compiled bluez stack [bluez](http://www.bluez.org/) and [firmware](https://github.com/OpenELEC/misc-firmware/tree/master/firmware/brcm) for the onboard BCM bluetooth chip BCM43438.

### Container hosts

The container has been successfully tested on the following hosts

* netPI, model RTE 3, product name NIOT-E-NPI3-51-EN-RE
* netPI, model CORE 3, product name NIOT-E-NPI3-EN
* netFIELD Connect, product name NIOT-E-TPI51-EN-RE/NFLD (disabled bluetooth service on Host OS)
* Raspberry Pi, model 3B

netPI devices specifically feature a restricted Docker protecting the system software's integrity by maximum. The restrictions are

* privileged mode is not automatically adding all host devices `/dev/` to a container
* volume bind mounts to rootfs is not supported
* the devices `/dev`,`/dev/mem`,`/dev/sd*`,`/dev/dm*`,`/dev/mapper`,`/dev/mmcblk*` cannot be added to a container

### Container setup

#### Environment variable (optional)

The container binds the SSH server port to `22` by default.

For an alternative port use the variable **SSHPORT** with the desired port number as value.

#### Network mode

The container needs to run in `host` network mode.

This mode makes port mapping unnecessary. The following TCP/UDP container ports are exposed to the host automatically

Used port | Protocol | By application | Remark
:---------|:------ |:------ |:-----
*22 or SSHPORT* | TCP | SSH service

#### Privileged mode

The privileged mode option needs to be activated to lift the standard Docker enforced container limitations. With this setting the container and the applications inside are the getting (almost) all capabilities as if running on the host directly. 

#### Host device

To grant access to the onboard BCM bluetooth chip the `/dev/ttyAMA0` host device needs to be added to the container. To prevent the container from failing to load the bluetooth chip with firmware (after soft restart), the chip is physically reset during each container start. To grant access to the reset logic the `/dev/vcio` host device needs to be added to the container.

### Container deployment

Pulling the image may take 10 minutes.

#### netPI example

STEP 1. Open netPI's website in your browser (https).

STEP 2. Click the Docker tile to open the [Portainer.io](http://portainer.io/) Docker management user interface.

STEP 3. Enter the following parameters under *Containers > + Add Container*

Parameter | Value | Remark
:---------|:------ |:------
*Image* | **hilschernetpi/netpi-bluetooth** |
*Network > Network* | **host** |
*Restart policy* | **always**
*Adv.con.set. > Env > > +add env.var.* | *name* **SSHPORT** -> *value* **any number value** | optional for different SSH port
*Adv.con.set. > Devices > +add device* | *Host path* **/dev/ttyAMA0** -> *Container path* **/dev/ttyAMA0** |
*Adv.con.set. > Devices > +add device* | *Host path* **/dev/vcio** -> *Container path* **/dev/vcio** | 
*Adv.con.set. > Privileged mode* | **On** |

STEP 4. Press the button *Actions > Start/Deploy container*

#### Docker command line example

`docker run -d --privileged --network=host --restart=always -e SSHPORT=22 --device=/dev/ttyAMA0:/dev/ttyAMA0 --device=/dev/vcio:/dev/vcio -p 22:22/tcp hilschernetpi/netpi-bluetooth`

#### Docker compose example

A `docker-compose.yml` file could look like this

    version: "2"

    services:
     nodered:
       image: hilschernetpi/netpi-bluetooth
       restart: always
       privileged: true
       network_mode: host
       ports:
         - 22:22
       devices:
         - "/dev/ttyAMA0:/dev/ttyAMA0"
         - "/dev/vcio:/dev/vcio"
       environment:
         - SSHPORT=22

### Container access

The container starts the SSH server and the bluetooth device hci0 automatically when started.

For an SSH terminal session use an SSH client such as [putty](http://www.putty.org/) with the Docker host IP address (@port number `22` or **SSHPORT**).

Use bluez tools such as bluetoothctl, hciconfig, hcitool as usual. For a simple test call [bluetoothctl](https://wiki.archlinux.org/index.php/bluetooth) to start the bluetooth interactive command utility. Input `scan on` to discover nearby bluetooth devices.

### License

Copyright (c) Hilscher Gesellschaft fuer Systemautomation mbH. All rights reserved.
Licensed under the LISENSE.txt file information stored in the project's source code repository.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).
As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.

[![N|Solid](http://www.hilscher.com/fileadmin/templates/doctima_2013/resources/Images/logo_hilscher.png)](http://www.hilscher.com)  Hilscher Gesellschaft fuer Systemautomation mbH  www.hilscher.com

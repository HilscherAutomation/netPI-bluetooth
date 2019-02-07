## Bluetooth

[![](https://images.microbadger.com/badges/image/hilschernetpi/netpi-bluetooth.svg)](https://microbadger.com/images/hilschernetpi/netpi-bluetooth "Bluetooth")
[![](https://images.microbadger.com/badges/commit/hilschernetpi/netpi-bluetooth.svg)](https://microbadger.com/images/hilschernetpi//netpi-bluetooth "Bluetooth")
[![Docker Registry](https://img.shields.io/docker/pulls/hilschernetpi/netpi-bluetooth.svg)](https://registry.hub.docker.com/u/hilschernetpi/netpi-bluetooth/)&nbsp;
[![Image last updated](https://img.shields.io/badge/dynamic/json.svg?url=https://api.microbadger.com/v1/images/hilschernetpi/netpi-bluetooth&label=Image%20last%20updated&query=$.LastUpdated&colorB=007ec6)](http://microbadger.com/images/hilschernetpi/netpi-bluetooth "Image last updated")&nbsp;

Made for [netPI](https://www.netiot.com/netpi/), the Raspberry Pi 3B Architecture based industrial suited Open Edge Connectivity Ecosystem

### Debian with SSH, dbus and latest bluez bluetooth stack 

The image provided hereunder deploys a container with latest bluetooth protocol stack to enable netPI bluetooth communications in a container.

Base of this image builds [debian](https://www.balena.io/docs/reference/base-images/base-images/) with enabled [SSH](https://en.wikipedia.org/wiki/Secure_Shell), a source code compiled bluez stack [bluez](http://www.bluez.org/) and [firmware](https://github.com/OpenELEC/misc-firmware/tree/master/firmware/brcm) for the onboard BCM bluetooth chip BCM43438.

#### Container prerequisites

##### Host network

The container needs the Docker "Host" network stack to be shared with the container. 

Hint: Using this mode makes port mapping unnecessary since all the container's used ports are exposed to the host. This is why the container's used SSH server port `22` is getting available on the host without a discrete port mapping.

##### Privileged mode

The privileged mode option needs to be activated to lift the standard Docker enforced container limitations. With this setting the container and the applications inside are the getting (almost) all capabilities as if running on the Host directly. 

netPI's secure reference software architecture prohibits root access to the Host system always. Even if priviledged mode is activated the intrinsic security of the Host Linux Kernel can not be compromised.

##### Host device

To grant access to the BCM chip the `/dev/ttyAMA0` host device needs to be exposed to the container.

To prevent the container from failing to load the BCM chip with firmware(when restarted), the BCM chip is physically reset by the container each time it is started. To grant access to the reset logic the `/dev/vcio` host device needs to be exposed to the container.

#### Getting started

STEP 1. Open netPI's website in your browser (https).

STEP 2. Click the Docker tile to open the [Portainer.io](http://portainer.io/) Docker management user interface.

STEP 3. Enter the following parameters under *Containers > + Add Container*

Parameter | Value | Remark
:---------|:------ |:------
*Image* | **hilschernetpi/netpi-bluetooth** |
*Network > Network* | **host** |
*Restart policy* | **always**
*Runtime > Devices > +add device* | *Host path* **/dev/ttyAMA0** -> *Container path* **/dev/ttyAMA0** |
*Runtime > Devices > +add device* | *Host path* **/dev/vcio** -> *Container path* **/dev/vcio** | 
*Runtime > Privileged mode* | **On** |


STEP 4. Press the button *Actions > Start/Deploy container*

Pulling the image may take a while (5-10mins). Sometimes it may take too long and a time out is indicated. In this case repeat STEP 4.

#### Accessing

The container starts the SSH server and the bluetooth device hci0 automatically.

Login to it with an SSH client such as [putty](http://www.putty.org/) using netPI's IP address at port `22`. Use the credentials `root` as user and `root` as password when asked and you are logged in as root.

Use bluez tools such as bluetoothctl, hciconfig, hcitool as usual. For a simple test call [bluetoothctl](https://wiki.archlinux.org/index.php/bluetooth) to start the bluetooth interactive command utility. Input `scan on` to discover nearby bluetooth devices.

#### Automated build

The project complies with the scripting based [Dockerfile](https://docs.docker.com/engine/reference/builder/) method to build the image output file. Using this method is a precondition for an [automated](https://docs.docker.com/docker-hub/builds/) web based build process on DockerHub platform.

DockerHub web platform is x86 CPU based, but an ARM CPU coded output file is needed for Raspberry systems. This is why the Dockerfile includes the [balena](https://balena.io/blog/building-arm-containers-on-any-x86-machine-even-dockerhub/) steps.

#### License

View the license information for the software in the project. As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).
As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.ex.php/bluetooth) to start the bluetooth interactive command utility. Input `scan on` to discover nearby bluetooth devices.

[![N|Solid](http://www.hilscher.com/fileadmin/templates/doctima_2013/resources/Images/logo_hilscher.png)](http://www.hilscher.com)  Hilscher Gesellschaft fuer Systemautomation mbH  www.hilscher.com

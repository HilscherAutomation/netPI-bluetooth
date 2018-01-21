## Bluetooth

Made for [netPI](https://www.netiot.com/netpi/), the Open Edge Connectivity Ecosystem

### Debian with SSH, dbus and latest bluez bluetooth stack 

The image provided hereunder deploys a container with latest bluetooth protocol stack to enable a bluetooth communication in a container.

Base of this image builds a tagged version of [debian:jessie](https://hub.docker.com/r/resin/armv7hf-debian/tags/) with enabled [SSH](https://en.wikipedia.org/wiki/Secure_Shell), a source code compiled bluez stack [bluez](http://www.bluez.org/) and firmware for the BCM bluetooth chip BCM43438.

#### Container prerequisites

##### Host network

The container needs the "Host" network stack to be shared with the container. 

##### Privileged mode

Only the privileged mode option lifts the enforced container limitations to allow usage of bluetooth in a container.

##### Host device

To grant access to the BCM chip the `/dev/ttyAMA0` host device needs to be exposed to the container.

#### Getting started

STEP 1. Open netPI's landing page under `https://<netpi's ip address>`.

STEP 2. Click the Docker tile to open the [Portainer.io](http://portainer.io/) Docker management user interface.

STEP 3. Enter the following parameters under **Containers > Add Container**

* **Image**: `hilschernetpi/netpi-bluetooth`

* **Network > Network**: `Host`

* **Restart policy"** : `always`

* **Runtime > Devices > add device**: `Host "/dev/ttyAMA0" -> Container "/dev/ttyAMA0"`

* **Runtime > Privileged mode** : `On`

STEP 4. Press the button **Actions > Start container**

Pulling the image from Docker Hub may take up to 5 minutes.

#### Accessing

The container starts the SSH service and the bluetooth device hci0 automatically.

Login to it with an SSH client such as [putty](http://www.putty.org/) using netPI's IP address at port `22`. Use the credentials `root` as user and `root` as password when asked and you are logged in as root.

Use bluez tools such as bluetoothctl, hciconfig, hcitool and more as usual.

#### Tags

* **hilscher/netPI-bluetooth:latest** - non-versioned latest development output of the master branch. Shouldn't be used since under development all the time.

* **hilscher/netPI-bluetooth:0.9.1.0** - runs with netPI's system software version V0.9.1.0. In this version the dbus host socket needs to be exposed to the container to run bluetooth **Volumes > Volume mapping > map additional volume** : `container: /var/run/dbus(bind)-> volume: /var/run/dbus(read/writeable)`

* **hilscher/netPI-bluetooth:1.1.0.0** - runs with netPI's system software version V1.1.0.0.


#### GitHub sources
The image is built from the GitHub project [netPI-bluetooth](https://github.com/Hilscher/netPI-bluetooth). It complies with the [Dockerfile](https://docs.docker.com/engine/reference/builder/) method to build a Docker image [automated](https://docs.docker.com/docker-hub/builds/).

To build the container for an ARM CPU on [Docker Hub](https://hub.docker.com/)(x86 based) the Dockerfile uses the method described here [resin.io](https://resin.io/blog/building-arm-containers-on-any-x86-machine-even-dockerhub/).

[![N|Solid](http://www.hilscher.com/fileadmin/templates/doctima_2013/resources/Images/logo_hilscher.png)](http://www.hilscher.com)  Hilscher Gesellschaft fuer Systemautomation mbH  www.hilscher.com

#use armv7hf compatible base image
FROM balenalib/armv7hf-debian:stretch

#enable building ARM container on x86 machinery on the web (comment out next line if built on Raspberry) 
RUN [ "cross-build-start" ]

#labeling
LABEL maintainer="netpi@hilscher.com" \
      version="V1.2.1" \
      description="Debian with bluez protocol stack"

#version
ENV HILSCHERNETPI_BLUEZ_VERSION 1.2.1
ENV BLUEZ_VERSION 5.50 

#copy files
COPY "./init.d/*" /etc/init.d/

#install prerequisites
RUN apt-get update  \
    && apt-get install -y openssh-server build-essential wget dbus git \
       libical-dev libdbus-1-dev libglib2.0-dev libreadline-dev libudev-dev systemd \
    && echo 'root:root' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && mkdir /var/run/sshd \
#get BCM chip firmware 
    && mkdir /etc/firmware \
    && curl -o /etc/firmware/BCM43430A1.hcd -L https://github.com/OpenELEC/misc-firmware/raw/master/firmware/brcm/BCM43430A1.hcd \
#get bluez source
    && wget -P /tmp/ https://www.kernel.org/pub/linux/bluetooth/bluez-${BLUEZ_VERSION}.tar.gz \
    && tar xf /tmp/bluez-${BLUEZ_VERSION}.tar.gz -C /tmp \
#compile bluez
    && cd /tmp/bluez-${BLUEZ_VERSION} \
    && ./configure --prefix=/usr \
       --mandir=/usr/share/man \
       --sysconfdir=/etc \
       --localstatedir=/var \
       --enable-library \
       --enable-experimental \
       --enable-maintainer-mode \
       --enable-deprecated \
    && make \
#install bluez
    && make install \
#install userland raspberry tools
    && git clone --depth 1 https://github.com/raspberrypi/firmware /tmp/firmware \
    && mv /tmp/firmware/hardfp/opt/vc /opt \
    && echo "/opt/vc/lib" >/etc/ld.so.conf.d/00-vmcs.conf \
    && /sbin/ldconfig \
#clean up
    && rm -rf /tmp/* \
    && apt-get remove wget \ 
    && apt-get -yqq autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

#SSH port
EXPOSE 22

#do startscript
ENTRYPOINT ["/etc/init.d/entrypoint.sh"]

#set STOPSGINAL
STOPSIGNAL SIGTERM

#stop processing ARM emulation (comment out next line if built on Raspberry)
RUN [ "cross-build-end" ]

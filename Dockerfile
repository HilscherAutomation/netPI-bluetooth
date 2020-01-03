#STEP 1 of multistage build ---Compile Bluetooth stack-----

#use armv7hf compatible base image
FROM balenalib/armv7hf-debian:buster-20191223 as builder

#enable cross compiling (comment out next line if built on Raspberry Pi) 
RUN [ "cross-build-start" ]

#environment variables
ENV BLUEZ_VERSION 5.52

RUN apt-get update && apt-get install -y \
    build-essential wget \
    libical-dev libdbus-1-dev libglib2.0-dev libreadline-dev libudev-dev systemd

RUN wget -P /tmp/ https://www.kernel.org/pub/linux/bluetooth/bluez-${BLUEZ_VERSION}.tar.gz \
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
#install bluez tools
 && make install
#disable cross compiling (comment out next line if built on Raspberry Pi) 
RUN [ "cross-build-end" ]


#STEP 2 of multistage build ----Create the final image-----

#use armv7hf compatible base image
FROM balenalib/armv7hf-debian:buster-20191223

#dynamic build arguments coming from the /hooks/build file
ARG BUILD_DATE
ARG VCS_REF

#metadata labels
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/HilscherAutomation/netPI-bluetooth" \
      org.label-schema.vcs-ref=$VCS_REF

#enable cross compiling (comment out next line if built on Raspberry Pi) 
RUN [ "cross-build-start" ]

#version
ENV HILSCHERNETPI_BLUEZ_VERSION 1.3.3

#labeling
LABEL maintainer="netpi@hilscher.com" \
      version=$HILSCHERNETPI_BLUEZ_VERSION \
      description="Bluetooth"

#install prerequisites
RUN apt-get update && apt-get install -y \
    openssh-server dbus git curl libglib2.0-dev \
#create user
 && echo 'root:root' | chpasswd \
 && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
 && mkdir /var/run/sshd \
#get BCM chip firmware 
 && mkdir /etc/firmware \
 && curl -o /etc/firmware/BCM43430A1.hcd -L https://github.com/OpenELEC/misc-firmware/raw/master/firmware/brcm/BCM43430A1.hcd \
#create folders for bluetooth tools
 && mkdir -p '/usr/bin' '/usr/libexec/bluetooth' '/usr/lib/cups/backend' '/etc/dbus-1/system.d' \
    '/usr/share/dbus-1/services' '/usr/share/dbus-1/system-services' '/usr/include/bluetooth' \
    '/usr/share/man/man1' '/usr/share/man/man8' '/usr/lib/pkgconfig' '/usr/lib/bluetooth/plugins' \
    '/lib/udev/rules.d' '/lib/systemd/system' '/usr/lib/systemd/user' '/lib/udev' \
#install userland raspberry pi tools
 && git clone -b "1.20180417" --single-branch --depth 1 https://github.com/raspberrypi/firmware /tmp/firmware \
 && mv /tmp/firmware/hardfp/opt/vc /opt \
 && echo "/opt/vc/lib" >/etc/ld.so.conf.d/00-vmcs.conf \
 && /sbin/ldconfig \
#clean up
 && rm -rf /tmp/* \
 && rm -rf /opt/vc/src \
 && apt-get remove git curl \
 && apt-get -yqq autoremove \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*
#copy files
COPY "./init.d/*" /etc/init.d/
#copy bluez tools from builder container
COPY --from=builder /usr/bin/bluetoothctl /usr/bin/btmon /usr/bin/rctest /usr/bin/l2test /usr/bin/l2ping \
                    /usr/bin/bccmd /usr/bin/bluemoon /usr/bin/hex2hcd /usr/bin/mpris-proxy /usr/bin/btattach \
                    /usr/bin/hciattach /usr/bin/hciconfig /usr/bin/hcitool /usr/bin/hcidump /usr/bin/rfcomm \
                    /usr/bin/sdptool /usr/bin/ciptool /usr/bin/
COPY --from=builder /usr/libexec/bluetooth/bluetoothd /usr/libexec/bluetooth/obexd /usr/libexec/bluetooth/
COPY --from=builder /usr/lib/cups/backend/bluetooth /usr/lib/cups/backend/
COPY --from=builder /etc/dbus-1/system.d/bluetooth.conf /etc/dbus-1/system.d/
COPY --from=builder /usr/share/dbus-1/services/org.bluez.obex.service /usr/share/dbus-1/services/
COPY --from=builder /usr/share/dbus-1/system-services/org.bluez.service /usr/share/dbus-1/system-services/
COPY --from=builder /usr/include/bluetooth/* /usr/include/bluetooth/
COPY --from=builder /usr/share/man/man1* /usr/share/man/man1/
COPY --from=builder /usr/share/man/man8/bluetoothd.8 /usr/share/man/man8/
COPY --from=builder /usr/lib/pkgconfig/bluez.pc /usr/lib/pkgconfig/
COPY --from=builder /usr/lib/bluetooth/plugins/external-dummy.so /usr/lib/bluetooth/plugins/
COPY --from=builder /usr/lib/bluetooth/plugins/external-dummy.la /usr/lib/bluetooth/plugins/
COPY --from=builder /lib/udev/rules.d/97-hid2hci.rules /lib/udev/rules.d/
COPY --from=builder /lib/systemd/system/bluetooth.service /lib/systemd/system/
COPY --from=builder /usr/lib/systemd/user/obex.service /usr/lib/systemd/user/
COPY --from=builder /lib/udev/hid2hci /lib/udev/

#SSH port
EXPOSE 22

#do startscript
ENTRYPOINT ["/etc/init.d/entrypoint.sh"]

#set STOPSGINAL
STOPSIGNAL SIGTERM

#disable cross compiling (comment out next line if built on Raspberry Pi) 
RUN [ "cross-build-end" ]

FROM ubuntu:24.04
RUN apt update && apt install 7zip wget -y
ARG SOURCES_FOLDER=/output/sources
RUN apt install git -y
COPY ./patches /patches

#COPY backup_offline/ubuntu-22.04.4-live-server-amd64.iso /assets/  
#download iso and extract kernel and initrd needed to boot
ARG ISO_FILE=ubuntu-22.04.4-live-server-amd64.iso
ARG UBUNTU_ISO=https://glua.ua.pt/pub/ubuntu-releases/22.04.4/${ISO_FILE}
RUN mkdir -p /output/assets && wget ${UBUNTU_ISO} -O /output/assets/${ISO_FILE} \
    &&  7z x /output/assets/${ISO_FILE} '-i!casper/initrd' -o/output/assets \
    &&  7z x /output/assets/${ISO_FILE} '-i!casper/vmlinuz' -o/output/assets \
    && cp /patches/autoinstall.yaml /output/assets

#download required sources to run netboot.xyz
RUN mkdir -p /output/sources \
    &&  git clone https://github.com/netbootxyz/docker-builder.git ${SOURCES_FOLDER}/docker-builder \
    && patch -d ${SOURCES_FOLDER}/docker-builder -p 1 -i /patches/docker-builder.patch \
    && git clone https://github.com/netbootxyz/netboot.xyz.git -b 2.0.79 ${SOURCES_FOLDER}/netboot.xyz \
    && patch -d ${SOURCES_FOLDER}/netboot.xyz -p 1 -i /patches/netboot.xyz.patch \
    && cp /patches/MAC-deadbeef1337.ipxe.j2 ${SOURCES_FOLDER}/netboot.xyz/roles/netbootxyz/templates/menu/MAC-deadbeef1337.ipxe.j2 \
    && git clone https://github.com/netbootxyz/webapp.git -b 0.7.1 ${SOURCES_FOLDER}/webapp

# download required sources to run dhcpd from networkboot
RUN git clone https://github.com/networkboot/docker-dhcpd.git -b v1.3.0 ${SOURCES_FOLDER}/docker-dhcpd \
    && mkdir -p output/dhcpd && cp /patches/dhcpd.conf /output/dhcpd/

CMD cp -r /output/* /data


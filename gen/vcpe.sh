#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 path/to/vcpe-image-qemux86.lxd.tar.bz2 or user@host:/path/to/vcpe-image-qemux86.lxd.tar.bz2>"
    exit 1
fi

input=$1
imagefile=$input

# Check if input matches SCP URL pattern (user@host:/path)
if [[ $input =~ ^[^@]+@[^:]+:.+ ]]; then
    # Create tmp directory if it doesn't exist
    mkdir -p ./tmp

    # Extract filename from path
    filename="${input##*/}"

    echo "Downloading file via SCP..."
    # Download file using scp
    if ! scp "$input" "./tmp/$filename"; then
        echo "SCP download failed"
        exit 1
    fi

    imagefile="./tmp/$filename"
    echo "Downloaded to $imagefile"
fi

# Verify file exists
if [ ! -f "$imagefile" ]; then
    echo "Error: File not found: $imagefile"
    exit 1
fi

imagename="${imagefile##*/}"; imagename="${imagename%.tar.bz2}"
containername="vcpe"
profilename="${containername}"
volumename="${containername}-nvram"

lxc image delete ${imagename} 2> /dev/null
lxc image import $imagefile --alias ${imagename}

echo "Configuring ${containername}"
lxc delete ${containername} -f > /dev/null 2>&1
lxc profile delete ${profilename} > /dev/null 2>&1
lxc profile copy default ${profilename} > /dev/null 2>&1

cat << EOF | lxc profile edit ${profilename}
name: ${containername}
description: "${containername}"
config:
    boot.autostart: "false"
    security.privileged: "true"
    security.nesting: "true"
    limits.memory: "512MB"
    limits.cpu: "0,1"
devices:
    root:
        path: /
        pool: default
        type: disk
        size: "512MB"
EOF

# eth0
lxc profile device add ${profilename} eth0 nic nictype=bridged parent=wan name=eth0

lxc profile device add ${profilename} erouter0 nic nictype=bridged parent=wan name=erouter0


# eth1
lxc profile device add ${profilename} eth1 nic nictype=bridged parent=lan-p1 name=eth1 vlan=1000


# nvram
if ! lxc storage volume show default $volumename > /dev/null 2>&1; then
    lxc storage volume create default $volumename size=4MB
fi
lxc profile device add $containername nvram disk pool=default source=$volumename path=/nvram 1>/dev/null
lxc launch ${imagename} ${containername} -p ${profilename}

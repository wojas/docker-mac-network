#!/bin/sh

dest=${dest:-docker.ovpn}
network=${DOCKER_NETWORK:-172.16.0.0}
netmask=${DOCKER_NETMASK:-255.240.0.0}
forward_port=${FORWARD_PORT:-13194}

if [ ! -f "/local/$dest" ]; then
    echo "*** REGENERATING ALL CONFIGS ***"
    set -ex
    #rm -rf /etc/openvpn/*
    ovpn_genconfig -u tcp://localhost
    sed -i 's|^push|#push|' /etc/openvpn/openvpn.conf
    echo localhost | ovpn_initpki nopass
    easyrsa build-client-full host nopass
    ovpn_getclient host | sed "s|localhost 1194|localhost ${forward_port}|;s|redirect-gateway.*|route ${network} ${netmask}|;" > "/tmp/out/$dest"
fi

exec ovpn_run

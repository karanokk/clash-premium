#!/bin/sh
setup(){
    TUN_DEV=utun
    CLASH_TABLE=0x162
    CLASH_MARK=0x162

    iptables -t mangle -N CLASH
    iptables -t mangle -A CLASH -d 198.18.0.0/16 -j RETURN
    iptables -t mangle -A CLASH -d 0.0.0.0/8 -j RETURN
    iptables -t mangle -A CLASH -d 10.0.0.0/8 -j RETURN
    iptables -t mangle -A CLASH -d 127.0.0.0/8 -j RETURN
    iptables -t mangle -A CLASH -d 169.254.0.0/16 -j RETURN
    iptables -t mangle -A CLASH -d 172.16.0.0/12 -j RETURN
    iptables -t mangle -A CLASH -d 192.168.0.0/16 -j RETURN
    iptables -t mangle -A CLASH -d 224.0.0.0/4 -j RETURN
    iptables -t mangle -A CLASH -d 240.0.0.0/4 -j RETURN
    iptables -t mangle -A CLASH -j MARK --set-xmark "$CLASH_MARK"
    iptables -t mangle -A PREROUTING -j CLASH

    # wait for TUN device
    while ! ip address show "$TUN_DEV" > /dev/null 2>&1; do
        sleep 1
    done
    ip rule add fwmark "$CLASH_MARK" lookup "$CLASH_TABLE"
    ip route add default dev "$TUN_DEV" table "$CLASH_TABLE"

    sysctl -w net.ipv4.conf.utun.rp_filter=0 > /dev/null
    sysctl -w net.ipv4.conf.all.rp_filter=0 > /dev/null
}

echo "1" > /proc/sys/net/ipv4/ip_forward

setup &
exec "$@"

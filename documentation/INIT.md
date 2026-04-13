## Azure
### firewalls
Set up fir

1. ssh to the bastion
1. for each firewall
    1. ssh to firewall
    1. open a root shell
        ```sh
        # enable second network interface after provisioning
        sysrc ifconfig_hn1="SYNCDHCP"

        # enable PF on boot
        sysrc pf_enable="YES"

        # enable NAT to allow forwarding of private network traffic to the internet
        sysrc gateway_enable="YES"

        # allow traffic to forward from one network interface to another
        # this might be redundant
        sysctl net.inet.ip.forwarding=1

        # load PF kernel module
        kldload pf
        ```
    1. reboot the machine
    1. add rules to /etc/pf.conf
    1. load pf configuration: `pfctl -f /etc/pf.conf`
    

### /etc/pf.conf
```
# MACROS
ext_if = "hn0"
int_if = "hn1"
client_out = "{ domain, https }"
udp_services = "{ domain, ntp }"
icmp_types = "{ echoreq, unreach }"
localnet = "192.168.0.0/16"

# TABLES

# OPTIONS

# ETHERNET FILTERING

# TRAFFIC NORMALIZATION

# QUEUEING

# TRANSLATION
nat on $ext_if from $localnet to any -> ($ext_if)

# PACKET FILTERING
block all
pass quick inet proto { tcp, udp } to any port $udp_services keep state
pass in inet proto tcp to $int_if port ssh
pass inet proto tcp from $localnet to any port $client_out \
    flags S/SA keep state
pass inet proto icmp from $localnet to any keep state
pass inet proto icmp from any to $ext_if keep state
pass inet proto icmp all icmp-type $icmp_types keep state
```
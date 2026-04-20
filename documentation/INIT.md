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
    1. `kldload pf`
    1. add rules to /etc/pf.conf
    1. turn on pf: `pftctl -e`
    1. load pf configuration: `pfctl -f /etc/pf.conf`
    

### /etc/pf.conf
```
# MACROS
ext_if = "hn0"
localnet = "192.168.0.0/16"

# TABLES

# OPTIONS
set skip on lo

# ETHERNET FILTERING

# TRAFFIC NORMALIZATION

# QUEUEING

# TRANSLATION
nat on $ext_if from $localnet to any -> ($ext_if)

# PACKET FILTERING
pass in quick all
pass out quick all
pass in on $ext_if proto tcp to ($ext_if) port 443 rdr-to 192.168.120.4 port 
```
#!/bin/bash
#limit the number of incoming tcp connections
/sbin/iptables -N syn_flood
/sbin/iptables -I INPUT -p tcp --syn -j syn_flood
/sbin/iptables -A syn_flood -p tcp -m tcpmss --mss 0:500
/sbin/iptables -A syn_flood -m limit --limit 3/s --limit-burst 10 -j RETURN
/sbin/iptables -A syn_flood -m connlimit --connlimit-above 5 -j REJECT
/sbin/iptables -A syn_flood -m hashlimit --hashlimit 1/s --hashlimit-mode dstip,dstport --hashlimit-name hosts --hashlimit-burst 3 -j RETURN
/sbin/iptables -A syn_flood -m state --state INVALID,UNTRACKED -j REJECT
/sbin/iptables -I INPUT -p tcp --dport 80 -m state --state NEW -m recent --set
/sbin/iptables -I INPUT -p tcp --dport 80 -m state --state NEW -m recent --update --seconds 60 --hitcount 5 -j REJECT
/sbin/iptables -I INPUT -p tcp -s 192.168.1.31 -m state --state NEW -m recent --update --seconds 60 --hitcount 20 -j RETURN
/sbin/iptables -A syn_flood -j DROP

#limit the incoming udp-flood protection
/sbin/iptables -N udp_flood
/sbin/iptables -A INPUT -p udp --dport 11111 -j udp_flood
/sbin/iptables -A INPUT -f -j DROP
/sbin/iptables -A udp_flood -m length --length 0:58 -j REJECT
/sbin/iptables -A udp_flood -m length --length 2401:65535 -j REJECT
/sbin/iptables -A udp_flood -m state --state NEW -m recent –update --second 1 --hitcount 10 -j RETURN
/sbin/iptables -A udp_flood -s 192.168.1.31 -m state --state NEW -m recent --update --seconds 60 --hitcount 20 -j RETURN
/sbin/iptables -A udp_flood -j DROP
#mitigation for icmp flooding --> only Allows RELATED ICMP types
/sbin/iptables -I INPUT -p icmp -m limit --limit 1/s --limit-burst 1 -j ACCEPT
/sbin/iptables -I INPUT -p icmp -m limit --limit 1/s --limit-burst 2 -j LOG --log-prefix "PING-DROP;"
/sbin/iptables -I INPUT -p icmp --icmp-type "echo-request" –m length --length 86:0xffff -j DROP
/sbin/iptables -I INPUT -p icmp -j DROP
/sbin/iptables -A OUTPUT -p icmp -j ACCEPT
/sbin/iptables -I INPUT -p icmp -m state --state RELATED -m limit --limit 3/s --limit-burst 8
/sbin/iptables -I INPUT -p icmp -m state --state ESTABLISHED -m limit --limit 3/s --limit-burst 8 -j ACCEPT
/sbin/iptables -I INPUT -p icmp --fragment -j DROP
/sbin/iptables -I INPUT -p icmp --icmp-type "echo-request" -m limit --limit 3/s --limit-burst 8 -j ACCEPT
/sbin/iptables -I INPUT -p icmp -j DROP

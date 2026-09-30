#!/bin/bash
set -e

# Jarkom Modul 2 K09 - prab
# Kondisi final konfigurasi sampai Soal 10.
# Jalankan sebagai root: bash /root/script.sh

echo "[+] Konfigurasi node prab"

# Soal 1, 3, 4, 5 - hostname, IP statis, gateway, dan resolver.
echo "prab" > /etc/hostname
hostname prab

# Resolver awal dipakai agar instalasi paket tetap bisa berjalan
# walaupun DNS internal Prab/Tedd belum aktif.
printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

cat > /etc/network/interfaces <<'EOF'
auto eth0
iface eth0 inet static
    address 10.68.3.2
    netmask 255.255.255.0
    gateway 10.68.3.1
    up printf "nameserver 10.68.3.2\nnameserver 10.68.3.3\nnameserver 192.168.122.1\n" > /etc/resolv.conf
EOF

# Terapkan konfigurasi resolver final sekarang juga.
printf "nameserver 10.68.3.2\nnameserver 10.68.3.3\nnameserver 192.168.122.1\n" > /etc/resolv.conf

# Soal 4-8 - DNS primary + forward dan reverse zone.
# Pakai resolver luar sementara untuk instalasi.
printf "nameserver 192.168.122.1\n" > /etc/resolv.conf
apt update
apt install -y bind9 bind9utils dnsutils

cat > /etc/bind/named.conf.options <<'EOF'
options {
    directory "/var/cache/bind";

    recursion yes;
    allow-query { any; };

    forwarders {
        192.168.122.1;
    };

    dnssec-validation auto;

    listen-on { any; };
    listen-on-v6 { none; };
};
EOF

cat > /etc/bind/named.conf.local <<'EOF'
zone "k09.com" {
    type master;
    file "/etc/bind/db.k09.com";
    notify yes;
    allow-transfer { 10.68.3.3; };
};

zone "2.68.10.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10.68.2";
    notify yes;
    allow-transfer { 10.68.3.3; };
};

zone "3.68.10.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10.68.3";
    notify yes;
    allow-transfer { 10.68.3.3; };
};

zone "4.68.10.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10.68.4";
    notify yes;
    allow-transfer { 10.68.3.3; };
};
EOF

cat > /etc/bind/db.k09.com <<'EOF'
$TTL 86400
@   IN SOA prab.k09.com. root.k09.com. (
        2026093003
        3600
        1800
        604800
        86400
)

@       IN NS      prab.k09.com.
@       IN NS      tedd.k09.com.
@       IN A       10.68.4.2

prab    IN A       10.68.3.2
tedd    IN A       10.68.3.3
rootkit IN A       10.68.3.1
alpha   IN A       10.68.1.2
beta    IN A       10.68.1.3
gamma   IN A       10.68.1.4
abbey   IN A       10.68.2.2
obladi  IN A       10.68.3.4
desmond IN A       10.68.3.5
oblada  IN A       10.68.3.6
molly   IN A       10.68.3.7
penny   IN A       10.68.4.2
delta   IN A       10.68.5.2
epsilon IN A       10.68.5.3

vault   IN A       10.68.3.4
vault   IN A       10.68.3.5
core    IN A       10.68.3.6
core    IN A       10.68.3.7

www     IN CNAME   penny.k09.com.
static  IN CNAME   abbey.k09.com.
EOF

cat > /etc/bind/db.10.68.2 <<'EOF'
$TTL 86400
@ IN SOA prab.k09.com. root.k09.com. (
    2026093001
    3600
    1800
    604800
    86400
)
@ IN NS prab.k09.com.
@ IN NS tedd.k09.com.
2 IN PTR abbey.k09.com.
EOF

cat > /etc/bind/db.10.68.3 <<'EOF'
$TTL 86400
@ IN SOA prab.k09.com. root.k09.com. (
    2026093001
    3600
    1800
    604800
    86400
)
@ IN NS prab.k09.com.
@ IN NS tedd.k09.com.
4 IN PTR vault.k09.com.
5 IN PTR vault.k09.com.
6 IN PTR core.k09.com.
7 IN PTR core.k09.com.
EOF

cat > /etc/bind/db.10.68.4 <<'EOF'
$TTL 86400
@ IN SOA prab.k09.com. root.k09.com. (
    2026093001
    3600
    1800
    604800
    86400
)
@ IN NS prab.k09.com.
@ IN NS tedd.k09.com.
2 IN PTR penny.k09.com.
EOF

named-checkconf
named-checkzone k09.com /etc/bind/db.k09.com
named-checkzone 2.68.10.in-addr.arpa /etc/bind/db.10.68.2
named-checkzone 3.68.10.in-addr.arpa /etc/bind/db.10.68.3
named-checkzone 4.68.10.in-addr.arpa /etc/bind/db.10.68.4

service named restart

# Resolver final setelah DNS lokal aktif.
printf "nameserver 10.68.3.2\nnameserver 10.68.3.3\nnameserver 192.168.122.1\n" > /etc/resolv.conf

echo "[+] DNS Prab selesai."

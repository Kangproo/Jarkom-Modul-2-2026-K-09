#!/bin/bash
set -e

# Jarkom Modul 2 K09 - tedd
# Kondisi final konfigurasi sampai Soal 10.
# Jalankan sebagai root: bash /root/script.sh

echo "[+] Konfigurasi node tedd"

# Soal 1, 3, 4, 5 - hostname, IP statis, gateway, dan resolver.
echo "tedd" > /etc/hostname
hostname tedd

# Resolver awal dipakai agar instalasi paket tetap bisa berjalan
# walaupun DNS internal Prab/Tedd belum aktif.
printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

cat > /etc/network/interfaces <<'EOF'
auto eth0
iface eth0 inet static
    address 10.68.3.3
    netmask 255.255.255.0
    gateway 10.68.3.1
    up printf "nameserver 10.68.3.2\nnameserver 10.68.3.3\nnameserver 192.168.122.1\n" > /etc/resolv.conf
EOF

# Terapkan konfigurasi resolver final sekarang juga.
printf "nameserver 10.68.3.2\nnameserver 10.68.3.3\nnameserver 192.168.122.1\n" > /etc/resolv.conf

# Soal 4, 6, 8 - DNS secondary/slave.
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
    type slave;
    masters { 10.68.3.2; };
    file "/var/cache/bind/db.k09.com";
};

zone "2.68.10.in-addr.arpa" {
    type slave;
    masters { 10.68.3.2; };
    file "/var/cache/bind/db.10.68.2";
};

zone "3.68.10.in-addr.arpa" {
    type slave;
    masters { 10.68.3.2; };
    file "/var/cache/bind/db.10.68.3";
};

zone "4.68.10.in-addr.arpa" {
    type slave;
    masters { 10.68.3.2; };
    file "/var/cache/bind/db.10.68.4";
};
EOF

named-checkconf
service named restart

printf "nameserver 10.68.3.2\nnameserver 10.68.3.3\nnameserver 192.168.122.1\n" > /etc/resolv.conf

echo "[+] DNS Tedd selesai. Zone akan ditarik otomatis dari Prab."

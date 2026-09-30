#!/bin/bash
set -e

# Jarkom Modul 2 K09 - rootkit
# Kondisi final konfigurasi sampai Soal 10.
# Jalankan sebagai root: bash /root/script.sh

echo "[+] Konfigurasi node rootkit"

# Soal 1-3 - Rootkit sebagai router sentral.
cat > /etc/network/interfaces <<'EOF'
auto eth0
iface eth0 inet dhcp
    up sysctl -w net.ipv4.ip_forward=1
    up iptables -t nat -C POSTROUTING -s 10.68.0.0/16 -o eth0 -j MASQUERADE 2>/dev/null || iptables -t nat -A POSTROUTING -s 10.68.0.0/16 -o eth0 -j MASQUERADE

auto eth1
iface eth1 inet static
    address 10.68.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 10.68.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 10.68.3.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 10.68.4.1
    netmask 255.255.255.0

auto eth5
iface eth5 inet static
    address 10.68.5.1
    netmask 255.255.255.0
EOF

echo "rootkit" > /etc/hostname
hostname rootkit

# Aktifkan routing segera tanpa menunggu interface di-restart.
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -C POSTROUTING -s 10.68.0.0/16 -o eth0 -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -s 10.68.0.0/16 -o eth0 -j MASQUERADE

echo "[+] Selesai. Restart node bila konfigurasi interface belum ter-apply."

#!/bin/bash
set -e

# Jarkom Modul 2 K09 - abbey
# Kondisi final konfigurasi sampai Soal 10.
# Jalankan sebagai root: bash /root/script.sh

echo "[+] Konfigurasi node abbey"

# Soal 1, 3, 4, 5 - hostname, IP statis, gateway, dan resolver.
echo "abbey" > /etc/hostname
hostname abbey

# Resolver awal dipakai agar instalasi paket tetap bisa berjalan
# walaupun DNS internal Prab/Tedd belum aktif.
printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

cat > /etc/network/interfaces <<'EOF'
auto eth0
iface eth0 inet static
    address 10.68.2.2
    netmask 255.255.255.0
    gateway 10.68.2.1
    up printf "nameserver 10.68.3.2\nnameserver 10.68.3.3\nnameserver 192.168.122.1\n" > /etc/resolv.conf
EOF

# Terapkan konfigurasi resolver final sekarang juga.
printf "nameserver 10.68.3.2\nnameserver 10.68.3.3\nnameserver 192.168.122.1\n" > /etc/resolv.conf

echo "[+] Selesai. Restart node bila IP belum ter-apply."

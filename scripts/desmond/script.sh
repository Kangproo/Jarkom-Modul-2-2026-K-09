#!/bin/bash
set -e

# Jarkom Modul 2 K09 - desmond
# Kondisi final konfigurasi sampai Soal 10.
# Jalankan sebagai root: bash /root/script.sh

echo "[+] Konfigurasi node desmond"

# Soal 1, 3, 4, 5 - hostname, IP statis, gateway, dan resolver.
echo "desmond" > /etc/hostname
hostname desmond

# Resolver awal dipakai agar instalasi paket tetap bisa berjalan
# walaupun DNS internal Prab/Tedd belum aktif.
printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

cat > /etc/network/interfaces <<'EOF'
auto eth0
iface eth0 inet static
    address 10.68.3.5
    netmask 255.255.255.0
    gateway 10.68.3.1
    up printf "nameserver 10.68.3.2\nnameserver 10.68.3.3\nnameserver 192.168.122.1\n" > /etc/resolv.conf
EOF

# Terapkan konfigurasi resolver final sekarang juga.
printf "nameserver 10.68.3.2\nnameserver 10.68.3.3\nnameserver 192.168.122.1\n" > /etc/resolv.conf

# Soal 9 - web statis Vault menggunakan Apache.
printf "nameserver 192.168.122.1\n" > /etc/resolv.conf
apt update
apt install -y apache2

mkdir -p /var/www/html/arsip
echo "Arsip dari Desmond" > /var/www/html/arsip/desmond.txt
echo "Dokumen Vault" > /var/www/html/arsip/dokumen.txt

cat > /etc/apache2/sites-available/vault.conf <<'EOF'
<VirtualHost *:80>
    ServerName vault.k09.com
    DocumentRoot /var/www/html

    <Directory /var/www/html/arsip>
        Options +Indexes
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
EOF

a2ensite vault.conf
a2dissite 000-default.conf || true

echo "ServerName vault.k09.com" > /etc/apache2/conf-available/servername.conf
a2enconf servername

apache2ctl configtest
service apache2 restart

printf "nameserver 10.68.3.2\nnameserver 10.68.3.3\nnameserver 192.168.122.1\n" > /etc/resolv.conf

echo "[+] Web Vault desmond selesai."

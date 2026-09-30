#!/bin/bash
set -e

# Jarkom Modul 2 K09 - molly
# Kondisi final konfigurasi sampai Soal 10.
# Jalankan sebagai root: bash /root/script.sh

echo "[+] Konfigurasi node molly"

# Soal 1, 3, 4, 5 - hostname, IP statis, gateway, dan resolver.
echo "molly" > /etc/hostname
hostname molly

# Resolver awal dipakai agar instalasi paket tetap bisa berjalan
# walaupun DNS internal Prab/Tedd belum aktif.
printf "nameserver 192.168.122.1\n" > /etc/resolv.conf

cat > /etc/network/interfaces <<'EOF'
auto eth0
iface eth0 inet static
    address 10.68.3.7
    netmask 255.255.255.0
    gateway 10.68.3.1
    up printf "nameserver 10.68.3.2\nnameserver 10.68.3.3\nnameserver 192.168.122.1\n" > /etc/resolv.conf
EOF

# Terapkan konfigurasi resolver final sekarang juga.
printf "nameserver 10.68.3.2\nnameserver 10.68.3.3\nnameserver 192.168.122.1\n" > /etc/resolv.conf

# Soal 10 - web dinamis Core menggunakan Nginx + PHP-FPM.
printf "nameserver 192.168.122.1\n" > /etc/resolv.conf
apt update
apt install -y nginx php-fpm

cat > /var/www/html/index.php <<'EOF'
<!DOCTYPE html>
<html>
<head><title>Core K09</title></head>
<body>
    <h1>Core K09</h1>
    <p>Halaman beranda dari <?php echo gethostname(); ?>.</p>
    <a href="/profil">Profil</a>
</body>
</html>
EOF

cat > /var/www/html/profil.php <<'EOF'
<!DOCTYPE html>
<html>
<head><title>Profil Core</title></head>
<body>
    <h1>Profil Core K09</h1>
    <p>Halaman profil dari <?php echo gethostname(); ?>.</p>
</body>
</html>
EOF

cat > /etc/nginx/sites-available/core <<'EOF'
server {
    listen 80;
    server_name core.k09.com;

    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location = /profil {
        rewrite ^/profil$ /profil.php last;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}
EOF

ln -sf /etc/nginx/sites-available/core /etc/nginx/sites-enabled/core
rm -f /etc/nginx/sites-enabled/default

service php8.4-fpm restart
nginx -t
service nginx restart

printf "nameserver 10.68.3.2\nnameserver 10.68.3.3\nnameserver 192.168.122.1\n" > /etc/resolv.conf

echo "[+] Web Core selesai."

#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd

# Placeholder pendant le déploiement
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html><head><meta charset="UTF-8">
<title>Azur Palace - Chargement...</title>
<style>
body{margin:0;background:#0a0a0a;display:flex;align-items:center;justify-content:center;height:100vh;font-family:Georgia,serif;}
.box{text-align:center;color:#fff;}
.logo{color:#d4af37;font-size:2rem;letter-spacing:4px;text-transform:uppercase;margin-bottom:16px;}
p{color:#888;letter-spacing:2px;font-size:0.85rem;}
</style></head>
<body><div class="box">
<div class="logo">Azur Palace</div>
<p>SERVEUR EN COURS DE CONFIGURATION...</p>
<p style="margin-top:8px;color:#d4af37;">AWS EC2 — Apache actif</p>
</div></body></html>
EOF

# Créer /data pour le volume EBS
mkdir -p /data
echo "Volume EBS pret - $(date)" > /data/readme.txt
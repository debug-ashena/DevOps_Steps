#!/bin/bash

echo "====== Starting DevOps VM Provisioning ======"

# آپدیت و ارتقای سیستم
sudo apt-get update
sudo apt-get upgrade -y

# نصب ابزارهای ضروری DevOps
echo "Installing base tools..."
sudo apt-get install -y \
    git \
    curl \
    wget \
    htop \
    tree \
    net-tools

# نصب Python و pip
echo "Installing Python..."
sudo apt-get install -y python3 python3-pip python3-venv

# نصب و راه‌اندازی Nginx برای نمایش نتیجه
echo "Installing Nginx..."
sudo apt-get install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# ایجاد یک صفحه وب ساده برای تأیید نصب
sudo tee /var/www/html/index.html > /dev/null <<'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>DevOps VM - Success!</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .success { color: green; font-weight: bold; }
        .info-box { background: #f0f0f0; padding: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1 class="success">✅ DevOps VM Provisioning Successful!</h1>
    <div class="info-box">
        <h3>Installed Tools:</h3>
        <ul>
            <li>Git: $(git --version 2>/dev/null | head -1)</li>
            <li>Python: $(python3 --version 2>/dev/null)</li>
            <li>Nginx: $(nginx -v 2>&1 | head -1)</li>
        </ul>
        <p><strong>Provisioning time:</strong> $(date)</p>
    </div>
    <p>This page is served from inside the Vagrant VM.</p>
</body>
</html>
HTML

# ایجاد فایل مارک برای تأیید
echo "DevOps tools provisioned on $(date)" | sudo tee 
/etc/devops-provisioned.txt

echo "====== Provisioning Complete! ======"
echo "VM is ready with Git, Python, Nginx and other tools."

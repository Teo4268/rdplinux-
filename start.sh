#!/bin/bash

# Thoát nếu có lỗi xảy ra
set -e

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Vui lòng chạy script này với quyền root!"
  exit 1
fi

# Cài đặt Fluxbox
echo "Cài đặt Fluxbox..."
apt update
apt install -y fluxbox

# Cài đặt Chrome Remote Desktop (CRD)
echo "Cài đặt Chrome Remote Desktop..."
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
dpkg -i chrome-remote-desktop_current_amd64.deb || apt-get -f install -y

# Thêm nhóm người dùng cho CRD
groupadd chrome-remote-desktop || true

# Tạo user 'root' với mật khẩu '123456'
echo "Tạo user root..."
useradd -m -s /bin/bash root || true
echo "root:123456" | chpasswd
usermod -aG chrome-remote-desktop root

# Cấu hình Chrome Remote Desktop cho Fluxbox
echo "Cấu hình Chrome Remote Desktop..."
CRD_CONFIG="/etc/chrome-remote-desktop-session"
echo "exec /usr/bin/startfluxbox" > "$CRD_CONFIG"
chmod +x "$CRD_CONFIG"

# Cài đặt các phụ thuộc cho giao diện từ xa (Xfce/X11 nếu cần)
echo "Cài đặt các gói phụ thuộc cho giao diện từ xa..."
apt install -y xfce4-session x11-xserver-utils

# Tự động khởi động CRD
systemctl enable chrome-remote-desktop@$USER

# Dọn dẹp file cài đặt
rm -f chrome-remote-desktop_current_amd64.deb

echo "Hoàn thành! Hãy thêm máy này vào Chrome Remote Desktop qua liên kết: https://remotedesktop.google.com/access/"

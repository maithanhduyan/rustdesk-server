#!/bin/bash

# RustDesk Server Quick Setup Guide
# Hướng dẫn cài đặt nhanh RustDesk Server

echo "========================================"
echo "🚀 RustDesk Server - Hướng dẫn cài đặt"
echo "========================================"
echo ""

# Check system information
echo "📋 Thông tin hệ thống:"
echo "- OS: $(lsb_release -d -s 2>/dev/null || echo "Unknown")"
echo "- Kernel: $(uname -r)"
echo "- Architecture: $(uname -m)"
echo "- Memory: $(free -h | awk '/^Mem:/ {print $2}')"
echo "- Disk: $(df -h / | awk 'NR==2 {print $4}') available"
echo ""

# Check if running on Ubuntu
if ! command -v lsb_release &> /dev/null || ! lsb_release -i | grep -q Ubuntu; then
    echo "⚠️  Cảnh báo: Script này được thiết kế cho Ubuntu. Có thể cần điều chỉnh cho hệ điều hành khác."
    echo ""
fi

# Check internet connectivity
echo "🌐 Kiểm tra kết nối internet..."
if ping -c 1 google.com &> /dev/null; then
    echo "✅ Kết nối internet OK"
else
    echo "❌ Không có kết nối internet. Vui lòng kiểm tra kết nối."
    exit 1
fi

# Get public IP
echo ""
echo "🔍 Phát hiện địa chỉ IP công khai..."
PUBLIC_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || curl -s --connect-timeout 5 ipinfo.io/ip 2>/dev/null || echo "")

if [ -n "$PUBLIC_IP" ]; then
    echo "✅ IP công khai: $PUBLIC_IP"
else
    echo "⚠️  Không thể phát hiện IP công khai tự động."
    echo "   Bạn sẽ cần nhập thủ công khi chạy script cài đặt."
fi

echo ""
echo "📋 Yêu cầu hệ thống:"
echo "✅ Ubuntu 18.04+ (Recommended: 20.04+)"
echo "✅ Tối thiểu 1GB RAM (Recommended: 2GB+)"
echo "✅ Tối thiểu 10GB dung lượng trống"
echo "✅ Quyền sudo"
echo "✅ Kết nối internet ổn định"
echo ""

echo "🔧 Các cổng sẽ được sử dụng:"
echo "- 21115/TCP (hbbs)"
echo "- 21116/UDP (hbbs ID server)"
echo "- 21117/TCP (hbbs relay)"
echo "- 21118/TCP (hbbr)"
echo ""

echo "📁 Cấu trúc thư mục sau khi cài đặt:"
echo "/home/rustdesk-server/"
echo "├── docker-compose.yml    # Cấu hình Docker"
echo "├── install.sh           # Script cài đặt"
echo "├── data/                # Dữ liệu server (keys, logs)"
echo "├── tests/               # Scripts kiểm tra"
echo "└── README.md            # Hướng dẫn chi tiết"
echo ""

# Check if already installed
if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
    echo "ℹ️  Docker và Docker Compose đã được cài đặt."
    if docker ps | grep -q rustdesk; then
        echo "ℹ️  RustDesk server có vẻ đã đang chạy."
        echo ""
        echo "🔧 Các lệnh quản lý:"
        echo "- Xem trạng thái: docker-compose ps"
        echo "- Xem logs: docker-compose logs -f"
        echo "- Khởi động lại: docker-compose restart"
        echo "- Dừng server: docker-compose down"
        echo ""
        exit 0
    fi
else
    echo "ℹ️  Docker chưa được cài đặt. Script sẽ tự động cài đặt."
fi

echo ""
echo "🚀 Sẵn sàng cài đặt RustDesk Server!"
echo ""
echo "Các bước thực hiện:"
echo "1. Cài đặt Docker và Docker Compose (nếu cần)"
echo "2. Cấu hình firewall"
echo "3. Thiết lập RustDesk server"
echo "4. Khởi động các container"
echo "5. Kiểm tra và xác minh"
echo ""

read -p "Bấm Enter để tiếp tục cài đặt hoặc Ctrl+C để hủy..."

echo ""
echo "🔄 Bắt đầu cài đặt..."
echo ""

# Run the installation script
if [ -f "./install.sh" ]; then
    ./install.sh
else
    echo "❌ Không tìm thấy file install.sh"
    echo "Vui lòng đảm bảo bạn đang ở thư mục /home/rustdesk-server/"
    exit 1
fi

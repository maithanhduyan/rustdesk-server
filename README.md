# RustDesk Server Installation Guide

RustDesk là một phần mềm desktop remote mã nguồn mở, tương tự TeamViewer. Hướng dẫn này sẽ giúp bạn cài đặt RustDesk Server trên Ubuntu.

## Yêu cầu hệ thống

- Ubuntu 18.04 LTS trở lên
- Tối thiểu 1GB RAM
- 10GB dung lượng trống
- Kết nối internet ổn định
- Quyền sudo

## Cài đặt tự động

### Bước 1: Tải và chạy script cài đặt

```bash
# Di chuyển đến thư mục rustdesk-server
cd /home/rustdesk-server

# Cấp quyền thực thi cho script
chmod +x install.sh

# Chạy script cài đặt
./install.sh
```

Script sẽ tự động:
- Cài đặt Docker và Docker Compose (nếu chưa có)
- Phát hiện địa chỉ IP công khai
- Cấu hình docker-compose.yml
- Thiết lập firewall
- Khởi động RustDesk server

### Bước 2: Kiểm tra trạng thái

```bash
# Kiểm tra container đang chạy
docker-compose ps

# Xem logs
docker-compose logs -f
```

## Cài đặt thủ công

### Bước 1: Cài đặt Docker

```bash
# Cập nhật package
sudo apt update

# Cài đặt dependencies
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Thêm Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Thêm Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Cài đặt Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Thêm user vào docker group
sudo usermod -aG docker $USER
```

### Bước 2: Cài đặt Docker Compose

```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Bước 3: Cấu hình RustDesk Server

```bash
# Tạo thư mục data
mkdir -p data

# Lấy IP công khai
PUBLIC_IP=$(curl -s ifconfig.me)

# Cập nhật docker-compose.yml
sed -i "s/YOUR_PUBLIC_IP/$PUBLIC_IP/g" docker-compose.yml
```

### Bước 4: Cấu hình Firewall

```bash
# Mở các port cần thiết
sudo ufw allow 21115/tcp
sudo ufw allow 21116/udp
sudo ufw allow 21117/tcp
sudo ufw allow 21118/tcp
```

### Bước 5: Khởi động Server

```bash
docker-compose up -d
```

## Cấu hình Client

Sau khi server đã chạy, bạn cần cấu hình client RustDesk:

1. Tải RustDesk client từ [https://rustdesk.com/](https://rustdesk.com/)
2. Mở RustDesk client
3. Nhấp vào biểu tượng **⚙️** (Settings)
4. Chọn **Network**
5. Nhập thông tin server:
   - **ID Server**: `YOUR_PUBLIC_IP:21116`
   - **Relay Server**: `YOUR_PUBLIC_IP:21117`
6. Nhấp **OK**

## Quản lý Server

### Các lệnh hữu ích

```bash
# Khởi động server
docker-compose up -d

# Dừng server
docker-compose down

# Khởi động lại server
docker-compose restart

# Xem logs
docker-compose logs -f

# Xem trạng thái containers
docker-compose ps

# Cập nhật image
docker-compose pull
docker-compose up -d
```

### Backup và Restore

```bash
# Backup dữ liệu
tar -czf rustdesk-backup-$(date +%Y%m%d).tar.gz data/

# Restore dữ liệu
tar -xzf rustdesk-backup-YYYYMMDD.tar.gz
```

## Cấu hình nâng cao

### SSL/TLS (HTTPS)

Để sử dụng SSL, bạn cần:
1. Có domain name trỏ về server
2. Cài đặt reverse proxy (nginx)
3. Sử dụng Let's Encrypt để có SSL certificate

### Tùy chỉnh cấu hình

Chỉnh sửa `docker-compose.yml` để:
- Thay đổi port
- Thêm environment variables
- Cấu hình logging
- Giới hạn tài nguyên

## Troubleshooting

### Lỗi thường gặp

1. **Container không khởi động được**
   ```bash
   docker-compose logs
   ```

2. **Không kết nối được từ client**
   - Kiểm tra firewall
   - Kiểm tra IP public
   - Kiểm tra port forwarding (nếu dùng NAT)

3. **Performance kém**
   - Kiểm tra tài nguyên server
   - Kiểm tra băng thông mạng
   - Tối ưu cấu hình Docker

### Logs và Monitoring

```bash
# Xem logs realtime
docker-compose logs -f

# Xem logs của container cụ thể
docker logs rustdesk-hbbs
docker logs rustdesk-hbbr

# Kiểm tra tài nguyên
docker stats
```

## Bảo mật

### Các biện pháp bảo mật cơ bản

1. **Firewall**: Chỉ mở các port cần thiết
2. **SSH**: Disable root login, sử dụng key authentication
3. **Updates**: Thường xuyên cập nhật hệ thống
4. **Monitoring**: Theo dõi logs và traffic

### Thay đổi key mặc định

```bash
# Tạo key mới
openssl rand -hex 16

# Cập nhật trong docker-compose.yml
# Thay thế -k _ bằng -k YOUR_NEW_KEY
```

## Hiệu năng

### Tối ưu hiệu năng

1. **Hardware**: 
   - CPU: 2+ cores
   - RAM: 2GB+
   - Network: 100Mbps+

2. **Software**:
   - Sử dụng SSD
   - Tối ưu kernel parameters
   - Giới hạn tài nguyên container

## Liên hệ và hỗ trợ

- **RustDesk Official**: [https://rustdesk.com/](https://rustdesk.com/)
- **GitHub**: [https://github.com/rustdesk/rustdesk](https://github.com/rustdesk/rustdesk)
- **Documentation**: [https://rustdesk.com/docs/](https://rustdesk.com/docs/)

---

**Lưu ý**: Hướng dẫn này phù hợp với Ubuntu 18.04+ và có thể cần điều chỉnh cho các phiên bản khác.
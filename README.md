# 🚀 Script Cài Đặt N8N Multi-Domain Tự Động 2025 - Enhanced Version 3.0

![N8N](https://img.shields.io/badge/N8N-Automation-blue) ![Docker](https://img.shields.io/badge/Docker-Containerized-blue) ![SSL](https://img.shields.io/badge/SSL-Auto-green) ![Multi-Domain](https://img.shields.io/badge/Multi--Domain-Support-orange) ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-blue) ![API](https://img.shields.io/badge/News%20API-FastAPI-red) ![Telegram](https://img.shields.io/badge/Telegram-Bot-blue) ![Google Drive](https://img.shields.io/badge/Google%20Drive-Backup-green)

Script tự động cài đặt N8N với đầy đủ tính năng mở rộng và quản lý từ xa, bao gồm:

## ✨ Tính Năng Mới Version 3.0

### 🤖 Telegram Bot Management
- **Quản lý từ xa hoàn toàn** qua Telegram
- **Real-time monitoring** và alerts
- **Quick actions**: restart, backup, logs, health check
- **Performance metrics** realtime
- **Security**: Chỉ Chat ID được ủy quyền

### ☁️ Google Drive Auto Backup
- **Tự động upload** backup lên Google Drive
- **Folder structure** theo năm/tháng/domain
- **Easy restore** từ Google Drive
- **OAuth2 authentication** bảo mật
- **Cross-platform** access

### 📊 Web Dashboard
- **Browser-based** management interface
- **Real-time charts** và metrics
- **Mobile responsive** design
- **Quick actions** và troubleshooting
- **Multi-user** support ready

### 🔒 Enhanced Security
- **Basic Authentication** cho N8N instances
- **IP filtering** và whitelist
- **Fail2ban** protection
- **SSL security headers**
- **Rate limiting** advanced

### 🌐 Multi-Domain Support
- **Nhiều N8N instances** trên cùng một server
- **Chia sẻ tài nguyên** hiệu quả (News API, PostgreSQL)
- **Quản lý tập trung** backup và monitoring
- **SSL tự động** cho tất cả domains

### 🐘 PostgreSQL Database Support
- **Hiệu suất cao** hơn SQLite
- **Concurrent connections** tốt hơp
- **Backup và restore** dễ dàng
- **Chia sẻ database** giữa các instances
- **Hoàn toàn miễn phí**

## 👨‍💻 Thông Tin Tác Giả

**Nguyễn Ngọc Thiện**
- 📺 **YouTube**: [Kalvin Thien Social](https://www.youtube.com/@kalvinthiensocial?sub_confirmation=1) - **HẢY ĐĂNG KÝ ĐỂ ỦNG HỘ!**
- 📘 **Facebook**: [Ban Thien Handsome](https://www.facebook.com/Ban.Thien.Handsome/)
- 📱 **Zalo/Phone**: 08.8888.4749
- 🎬 **N8N Playlist**: [N8N Tutorials](https://www.youtube.com/@kalvinthiensocial/playlists)
- 🚀 **Ngày cập nhật**: 28/06/2025
- 🆕 **Phiên bản**: 3.0 Enhanced - Telegram Bot + Google Drive + Web Dashboard

## 🖥️ Hỗ Trợ Môi Trường

✅ **Ubuntu VPS/Server** (Recommend)  
✅ **Ubuntu on Windows WSL**  
✅ **Ubuntu Docker Environment**  
✅ **Tự động detect** và xử lý môi trường

## 📋 Yêu Cầu Hệ Thống

### Cơ Bản
- **OS**: Ubuntu 20.04+ (VPS hoặc WSL)
- **RAM**: Tối thiểu 2GB (khuyến nghị 4GB+ cho multi-domain)
- **Disk**: 20GB+ free space
- **Network**: Domains đã trỏ về server
- **Permission**: Root access

### Enhanced Features
- **RAM**: Khuyến nghị 4GB+ (mỗi N8N instance ~512MB)
- **CPU**: 2+ cores cho hiệu suất tốt
- **Disk**: 30GB+ cho nhiều instances + backups
- **Google Account**: Cho Google Drive backup (optional)
- **Telegram Bot**: Cho remote management (optional)

## 🚀 Cài Đặt Nhanh

### 1️⃣ Cài Đặt Cơ Bản (Single Domain)

```bash
cd /tmp && curl -sSL https://raw.githubusercontent.com/KalvinThien/install-n8n-ffmpeg/main/auto_install_multi_n8n.sh | tr -d '\r' > install_n8n.sh && chmod +x install_n8n.sh && sudo bash install_n8n.sh
```

### 2️⃣ Cài Đặt Multi-Domain + PostgreSQL

```bash
cd /tmp && curl -sSL https://raw.githubusercontent.com/KalvinThien/install-n8n-ffmpeg/main/auto_install_multi_n8n.sh | tr -d '\r' > install_n8n.sh && chmod +x install_n8n.sh && sudo bash install_n8n.sh --multi-domain --postgresql
```

### 3️⃣ Cài Đặt Full Features

```bash
cd /tmp && curl -sSL https://raw.githubusercontent.com/KalvinThien/install-n8n-ffmpeg/main/auto_install_multi_n8n.sh | tr -d '\r' > install_n8n.sh && chmod +x install_n8n.sh && sudo bash install_n8n.sh --multi-domain --postgresql --google-drive --telegram-bot
```

### 4️⃣ Options Nâng Cao

```bash
# Multi-domain với PostgreSQL
sudo ./auto_install_multi_n8n.sh -m -p

# Full features với Google Drive và Telegram Bot
sudo ./auto_install_multi_n8n.sh -m -p -g -t

# Clean install với full features
sudo ./auto_install_multi_n8n.sh --clean --multi-domain --postgresql --google-drive --telegram-bot

# Xem trợ giúp
./auto_install_multi_n8n.sh -h
```

## 🔧 Quá Trình Cài Đặt

Script sẽ hướng dẫn bạn qua các bước:

### Installation Modes
1. **Single Domain** (Cơ bản)
2. **Multi-Domain** (Nâng cao)
3. **Multi-Domain + PostgreSQL** (Khuyến nghị)
4. **Full Features** (Multi-Domain + PostgreSQL + Google Drive + Telegram Bot)

### Setup Process
1. **Setup Swap** tự động (tăng cường cho multi-domain)
2. **Nhập domains** (single hoặc multiple)
3. **Cấu hình PostgreSQL** (nếu được chọn)
4. **Cấu hình News API** (tùy chọn)
5. **Cấu hình Telegram** (tùy chọn)
6. **Cấu hình Google Drive** (nếu được chọn)
7. **Cấu hình Telegram Bot** (nếu được chọn)
8. **Kiểm tra DNS** cho tất cả domains
9. **Cài đặt Docker** & dependencies
10. **Build & start** tất cả containers
11. **Setup SSL** cho tất cả domains
12. **Thiết lập services** (Dashboard, Telegram Bot)

## 🤖 Telegram Bot Management

### 🔧 Lệnh Bot Cơ Bản
```
/start          - Khởi động bot
/status         - Trạng thái tất cả instances
/health         - Health check chi tiết
/performance    - Performance metrics
/help           - Danh sách lệnh
```

### 🛠️ Quản Lý Services
```
/restart all              - Restart tất cả services
/restart n8n              - Restart N8N container
/restart caddy            - Restart Caddy proxy
/restart postgres         - Restart PostgreSQL
```

### 📋 Logs & Monitoring
```
/logs all                 - Logs tất cả services
/logs n8n 50              - 50 dòng logs cuối của N8N
/backup                   - Chạy backup manual
/troubleshoot             - Chạy diagnostic
```

### 📊 Ví Dụ Output
```
🚀 N8N System Status

📊 System Info:
• Uptime: up 2 days, 14 hours, 32 minutes
• Memory: 2.1G/4.0G
• Disk Usage: 45%

🌐 Domains (3):
• Instance 1: n8n1.example.com
• Instance 2: n8n2.example.com  
• Instance 3: n8n3.example.com

🐳 Containers (5):
✅ n8n-container-1: running
✅ n8n-container-2: running
✅ caddy-proxy: running
✅ postgres-n8n: running
```

## ☁️ Google Drive Backup System

### 🔧 Thiết Lập Google Drive API
1. Truy cập [Google Cloud Console](https://console.developers.google.com/)
2. Tạo project mới hoặc chọn project có sẵn
3. Enable Google Drive API
4. Tạo Service Account credentials
5. Download JSON credentials file
6. Share Google Drive folder với service account

### 📁 Cấu Trúc Backup
```
N8N-Backups/
├── 2025/
│   ├── 06-June/
│   │   ├── domain1.com/
│   │   │   ├── n8n_backup_20250628_140000.zip
│   │   │   └── n8n_backup_20250627_020000.zip
│   │   ├── domain2.com/
│   │   └── All-Domains/
│   └── 07-July/
└── 2024/
```

### 🔄 Auto Backup Features
- **Daily upload** lên Google Drive
- **Organized by** year/month/domain
- **Automatic cleanup** old backups
- **Telegram notifications** với status
- **Fallback local** nếu upload thất bại

## 📊 Web Dashboard

### 🌐 Truy Cập Dashboard
```
http://YOUR_SERVER_IP:8080
```

### 📈 Tính Năng Dashboard
- **Real-time monitoring** tất cả instances
- **System metrics** (CPU, Memory, Disk, Network)
- **Container status** với health checks
- **SSL certificate** monitoring
- **Backup status** và history
- **Quick actions** (restart, backup, logs)
- **Mobile responsive** design
- **Auto-refresh** every 30 seconds

### 🔧 Quick Actions
- 🔄 **Refresh Data** - Cập nhật realtime
- 🔄 **Restart All** - Restart tất cả services
- 💾 **Manual Backup** - Chạy backup manual
- 📋 **View Logs** - Xem logs trong tab mới
- ⬆️ **Update System** - Update hệ thống
- 🔧 **Troubleshoot** - Chạy diagnostic script

## 📰 News Content API

### 🔑 Authentication
Tất cả API calls yêu cầu Bearer Token:
```bash
Authorization: Bearer YOUR_TOKEN_HERE
```

### 📖 API Documentation
Sau khi cài đặt, truy cập:
- **Homepage**: `https://api.yourdomain.com/`
- **Swagger UI**: `https://api.yourdomain.com/docs`
- **ReDoc**: `https://api.yourdomain.com/redoc`

### 💻 Ví Dụ cURL
```bash
# Lấy nội dung bài viết
curl -X POST "https://api.yourdomain.com/extract-article" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -d '{
       "url": "https://dantri.com.vn/the-gioi.htm",
       "language": "vi",
       "extract_images": true,
       "summarize": true
     }'
```

## 💾 Enhanced Backup & Restore System

### 🔄 Multi-Domain Backup Features
- **ZIP compression** tối ưu dung lượng
- **Multi-domain backup** tất cả instances cùng lúc
- **PostgreSQL databases** backup riêng từng instance
- **SSL certificates** backup và restore
- **Configuration files** backup
- **Metadata** chi tiết cho mỗi backup

### 📱 Telegram Integration
- **Detailed reports** về tất cả instances
- **File upload** nếu <50MB
- **Status notifications** success/failure
- **Fallback**: Giữ backup local nếu Telegram thất bại

### ☁️ Google Drive Integration
- **Auto-upload** sau mỗi backup
- **Organized folders** theo domain và ngày
- **Easy restore** từ Google Drive
- **Cross-platform** access

### 🔄 Restore System
```bash
# Restore từ backup file
/home/n8n/restore-from-backup.sh /path/to/backup.zip

# Restore domain cụ thể
/home/n8n/restore-from-backup.sh /path/to/backup.zip domain.com

# Restore sẽ:
# 1. Stop tất cả services
# 2. Restore configuration files
# 3. Restore SSL certificates
# 4. Restore PostgreSQL databases
# 5. Restore N8N instances data
# 6. Import workflows và credentials
# 7. Start tất cả services
```

## 🔒 Enhanced Security Features

### 🔐 Basic Authentication
- **Auto-generated** username/password cho N8N
- **Secure storage** credentials
- **Easy rotation** passwords

### 🛡️ IP Filtering
- **Whitelist** allowed IP addresses
- **CIDR block** support
- **Easy configuration** via file

### 🚫 Fail2ban Protection
- **Auto-ban** malicious IPs
- **Custom rules** cho N8N
- **Configurable** ban times

### 🔒 SSL Security Headers
- **HSTS** enforcement
- **XSS protection**
- **Content Security Policy**
- **Frame protection**

## 🛠️ Quản Lý Hệ Thống

### 🔧 Lệnh Cơ Bản
```bash
# Xem trạng thái tất cả containers
cd /home/n8n && docker-compose ps

# Xem logs realtime tất cả services
cd /home/n8n && docker-compose logs -f

# Restart toàn bộ hệ thống
cd /home/n8n && docker-compose restart

# Web Dashboard
http://YOUR_SERVER_IP:8080

# Troubleshoot script
/home/n8n/troubleshoot.sh
```

### 📊 Management Tools
```bash
# Enhanced backup
/home/n8n/backup-workflows-enhanced.sh

# Restore system
/home/n8n/restore-from-backup.sh

# Manual backup test
/home/n8n/backup-manual.sh
```

## 📂 Cấu Trúc Thư Mục Enhanced

```
/home/n8n/
├── docker-compose.yml              # Main config với multi-domain
├── Dockerfile                      # N8N custom image
├── Caddyfile                       # Reverse proxy cho tất cả domains
├── init-multi-db.sh                # PostgreSQL init script
├── backup-workflows-enhanced.sh    # Enhanced backup script
├── restore-from-backup.sh          # Enhanced restore script
├── troubleshoot.sh                 # Multi-domain diagnostic script
├── telegram_config.txt             # Telegram settings
├── dashboard/                      # Web Dashboard
│   ├── index.html                 # Dashboard UI
│   ├── server.py                  # Dashboard API server
│   └── assets/                    # Static assets
├── telegram_bot/                   # Telegram Bot Management
│   ├── bot.py                     # Main bot script
│   └── start_bot.sh               # Bot startup script
├── google_drive/                   # Google Drive Integration
│   ├── gdrive_backup.py           # Google Drive backup script
│   ├── credentials.json           # Service account credentials
│   └── cleanup_old_backups.py     # Cleanup script
├── security/                       # Security configurations
│   ├── setup_security.sh          # Security setup script
│   ├── auth_credentials.txt        # Basic auth credentials
│   ├── allowed_ips.txt            # IP whitelist
│   └── ssl_headers.conf           # SSL security headers
├── management/                     # Management tools
│   ├── dashboard.sh               # CLI dashboard
│   ├── menu.sh                    # Management menu
│   └── export-migration.sh        # Migration tools
├── files/                          # N8N data
│   ├── backup_full/               # Enhanced backup storage
│   ├── n8n_instance_1/           # Instance 1 data
│   ├── n8n_instance_2/           # Instance 2 data
│   └── n8n_instance_n/           # Instance N data
├── postgres_data/                  # PostgreSQL data (if enabled)
├── logs/                          # System logs
└── news_api/                       # News API (shared)
    ├── Dockerfile
    ├── requirements.txt
    └── main.py
```

## ⚡ Performance Tips

### 🚀 Multi-Domain Optimization
1. **Memory**: Script tự động tăng swap cho multi-domain
2. **CPU**: Mỗi N8N instance sử dụng optimized workers
3. **Database**: PostgreSQL shared connection pooling
4. **Disk**: Auto cleanup old backups và logs
5. **Network**: Caddy auto-compression cho tất cả domains

### 📊 Monitoring Multi-Domain
```bash
# Resource usage tất cả containers
docker stats --no-stream

# Real-time dashboard
http://YOUR_SERVER_IP:8080

# Telegram monitoring
/status trong Telegram Bot

# Performance metrics
/performance trong Telegram Bot
```

## 🐛 Troubleshooting

### ❌ Lỗi Thường Gặp Enhanced

**1. Telegram Bot không phản hồi**
```bash
# Kiểm tra service
systemctl status n8n-telegram-bot

# Xem logs
journalctl -u n8n-telegram-bot -f

# Restart bot
systemctl restart n8n-telegram-bot
```

**2. Google Drive upload thất bại**
```bash
# Kiểm tra credentials
cat /home/n8n/google_drive/credentials.json

# Test connection
python3 /home/n8n/google_drive/gdrive_backup.py list all
```

**3. Web Dashboard không load**
```bash
# Kiểm tra service
systemctl status n8n-dashboard

# Kiểm tra port
netstat -tulpn | grep 8080

# Restart dashboard
systemctl restart n8n-dashboard
```

**4. Multi-domain SSL issues**
```bash
# Kiểm tra Caddy logs cho domain cụ thể
cd /home/n8n && docker-compose logs caddy | grep domain.com

# Reset SSL cho tất cả domains
docker-compose restart caddy
```

## 🌟 Features Roadmap

- [x] **Multi-domain** support ✅
- [x] **PostgreSQL** external database ✅
- [x] **Telegram Bot** management ✅
- [x] **Google Drive** backup ✅
- [x] **Web Dashboard** ✅
- [x] **Enhanced Security** ✅
- [ ] **Load balancing** between instances
- [ ] **Kubernetes** deployment
- [ ] **Monitoring** dashboard with metrics
- [ ] **Auto-scaling** based on load
- [ ] **Plugin** marketplace integration
- [ ] **Cross-instance** workflow sharing

## 🤝 Contributing

1. Fork repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## 📄 License

MIT License - Xem file [LICENSE](LICENSE)

## 💬 Support

- **Issues**: [GitHub Issues](https://github.com/KalvinThien/install-n8n-ffmpeg/issues)
- **YouTube**: [Kalvin Thien Social](https://www.youtube.com/@kalvinthiensocial)
- **Facebook**: [Ban Thien Handsome](https://www.facebook.com/Ban.Thien.Handsome/)
- **Zalo**: 08.8888.4749

## ⭐ Star History

Nếu script này hữu ích, hãy cho một ⭐ star để ủng hộ!

[![Star History Chart](https://api.star-history.com/svg?repos=KalvinThien/install-n8n-ffmpeg&type=Date)](https://star-history.com/#KalvinThien/install-n8n-ffmpeg&Date)

---

**🚀 Made with ❤️ by Nguyễn Ngọc Thiện - 28/06/2025**  
**🆕 Enhanced Version 3.0 - Telegram Bot + Google Drive + Web Dashboard + Advanced Security**

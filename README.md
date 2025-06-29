# 🚀 Script Cài Đặt N8N Tự Động 2025 - Multi-Domain + PostgreSQL

![N8N](https://img.shields.io/badge/N8N-Automation-blue) ![Docker](https://img.shields.io/badge/Docker-Containerized-blue) ![SSL](https://img.shields.io/badge/SSL-Auto-green) ![Multi-Domain](https://img.shields.io/badge/Multi--Domain-Support-orange) ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-blue) ![API](https://img.shields.io/badge/News%20API-FastAPI-red)

Script tự động cài đặt N8N với đầy đủ tính năng mở rộng và hỗ trợ multi-domain, bao gồm:

## ✨ Tính Năng Mới 2025

### 🌐 Multi-Domain Support
- **Nhiều N8N instances** trên cùng một server
- **Chia sẻ tài nguyên** hiệu quả (News API, PostgreSQL)
- **Quản lý tập trung** backup và monitoring
- **SSL tự động** cho tất cả domains

### 🐘 PostgreSQL Database Support
- **Hiệu suất cao** hơn SQLite
- **Concurrent connections** tốt hơn
- **Backup và restore** dễ dàng
- **Chia sẻ database** giữa các instances
- **Hoàn toàn miễn phí**

### 📊 Management Dashboard
- **Quản lý tập trung** tất cả N8N instances
- **Real-time monitoring** resource usage
- **Báo cáo chi tiết** từng instance
- **Quick actions** restart, backup, update
- **SSL status** cho tất cả domains

### 💾 Advanced Backup System
- **ZIP compression** tối ưu dung lượng
- **Multi-domain backup** tất cả instances cùng lúc
- **Telegram integration** với detailed reports
- **Auto-retry** nếu gửi Telegram thất bại
- **Migration tools** chuyển đổi server dễ dàng

### 🔧 Core Features
- **N8N Workflow Automation** với FFmpeg, yt-dlp, Puppeteer
- **News Content API** (FastAPI + Newspaper4k)
- **Telegram Backup** tự động cho tất cả instances
- **SSL Certificate** tự động với Caddy
- **Auto-Update** thông minh
- **Smart Backup System** với multi-domain support

## 👨‍💻 Thông Tin Tác Giả

**Nguyễn Ngọc Thiện**
- 📺 **YouTube**: [Kalvin Thien Social](https://www.youtube.com/@kalvinthiensocial?sub_confirmation=1) - **HẢY ĐĂNG KÝ ĐỂ ỦNG HỘ!**
- 📘 **Facebook**: [Ban Thien Handsome](https://www.facebook.com/Ban.Thien.Handsome/)
- 📱 **Zalo/Phone**: 08.8888.4749
- 🎬 **N8N Playlist**: [N8N Tutorials](https://www.youtube.com/@kalvinthiensocial/playlists)
- 🚀 **Ngày cập nhật**: 28/06/2025
- 🆕 **Phiên bản**: 3.0 - Multi-Domain + Advanced Management

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

### Multi-Domain
- **RAM**: Khuyến nghị 4GB+ (mỗi N8N instance ~512MB)
- **CPU**: 2+ cores cho hiệu suất tốt
- **Disk**: 30GB+ cho nhiều instances

## 🚀 Cài Đặt Nhanh

### 1️⃣ Cài Đặt Cơ Bản (Single Domain)

```bash
cd /tmp && curl -sSL https://raw.githubusercontent.com/KalvinThien/install-n8n-ffmpeg/main/auto_cai_dat_n8n.sh | tr -d '\r' > install_n8n.sh && chmod +x install_n8n.sh && sudo bash install_n8n.sh
```

### 2️⃣ Cài Đặt Multi-Domain + PostgreSQL

```bash
cd /tmp && curl -sSL https://raw.githubusercontent.com/KalvinThien/install-n8n-ffmpeg/main/auto_cai_dat_n8n.sh | tr -d '\r' > install_n8n.sh && chmod +x install_n8n.sh && sudo bash install_n8n.sh --multi-domain --postgresql
```

### 3️⃣ Options Nâng Cao

```bash
# Multi-domain với PostgreSQL
sudo ./auto_cai_dat_n8n.sh -m -p

# Chỉ định thư mục cài đặt
sudo ./auto_cai_dat_n8n.sh -d /custom/path -m -p

# Clean install với multi-domain
sudo ./auto_cai_dat_n8n.sh --clean --multi-domain --postgresql

# Xem trợ giúp
./auto_cai_dat_n8n.sh -h
```

## 🔧 Quá Trình Cài Đặt

Script sẽ hướng dẫn bạn qua các bước:

### Single Domain Mode
1. **Setup Swap** tự động
2. **Nhập domain** của bạn
3. **Cấu hình database** (SQLite hoặc PostgreSQL)
4. **Cấu hình News API** (tùy chọn)
5. **Cấu hình Telegram** (tùy chọn)
6. **Kiểm tra DNS** pointing
7. **Cài đặt Docker** & dependencies
8. **Build & start** containers
9. **Setup SSL** certificate

### Multi-Domain Mode
1. **Setup Swap** tự động (tăng cường cho multi-domain)
2. **Nhập nhiều domains** (không giới hạn số lượng)
3. **Cấu hình PostgreSQL** (khuyến nghị cho multi-domain)
4. **Cấu hình News API** (chia sẻ cho tất cả instances)
5. **Cấu hình Telegram** (backup tất cả instances)
6. **Kiểm tra DNS** cho tất cả domains
7. **Cài đặt Docker** & dependencies
8. **Build & start** tất cả containers
9. **Setup SSL** cho tất cả domains
10. **Thiết lập databases** riêng cho mỗi instance

## 🌐 Multi-Domain Architecture

### Cấu Trúc Hệ Thống
```
┌─────────────────────────────────────────────────────────────┐
│                    Caddy Reverse Proxy                     │
│                     (SSL Termination)                      │
└─────────────────────────────────────────────────────────────┘
                              │
                ┌─────────────┼─────────────┐
                │             │             │
        ┌───────▼──────┐ ┌────▼────┐ ┌─────▼──────┐
        │ N8N Instance │ │ N8N ... │ │ News API   │
        │      #1      │ │         │ │ (Shared)   │
        │ domain1.com  │ │         │ │api.domain1 │
        └──────────────┘ └─────────┘ └────────────┘
                │             │             │
                └─────────────┼─────────────┘
                              │
                    ┌─────────▼─────────┐
                    │   PostgreSQL      │
                    │   (Shared DB)     │
                    │ - instance_1_db   │
                    │ - instance_2_db   │
                    │ - instance_n_db   │
                    └───────────────────┘
```

### Lợi Ích Multi-Domain
- **Tách biệt workflows** theo dự án/khách hàng
- **Chia sẻ tài nguyên** hiệu quả
- **Quản lý tập trung** backup và monitoring
- **Tiết kiệm chi phí** server
- **Dễ dàng scale** thêm domains

## 📊 Management Dashboard

### 🎛️ Truy Cập Dashboard
```bash
# Real-time dashboard
/home/n8n/management/dashboard.sh

# Management menu
/home/n8n/management/menu.sh

# Auto-refresh dashboard
/home/n8n/management/dashboard.sh --watch
```

### 📈 Tính Năng Dashboard
- **System Information**: OS, Memory, Disk, Uptime
- **Container Status**: Tất cả containers với health check
- **N8N Instances**: Status từng instance với domain mapping
- **Database Info**: PostgreSQL/SQLite status và connections
- **SSL Certificates**: Status tất cả domains
- **Backup Information**: Latest backups và storage usage
- **Resource Usage**: CPU, Memory, Network cho từng container
- **Quick Actions**: Restart, logs, backup, troubleshoot

### 🛠️ Management Menu
- **Monitoring**: Dashboard, logs, resource usage
- **Management**: Restart services, update, rebuild
- **Backup & Restore**: Manual backup, restore, migration
- **Configuration**: Change API tokens, Telegram config
- **Troubleshooting**: Diagnostics, fix issues, clean system

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

**1. Kiểm tra API:**
```bash
curl -X GET "https://api.yourdomain.com/health" \
     -H "Authorization: Bearer YOUR_TOKEN"
```

**2. Lấy nội dung bài viết:**
```bash
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

**3. Parse RSS Feed:**
```bash
curl -X POST "https://api.yourdomain.com/parse-feed" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -d '{
       "url": "https://dantri.com.vn/rss.xml",
       "max_articles": 10
     }'
```

### 🔧 Đổi Bearer Token

**One-liner command:**
```bash
cd /home/n8n && sed -i 's/NEWS_API_TOKEN=.*/NEWS_API_TOKEN="NEW_TOKEN"/' docker-compose.yml && docker-compose restart fastapi
```

## 🐘 PostgreSQL Database

### Thông Tin Kết Nối
- **Host**: localhost (127.0.0.1)
- **Port**: 5432
- **Database**: n8n_db
- **Username**: n8n_user
- **Password**: Tự động tạo trong quá trình cài đặt

### Multi-Domain Database Structure
```sql
-- Main database: n8n_db
-- Instance databases:
-- - n8n_db_instance_1 (for domain 1)
-- - n8n_db_instance_2 (for domain 2)
-- - n8n_db_instance_n (for domain n)

-- Each instance has its own schema:
-- - n8n_instance_1
-- - n8n_instance_2
-- - n8n_instance_n
```

### Backup PostgreSQL
```bash
# Backup tất cả databases
docker exec postgres-n8n pg_dumpall -U n8n_user > full_backup.sql

# Backup database cụ thể
docker exec postgres-n8n pg_dump -U n8n_user -d n8n_db_instance_1 > instance_1_backup.sql

# Restore database
docker exec -i postgres-n8n psql -U n8n_user -d n8n_db < backup.sql
```

## 💾 Advanced Backup & Restore System

### 🔄 Multi-Domain Backup System
Script tự động backup mỗi ngày lúc 2:00 AM:
- **Tất cả N8N instances** (workflows & credentials)
- **PostgreSQL databases** (tất cả instance databases)
- **Configuration files** (docker-compose.yml, Caddyfile)
- **SSL certificates** (Caddy data)
- **ZIP compression** với metadata chi tiết

### 🧪 Test Backup
```bash
# Chạy backup thủ công và kiểm tra
/home/n8n/backup-manual.sh

# Chạy backup thông thường
/home/n8n/backup-workflows.sh
```

### 📁 Cấu Trúc Backup
```
/home/n8n/files/backup_full/
├── n8n_backup_20250628_140000.zip
│   ├── instances/
│   │   ├── instance_1/
│   │   │   ├── workflows.json
│   │   │   ├── credentials.json
│   │   │   ├── database.sqlite (if SQLite)
│   │   │   └── metadata.json
│   │   ├── instance_2/
│   │   └── instance_n/
│   ├── postgres/
│   │   ├── dump_instance_1.sql
│   │   ├── dump_instance_2.sql
│   │   └── dump_main.sql
│   ├── config/
│   │   ├── docker-compose.yml
│   │   ├── Caddyfile
│   │   └── telegram_config.txt
│   ├── ssl/
│   │   └── caddy_data.tar.gz
│   └── backup_metadata.json
├── latest_backup_report.txt
└── backup.log
```

### 📱 Telegram Backup
Nếu đã cấu hình, backup sẽ tự động gửi qua Telegram:
- **File backup** (.zip) nếu <50MB
- **Detailed report** về tất cả instances
- **Database status** và kích thước
- **Instance mapping** với domains
- **Notifications** khi backup thành công/thất bại
- **Fallback**: Giữ backup local nếu Telegram thất bại

### 🔄 Restore System
```bash
# Restore từ backup file
/home/n8n/management/restore.sh /path/to/backup.zip

# Restore sẽ:
# 1. Stop tất cả services
# 2. Restore configuration files
# 3. Restore SSL certificates
# 4. Restore PostgreSQL databases
# 5. Restore N8N instances data
# 6. Import workflows và credentials
# 7. Start tất cả services
```

## 🚚 Migration Tools

### 📦 Export for Migration
```bash
# Tạo migration package
/home/n8n/management/export-migration.sh

# Package bao gồm:
# - Tất cả N8N instances data
# - Configuration files
# - Database schema
# - Migration scripts
# - Detailed documentation
```

### 🔄 Migration Process
1. **Export** từ server cũ
2. **Transfer** migration package
3. **Setup** server mới
4. **Import** và restore data
5. **Verify** tất cả domains

### 📚 Migration Guide
- **Detailed documentation** trong migration package
- **Step-by-step instructions** cho từng bước
- **Troubleshooting guide** cho các lỗi thường gặp
- **Server comparison** tool
- **DNS migration** checklist

## 🛠️ Quản Lý Hệ Thống

### 🔧 Lệnh Cơ Bản

```bash
# Xem trạng thái tất cả containers
cd /home/n8n && docker-compose ps

# Xem logs realtime tất cả services
cd /home/n8n && docker-compose logs -f

# Restart toàn bộ hệ thống
cd /home/n8n && docker-compose restart

# Restart N8N instance cụ thể
cd /home/n8n && docker-compose restart n8n_1

# Rebuild tất cả containers
cd /home/n8n && docker-compose down && docker-compose up -d --build
```

### 🔍 Troubleshooting

```bash
# Script chẩn đoán tự động (Multi-Domain support)
/home/n8n/troubleshoot.sh

# Kiểm tra N8N instances
docker ps --filter "name=n8n-container-"

# Kiểm tra logs instance cụ thể
cd /home/n8n && docker-compose logs n8n_1
cd /home/n8n && docker-compose logs n8n_2

# Kiểm tra PostgreSQL
cd /home/n8n && docker-compose logs postgres

# Kiểm tra Caddy
cd /home/n8n && docker-compose logs caddy
```

### 🔄 Updates

```bash
# Update tự động (mỗi 12h) - tất cả instances
/home/n8n/update-n8n.sh

# Update yt-dlp cho tất cả instances
for container in $(docker ps --filter "name=n8n-container-" --format "{{.Names}}"); do
    docker exec $container pip3 install --break-system-packages -U yt-dlp
done
```

## 📂 Cấu Trúc Thư Mục Multi-Domain

```
/home/n8n/
├── docker-compose.yml              # Main config với multi-domain
├── Dockerfile                      # N8N custom image
├── Caddyfile                       # Reverse proxy cho tất cả domains
├── init-multi-db.sh                # PostgreSQL init script
├── backup-workflows.sh             # Multi-domain backup script
├── backup-manual.sh                # Manual backup test
├── update-n8n.sh                  # Multi-domain update script
├── troubleshoot.sh                 # Multi-domain diagnostic script
├── telegram_config.txt             # Telegram settings
├── management/                     # Management tools
│   ├── dashboard.sh               # Real-time dashboard
│   ├── menu.sh                    # Management menu
│   ├── restore.sh                 # Restore system
│   └── export-migration.sh        # Migration tools
├── files/                          # N8N data
│   ├── backup_full/               # Multi-domain backup storage
│   ├── temp/                      # Temporary files
│   ├── youtube_content_anylystic/ # Shared video downloads
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
2. **CPU**: Mỗi N8N instance sử dụng single worker
3. **Database**: PostgreSQL shared connection pooling
4. **Disk**: Auto cleanup old backups (30 days)
5. **Network**: Caddy auto-compression cho tất cả domains

### 📊 Monitoring Multi-Domain

```bash
# Resource usage tất cả containers
docker stats --no-stream

# Disk usage
df -h

# Memory usage per instance
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" --no-stream

# PostgreSQL connections
docker exec postgres-n8n psql -U n8n_user -d n8n_db -c "SELECT count(*) FROM pg_stat_activity;"

# Real-time dashboard
/home/n8n/management/dashboard.sh --watch
```

## 🐛 Troubleshooting

### ❌ Lỗi Thường Gặp Multi-Domain

**1. Một instance không start**
```bash
# Kiểm tra logs instance cụ thể
cd /home/n8n && docker-compose logs n8n_1

# Restart instance cụ thể
cd /home/n8n && docker-compose restart n8n_1

# Sử dụng management menu
/home/n8n/management/menu.sh
```

**2. PostgreSQL connection issues**
```bash
# Kiểm tra PostgreSQL status
docker exec postgres-n8n pg_isready -U n8n_user

# Kiểm tra databases
docker exec postgres-n8n psql -U n8n_user -l

# Restart PostgreSQL
cd /home/n8n && docker-compose restart postgres
```

**3. SSL issues cho một domain**
```bash
# Kiểm tra Caddy logs
cd /home/n8n && docker-compose logs caddy | grep domain.com

# Test SSL cho domain cụ thể
curl -I https://domain.com

# Reset SSL certificates
/home/n8n/management/menu.sh # Option 20 -> 5
```

**4. Memory issues với nhiều instances**
```bash
# Kiểm tra memory usage
free -h
docker stats --no-stream

# Tăng swap nếu cần
sudo fallocate -l 4G /swapfile2
sudo chmod 600 /swapfile2
sudo mkswap /swapfile2
sudo swapon /swapfile2
```

**5. Backup issues**
```bash
# Test manual backup
/home/n8n/backup-manual.sh

# Kiểm tra Telegram config
cat /home/n8n/telegram_config.txt

# Kiểm tra backup logs
tail -f /home/n8n/files/backup_full/backup.log
```

### 🔧 Recovery Commands

```bash
# Restart toàn bộ hệ thống
cd /home/n8n && docker-compose down && docker-compose up -d

# Rebuild specific instance
cd /home/n8n && docker-compose up -d --build n8n_1

# Reset PostgreSQL
cd /home/n8n && docker-compose down postgres
docker volume rm n8n_postgres_data
cd /home/n8n && docker-compose up -d postgres

# Clean reinstall
sudo rm -rf /home/n8n
sudo ./auto_cai_dat_n8n.sh --clean --multi-domain --postgresql

# Restore từ backup
/home/n8n/management/restore.sh /path/to/backup.zip
```

## 🌟 Features Roadmap

- [x] **Multi-domain** support ✅
- [x] **PostgreSQL** external database ✅
- [x] **Management Dashboard** ✅
- [x] **Advanced Backup System** ✅
- [x] **Migration Tools** ✅
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
**🆕 Enhanced with Multi-Domain + PostgreSQL + Advanced Management**
# 🚀 N8N Multi-Mode Enhanced Installation Script v4.0

![N8N](https://img.shields.io/badge/N8N-Automation-blue) ![Docker](https://img.shields.io/badge/Docker-Containerized-blue) ![SSL](https://img.shields.io/badge/SSL-Auto-green) ![Multi-Domain](https://img.shields.io/badge/Multi--Domain-Support-orange) ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-blue) ![API](https://img.shields.io/badge/News%20API-FastAPI-red) ![Telegram](https://img.shields.io/badge/Telegram-Bot-blue) ![Google Drive](https://img.shields.io/badge/Google%20Drive-Backup-green) ![Cloudflare](https://img.shields.io/badge/Cloudflare-Tunnel-purple) ![Auto-Fix](https://img.shields.io/badge/Auto--Fix-Enabled-green)

**🎬 PLEASE SUBSCRIBE TO MY YOUTUBE CHANNEL TO SUPPORT ME! 🔔**
👉 [SUBSCRIBE HERE](https://www.youtube.com/@kalvinthiensocial?sub_confirmation=1) to receive the latest videos about N8N, Automation and many other interesting technologies!

Automated N8N installation script with comprehensive features and remote management, including:

## ✨ New Features Version 4.0

### 🌐 Multi-Mode Installation Support
- **Localhost Mode** - No domain required, access via IP
- **Domain Mode** - Requires domain and DNS with automatic SSL
- **Cloudflare Tunnel Mode** - No public IP needed, completely secure
- **Smart Mode Detection** - Automatically selects the most suitable mode

### 🔧 Auto-Fix Integration System
- **No more 503 errors!** - Automatically fixes all common issues
- **Permission Auto-Fix** - Automatically fixes directory permissions (1000:1000)
- **Docker Network Recovery** - Automatically recreates broken networks
- **Service Health Recovery** - Automatically restarts unstable services
- **PostgreSQL Connection Fix** - Automatically fixes database connection issues
- **SSL Certificate Recovery** - Automatically fixes SSL problems

### ☁️ Cloudflare Tunnel Support
- **No Public IP Required** - Works even without public IP
- **Automatic SSL** - SSL certificates automatically from Cloudflare
- **DDoS Protection** - Protection against DDoS attacks
- **Zero Trust Security** - High-level security
- **Easy Setup** - Only needs tunnel token from Cloudflare dashboard

### 🔌 Custom Port Configuration
- **Dynamic Port Assignment** - Automatically finds available ports
- **Multi-Instance Ports** - Each N8N instance has its own port
- **Port Conflict Resolution** - Automatically avoids port conflicts
- **Custom Base Ports** - Can change default base ports

### 📊 Enhanced Health Monitoring & Auto-Recovery
- **Real-time Health Checks** - Continuously monitors system health
- **Auto-Recovery System** - Automatically recovers when errors occur
- **Performance Metrics** - Real-time performance monitoring
- **Telegram Alerts** - Error notifications via Telegram
- **Retry Mechanism** - Automatically retries when failed

### 🔒 Enhanced Dashboard Security
- **Basic Authentication** - Protects dashboard with username/password
- **Secure Credentials** - Securely stores login information
- **IP Filtering** - Only allows authorized IPs
- **Session Management** - Manages login sessions

### 🤖 Telegram Bot Management (Enhanced)
- **Complete remote management** via Telegram
- **Real-time monitoring** and alerts
- **Quick actions**: restart, backup, logs, health check
- **Real-time performance metrics**
- **Security**: Only authorized Chat ID
- **Auto-Fix Commands** - Fix commands from Telegram

### ☁️ Google Drive Auto Backup (Enhanced)
- **Automatic upload** backup to Google Drive
- **Folder structure** by year/month/domain
- **Easy restore** from Google Drive
- **OAuth2 authentication** secure
- **Cross-platform** access
- **Auto-Fix Integration** - Automatically fixes backup issues

### 📊 Web Dashboard (Enhanced)
- **Browser-based** management interface
- **Real-time charts** and metrics
- **Mobile responsive** design
- **Quick actions** and troubleshooting
- **Multi-user** support ready
- **Auto-Fix Dashboard** - Auto-fix management interface

### 🔒 Enhanced Security (Version 4.0)
- **Basic Authentication** for N8N instances
- **IP filtering** and whitelist
- **Fail2ban** protection
- **SSL security headers**
- **Advanced rate limiting**
- **Cloudflare Zero Trust** integration

### 🌐 Multi-Domain Support (Enhanced)
- **Multiple N8N instances** on the same server
- **Efficient resource sharing** (News API, PostgreSQL)
- **Centralized management** of backup and monitoring
- **Automatic SSL** for all domains
- **Auto-Fix Multi-Domain** - Automatically fixes all instances

### 🐘 PostgreSQL Database Support (Enhanced)
- **High performance** better than SQLite
- **Better concurrent connections**
- **Easy backup and restore**
- **Database sharing** between instances
- **Completely free**
- **Auto-Fix Database** - Automatically fixes connection issues

## 👨‍💻 Author Information

**🌟 Nguyễn Ngọc Thiện 🌟**
- 📺 **YouTube**: [Kalvin Thien Social](https://www.youtube.com/@kalvinthiensocial?sub_confirmation=1) - **🔥 PLEASE SUBSCRIBE TO SUPPORT! 🔥**
- 📘 **Facebook**: [@Ban.Thien.Handsome](https://www.facebook.com/Ban.Thien.Handsome/)
- 📱 **Zalo/Phone**: 08.8888.4749
- 🎬 **N8N Playlist**: [N8N Video List](https://www.youtube.com/@kalvinthiensocial/playlists)
- 🚀 **Update Date**: 01/07/2025  
- 🆕 **Version**: 4.0 Enhanced - Multi-Mode + Auto-Fix + Cloudflare Tunnel + Health Monitoring + Custom Ports

> 💡 **Don't forget to SUBSCRIBE and 🔔 to not miss the latest useful videos!**
> 
> 🎯 My channel shares knowledge about:
> - 🤖 N8N Automation workflows
> - 🐳 Docker & DevOps
> - 💻 Server management  
> - 🚀 Latest tech tutorials
> - 📱 Social media automation

## 🖥️ Supported Environments

✅ **Ubuntu VPS/Server** (Recommended)  
✅ **Ubuntu on Windows WSL**  
✅ **Ubuntu Docker Environment**  
✅ **Automatic detection** and environment handling  
✅ **Cloudflare Tunnel** - No public IP needed

## 📋 System Requirements

### Basic
- **OS**: Ubuntu 20.04+ (VPS or WSL)
- **RAM**: Minimum 2GB (recommended 4GB+ for multi-domain)
- **Disk**: 20GB+ free space
- **Network**: Domains pointed to server (for Domain Mode)
- **Permission**: Root access

### Enhanced Features (Version 4.0)
- **RAM**: Recommended 4GB+ (each N8N instance ~512MB)
- **CPU**: 2+ cores for good performance
- **Disk**: 30GB+ for multiple instances + backups
- **Google Account**: For Google Drive backup (optional)
- **Telegram Bot**: For remote management (optional)
- **Cloudflare Account**: For Cloudflare Tunnel (optional)

## 🚀 Quick Installation

### 1️⃣ Localhost Mode Installation (No domain required)

```bash
cd /tmp && curl -sSL https://raw.githubusercontent.com/KalvinThien/install-n8n-ffmpeg/main/auto_cai_dat_n8n.sh | tr -d '\r' > install_n8n.sh && chmod +x install_n8n.sh && sudo bash install_n8n.sh -l
```

### 2️⃣ Cloudflare Tunnel Mode Installation (No public IP needed)

```bash
cd /tmp && curl -sSL https://raw.githubusercontent.com/KalvinThien/install-n8n-ffmpeg/main/auto_cai_dat_n8n.sh | tr -d '\r' > install_n8n.sh && chmod +x install_n8n.sh && sudo bash install_n8n.sh -f
```

### 3️⃣ Multi-Domain + PostgreSQL Installation

```bash
cd /tmp && curl -sSL https://raw.githubusercontent.com/KalvinThien/install-n8n-ffmpeg/main/auto_cai_dat_n8n.sh | tr -d '\r' > install_n8n.sh && chmod +x install_n8n.sh && sudo bash install_n8n.sh -m -p
```

### 4️⃣ Full Features Installation with Auto-Fix

```bash
cd /tmp && curl -sSL https://raw.githubusercontent.com/KalvinThien/install-n8n-ffmpeg/main/auto_cai_dat_n8n.sh | tr -d '\r' > install_n8n.sh && chmod +x install_n8n.sh && sudo bash install_n8n.sh -m -p -g -t
```

### 5️⃣ Advanced Options Version 4.0

```bash
# Localhost mode with auto-fix
sudo ./auto_cai_dat_n8n.sh -l

# Cloudflare Tunnel mode
sudo ./auto_cai_dat_n8n.sh -f

# Multi-domain with PostgreSQL and auto-fix
sudo ./auto_cai_dat_n8n.sh -m -p

# Full features with all capabilities
sudo ./auto_cai_dat_n8n.sh -m -p -g -t

# Clean install with full features
sudo ./auto_cai_dat_n8n.sh -c -m -p -g -t

# Disable auto-fix (not recommended)
sudo ./auto_cai_dat_n8n.sh --no-auto-fix

# Show help
./auto_cai_dat_n8n.sh -h
```

## 🔧 Installation Process Version 4.0

The script will guide you through the steps:

### Installation Modes (New)
1. **Localhost Mode** - No domain required, access via IP
2. **Domain Mode** - Requires domain and DNS with automatic SSL
3. **Cloudflare Tunnel Mode** - No public IP needed, completely secure

### Setup Process (Enhanced)
1. **Choose Installation Mode** - Localhost/Domain/Cloudflare
2. **Setup Swap** automatically (enhanced for multi-domain)
3. **Enter domains** (single or multiple)
4. **Custom Port Configuration** - Automatically allocate ports
5. **Dashboard Security** - Basic Auth setup
6. **Configure PostgreSQL** (if selected)
7. **Configure News API** (optional)
8. **Configure Telegram** (optional)
9. **Configure Google Drive** (if selected)
10. **Configure Cloudflare Tunnel** (if selected)
11. **Verify DNS** for all domains (Domain Mode)
12. **Install Docker** & dependencies
13. **Build & start** all containers with auto-fix
14. **Setup SSL** for all domains
15. **Setup services** (Dashboard, Telegram Bot, Health Monitor)
16. **Auto-Fix Integration** - Check and fix errors automatically

## 🔧 Auto-Fix System (Version 4.0)

### 🛠️ Automatically Fix Common Issues
- **Permission Issues** - Automatically fixes directory permissions (1000:1000)
- **Docker Network Problems** - Automatically recreates broken networks
- **Container Health Issues** - Automatically restarts unstable containers
- **PostgreSQL Connection** - Automatically fixes database connection
- **SSL Certificate Problems** - Automatically fixes SSL issues
- **Port Conflicts** - Automatically finds available ports

### 🔄 Auto-Recovery Features
- **Health Monitoring** - Continuously monitors system health
- **Retry Mechanism** - Automatically retries when failed
- **Graceful Degradation** - System continues working when errors occur
- **Telegram Alerts** - Error notifications and fix status

### 📊 Auto-Fix Commands
```bash
# Automatically fix all errors
/home/n8n/auto-fix.sh

# Fix permissions
/home/n8n/auto-fix.sh permissions

# Fix Docker networks
/home/n8n/auto-fix.sh networks

# Fix PostgreSQL
/home/n8n/auto-fix.sh database

# Fix SSL certificates
/home/n8n/auto-fix.sh ssl
```

## ☁️ Cloudflare Tunnel Mode (Version 4.0)

### 🌐 Cloudflare Tunnel Features
- **No Public IP Required** - Works even without public IP
- **Automatic SSL** - SSL certificates automatically from Cloudflare
- **DDoS Protection** - Protection against DDoS attacks
- **Zero Trust Security** - High-level security
- **Easy Setup** - Only needs tunnel token from Cloudflare dashboard

### 🔧 Cloudflare Tunnel Setup
1. Visit [Cloudflare Zero Trust](https://one.dash.cloudflare.com/)
2. Go to Zero Trust → Access → Tunnels
3. Create a tunnel → Cloudflared
4. Name the tunnel (e.g., n8n-tunnel)
5. Copy tunnel token
6. Enter token in script

### 📁 Cloudflare Structure
```
/home/n8n/cloudflare/
├── config.yml              # Tunnel configuration
├── credentials.json        # Cloudflare credentials
└── tunnel.log             # Tunnel logs
```

## 🔌 Custom Port Configuration (Version 4.0)

### 🌐 Dynamic Port Assignment
- **Auto Port Detection** - Automatically finds available ports
- **Port Conflict Resolution** - Avoids port conflicts
- **Custom Base Ports** - Can change default base ports
- **Multi-Instance Ports** - Each N8N instance has its own port

### 📊 Port Management
```bash
# Default ports
N8N Base Port: 5678
API Base Port: 8000
Dashboard Port: 8080

# Multi-domain ports
Instance 1: 5678
Instance 2: 5800
Instance 3: 5801
...
```

## 📊 Enhanced Health Monitoring (Version 4.0)

### 🏥 Health Check System
- **Real-time Monitoring** - Continuously monitors system health
- **Auto-Recovery** - Automatically recovers when errors occur
- **Performance Metrics** - Real-time performance monitoring
- **Telegram Alerts** - Error notifications via Telegram

### 🔄 Health Check Features
```bash
# Health check endpoints
N8N: /healthz
News API: /health
PostgreSQL: pg_isready
Caddy: Built-in health checks

# Health check interval: 30s
# Retry attempts: 3
# Auto-recovery: Enabled
```

## 🤖 Telegram Bot Management (Enhanced Version 4.0)

### 🔧 Basic Bot Commands
```
/start          - Start bot
/status         - Status of all instances
/health         - Detailed health check
/performance    - Performance metrics
/help           - Command list
```

### 🛠️ Service Management (Enhanced)
```
/restart all              - Restart all services
/restart n8n              - Restart N8N container
/restart caddy            - Restart Caddy proxy
/restart postgres         - Restart PostgreSQL
/auto-fix                 - Run auto-fix system
/auto-fix permissions     - Fix permissions
/auto-fix networks        - Fix Docker networks
/auto-fix database        - Fix PostgreSQL
/auto-fix ssl             - Fix SSL certificates
```

### 📋 Logs & Monitoring (Enhanced)
```
/logs all                 - Logs of all services
/logs n8n 50              - Last 50 lines of N8N logs
/backup                   - Run manual backup
/troubleshoot             - Run diagnostic
/health-monitor           - Health monitor status
```

### 📊 Example Output (Enhanced)
```
🚀 N8N System Status v4.0

📊 System Info:
• Uptime: up 2 days, 14 hours, 32 minutes
• Memory: 2.1G/4.0G
• Disk Usage: 45%
• Auto-Fix: ✅ Enabled
• Health Monitor: ✅ Active

🌐 Installation Mode: Cloudflare Tunnel
🌐 Domains (3):
• Instance 1: n8n1.example.com (Port: 5678)
• Instance 2: n8n2.example.com (Port: 5800)
• Instance 3: n8n3.example.com (Port: 5801)

🐳 Containers (6):
✅ n8n-container-1: running (healthy)
✅ n8n-container-2: running (healthy)
✅ caddy-proxy: running (healthy)
✅ postgres-n8n: running (healthy)
✅ cloudflared: running (healthy)
✅ news-api-container: running (healthy)

🔧 Auto-Fix Status:
• Last Check: 2 minutes ago
• Issues Fixed: 0
• System Health: ✅ Excellent
```

## ☁️ Google Drive Backup System (Enhanced Version 4.0)

### 🔧 Google Drive API Setup
1. Visit [Google Cloud Console](https://console.developers.google.com/)
2. Create new project or select existing project
3. Enable Google Drive API
4. Create Service Account credentials
5. Download JSON credentials file
6. Share Google Drive folder with service account

### 📁 Backup Structure (Enhanced)
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

### 🔄 Auto Backup Features (Enhanced)
- **Daily upload** to Google Drive
- **Organized by** year/month/domain
- **Automatic cleanup** of old backups
- **Telegram notifications** with status
- **Fallback local** if upload fails
- **Auto-Fix Integration** - Automatically fixes backup issues

## 📊 Web Dashboard (Enhanced Version 4.0)

### 🌐 Dashboard Access
```
http://YOUR_SERVER_IP:8080
```

### 📈 Dashboard Features (Enhanced)
- **Real-time monitoring** of all instances
- **System metrics** (CPU, Memory, Disk, Network)
- **Container status** with health checks
- **SSL certificate** monitoring
- **Backup status** and history
- **Quick actions** (restart, backup, logs)
- **Mobile responsive** design
- **Auto-refresh** every 30 seconds
- **Auto-Fix Dashboard** - Auto-fix management interface
- **Health Monitor Status** - Health monitoring status

### 🔧 Quick Actions (Enhanced)
- 🔄 **Refresh Data** - Update realtime
- 🔄 **Restart All** - Restart all services
- 💾 **Manual Backup** - Run manual backup
- 📋 **View Logs** - View logs in new tab
- ⬆️ **Update System** - Update system
- 🔧 **Troubleshoot** - Run diagnostic script
- 🛠️ **Auto-Fix** - Run auto-fix system
- 🏥 **Health Check** - Run manual health check

## 📰 News Content API (Enhanced Version 4.0)

### 🔑 Authentication
All API calls require Bearer Token:
```bash
Authorization: Bearer YOUR_TOKEN_HERE
```

### 📖 API Documentation
After installation, visit:
- **Homepage**: `https://api.yourdomain.com/`
- **Swagger UI**: `https://api.yourdomain.com/docs`
- **ReDoc**: `https://api.yourdomain.com/redoc`

### 💻 cURL Example
```bash
# Extract article content
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

## 💾 Enhanced Backup & Restore System (Version 4.0)

### 🔄 Multi-Domain Backup Features (Enhanced)
- **ZIP compression** optimized for size
- **Multi-domain backup** all instances simultaneously
- **PostgreSQL databases** backup separately for each instance
- **SSL certificates** backup and restore
- **Configuration files** backup
- **Metadata** detailed for each backup
- **Auto-Fix Integration** - Automatically fixes backup issues

### 📱 Telegram Integration (Enhanced)
- **Detailed reports** about all instances
- **File upload** if <50MB
- **Status notifications** success/failure
- **Fallback**: Keep backup local if Telegram fails
- **Auto-Fix Notifications** - Auto-fix status notifications

### ☁️ Google Drive Integration (Enhanced)
- **Auto-upload** after each backup
- **Organized folders** by domain and date
- **Easy restore** from Google Drive
- **Cross-platform** access
- **Auto-Fix Integration** - Automatically fixes upload issues

### 🔄 Restore System (Enhanced)
```bash
# Restore from backup file
/home/n8n/restore-from-backup.sh /path/to/backup.zip

# Restore specific domain
/home/n8n/restore-from-backup.sh /path/to/backup.zip domain.com

# Restore will:
# 1. Stop all services
# 2. Restore configuration files
# 3. Restore SSL certificates
# 4. Restore PostgreSQL databases
# 5. Restore N8N instances data
# 6. Import workflows and credentials
# 7. Start all services
# 8. Run auto-fix to ensure stability
```

## 🔒 Enhanced Security Features (Version 4.0)

### 🔐 Basic Authentication (Enhanced)
- **Auto-generated** username/password for N8N
- **Secure storage** of credentials
- **Easy rotation** of passwords
- **Dashboard Security** - Basic Auth for dashboard

### 🛡️ IP Filtering (Enhanced)
- **Whitelist** allowed IP addresses
- **CIDR block** support
- **Easy configuration** via file
- **Cloudflare Integration** - IP filtering with Cloudflare

### 🚫 Fail2ban Protection (Enhanced)
- **Auto-ban** malicious IPs
- **Custom rules** for N8N
- **Configurable** ban times
- **Cloudflare Integration** - Fail2ban with Cloudflare

### 🔒 SSL Security Headers (Enhanced)
- **HSTS** enforcement
- **XSS protection**
- **Content Security Policy**
- **Frame protection**
- **Cloudflare Zero Trust** integration

## 🛠️ System Management (Version 4.0)

### 🔧 Basic Commands (Enhanced)
```bash
# View status of all containers
cd /home/n8n && docker-compose ps

# View realtime logs of all services
cd /home/n8n && docker-compose logs -f

# Restart entire system
cd /home/n8n && docker-compose restart

# Web Dashboard
http://YOUR_SERVER_IP:8080

# Auto-Fix System
/home/n8n/auto-fix.sh

# Health Monitor
systemctl status n8n-health-monitor

# Troubleshoot script
/home/n8n/troubleshoot.sh
```

### 📊 Management Tools (Enhanced)
```bash
# Enhanced backup
/home/n8n/backup-workflows-enhanced.sh

# Restore system
/home/n8n/restore-from-backup.sh

# Manual backup test
/home/n8n/backup-manual.sh

# Auto-Fix System
/home/n8n/auto-fix.sh

# Health Monitor
/home/n8n/health_checks/health_monitor.sh
```

## 📂 Enhanced Directory Structure (Version 4.0)

```
/home/n8n/
├── docker-compose.yml              # Main config with multi-domain
├── Dockerfile                      # N8N custom image
├── Caddyfile                       # Reverse proxy for all domains
├── init-multi-db.sh                # PostgreSQL init script
├── backup-workflows-enhanced.sh    # Enhanced backup script
├── restore-from-backup.sh          # Enhanced restore script
├── troubleshoot.sh                 # Multi-domain diagnostic script
├── auto-fix.sh                     # Auto-Fix system script
├── telegram_config.txt             # Telegram settings
├── dashboard/                      # Web Dashboard
│   ├── index.html                 # Dashboard UI
│   ├── api_server.py              # Dashboard API server
│   └── assets/                    # Static assets
├── telegram_bot/                   # Telegram Bot Management
│   ├── bot.py                     # Main bot script
│   └── start_bot.sh               # Bot startup script
├── google_drive/                   # Google Drive Integration
│   ├── gdrive_backup.py           # Google Drive backup script
│   ├── credentials.json           # Service account credentials
│   └── cleanup_old_backups.py     # Cleanup script
├── cloudflare/                     # Cloudflare Tunnel
│   ├── config.yml                 # Tunnel configuration
│   ├── credentials.json           # Cloudflare credentials
│   └── tunnel.log                 # Tunnel logs
├── health_checks/                  # Health Monitoring
│   ├── health_monitor.sh          # Health monitor script
│   ├── health_check.sh            # Health check script
│   └── auto_recovery.sh           # Auto recovery script
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

## ⚡ Performance Tips (Version 4.0)

### 🚀 Multi-Mode Optimization
1. **Localhost Mode**: Optimized for development and testing
2. **Domain Mode**: Optimized for production with SSL
3. **Cloudflare Mode**: Optimized for high security and no public IP
4. **Memory**: Script automatically increases swap for multi-domain
5. **CPU**: Each N8N instance uses optimized workers
6. **Database**: PostgreSQL shared connection pooling
7. **Disk**: Auto cleanup of old backups and logs
8. **Network**: Caddy auto-compression for all domains

### 📊 Monitoring Multi-Mode (Enhanced)
```bash
# Resource usage of all containers
docker stats --no-stream

# Real-time dashboard
http://YOUR_SERVER_IP:8080

# Telegram monitoring
/status in Telegram Bot

# Performance metrics
/performance in Telegram Bot

# Health monitor
systemctl status n8n-health-monitor

# Auto-fix status
/home/n8n/auto-fix.sh status
```

## 🐛 Troubleshooting (Version 4.0)

### ❌ Common Issues Enhanced

**1. Auto-Fix System not working**
```bash
# Check auto-fix service
systemctl status n8n-auto-fix

# Run auto-fix manually
/home/n8n/auto-fix.sh

# View auto-fix logs
tail -f /var/log/n8n-auto-fix.log
```

**2. Cloudflare Tunnel not connecting**
```bash
# Check tunnel status
systemctl status cloudflared

# View tunnel logs
journalctl -u cloudflared -f

# Test tunnel connection
cloudflared tunnel info
```

**3. Health Monitor not working**
```bash
# Check health monitor
systemctl status n8n-health-monitor

# View health monitor logs
journalctl -u n8n-health-monitor -f

# Restart health monitor
systemctl restart n8n-health-monitor
```

**4. Custom Ports not working**
```bash
# Check port usage
netstat -tulpn | grep :5678

# Check port conflicts
/home/n8n/auto-fix.sh ports

# Fix port issues
/home/n8n/auto-fix.sh networks
```

**5. Multi-Mode issues**
```bash
# Check installation mode
cat /home/n8n/installation_mode.txt

# Switch mode
/home/n8n/switch-mode.sh localhost
/home/n8n/switch-mode.sh domain
/home/n8n/switch-mode.sh cloudflare
```

## 🌟 Features Roadmap (Version 4.0)

- [x] **Multi-Mode** support (Localhost/Domain/Cloudflare) ✅
- [x] **Auto-Fix Integration** system ✅
- [x] **Health Monitoring** & Auto-Recovery ✅
- [x] **Custom Port Configuration** ✅
- [x] **Cloudflare Tunnel** support ✅
- [x] **Multi-domain** support ✅
- [x] **PostgreSQL** external database ✅
- [x] **Telegram Bot** management ✅
- [x] **Google Drive** backup ✅
- [x] **Web Dashboard** ✅
- [x] **Enhanced Security** ✅
- [ ] **Load balancing** between instances
- [ ] **Kubernetes** deployment
- [ ] **Advanced monitoring** dashboard with metrics
- [ ] **Auto-scaling** based on load
- [ ] **Plugin** marketplace integration
- [ ] **Cross-instance** workflow sharing
- [ ] **Multi-cloud** deployment support

## 🤝 Contributing

1. Fork repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## 📄 License

MIT License - See [LICENSE](LICENSE) file

## 💬 Support

- **Issues**: [GitHub Issues](https://github.com/KalvinThien/install-n8n-ffmpeg/issues)
- **YouTube**: [Kalvin Thien Social](https://www.youtube.com/@kalvinthiensocial)
- **Facebook**: [Ban Thien Handsome](https://www.facebook.com/Ban.Thien.Handsome/)
- **Zalo**: 08.8888.4749

## ⭐ Star History

If this script is useful, please give a ⭐ star to support!

[![Star History Chart](https://api.star-history.com/svg?repos=KalvinThien/install-n8n-ffmpeg&type=Date)](https://star-history.com/#KalvinThien/install-n8n-ffmpeg&Date)

---

**🚀 Made with ❤️ by Nguyễn Ngọc Thiện - 01/07/2025**  
**🆕 Enhanced Version 4.0 - Multi-Mode + Auto-Fix + Cloudflare Tunnel + Health Monitoring + Custom Ports**

## 🔧 Troubleshooting & Fix Issues (Version 4.0)

### 🚨 When encountering HTTP 502 errors or N8N not working

If you encounter the following issues:
- ❌ HTTP ERROR 502 when accessing domains
- ❌ N8N containers continuously restarting
- ❌ Permission denied errors
- ❌ PostgreSQL connection issues
- ❌ SSL certificate problems
- ❌ Cloudflare Tunnel connection issues
- ❌ Health monitor not working

### 🛠️ Comprehensive Auto-Fix System (Version 4.0)

**Script `auto-fix.sh` will automatically fix all issues:**

```bash
# 1. Auto-Fix System is already integrated
# Run comprehensive auto-fix
sudo /home/n8n/auto-fix.sh

# 2. Fix specific parts
sudo /home/n8n/auto-fix.sh permissions    # Fix permissions
sudo /home/n8n/auto-fix.sh networks       # Fix Docker networks
sudo /home/n8n/auto-fix.sh database       # Fix PostgreSQL
sudo /home/n8n/auto-fix.sh ssl            # Fix SSL certificates
sudo /home/n8n/auto-fix.sh ports          # Fix port conflicts
sudo /home/n8n/auto-fix.sh health         # Fix health monitor
```

### 🔍 Auto-Fix System will fix the following issues:

1. **✅ Fix Permission Issues (1000:1000)**
   - Fix N8N directory permissions
   - Fix user/group ownership
   - Create missing directories

2. **🌐 Fix Docker Network & Service Names**
   - Recreate Docker networks
   - Fix container name resolution
   - Clean up old networks

3. **🐘 Fix PostgreSQL Database Issues**
   - Recreate users and databases
   - Fix connection issues
   - Test database connectivity

4. **🔒 Fix SSL Certificate Problems**
   - Update Caddyfile with correct container names
   - Add health checks
   - Fix reverse proxy configuration

5. **☁️ Fix Cloudflare Tunnel Issues**
   - Recreate tunnel configuration
   - Fix tunnel credentials
   - Restart tunnel service

6. **🔌 Fix Custom Port Issues**
   - Resolve port conflicts
   - Reassign available ports
   - Update configuration files

7. **🏥 Fix Health Monitor Issues**
   - Restart health monitor service
   - Fix health check scripts
   - Update monitoring configuration

8. **🚀 Restart Services in Correct Order**
   - PostgreSQL → N8N → API → Caddy → Cloudflare
   - Verify service health
   - Clean up old containers

9. **📊 Health Check All Components**
   - Test container connectivity
   - Verify domain accessibility
   - Check SSL certificates
   - Test Cloudflare tunnel

### 📋 Log and Monitoring (Enhanced)

Auto-Fix System will create detailed log file at `/var/log/n8n-auto-fix.log`

```bash
# View auto-fix logs
tail -f /var/log/n8n-auto-fix.log

# Monitor containers after fix
cd /home/n8n && docker-compose logs -f

# Check status
cd /home/n8n && docker-compose ps

# Health monitor status
systemctl status n8n-health-monitor
```

### 🎯 Expected results after auto-fix:

✅ All domains working normally  
✅ SSL certificates issued automatically  
✅ N8N instances starting stably  
✅ PostgreSQL connection successful  
✅ Cloudflare Tunnel working  
✅ Health Monitor active  
✅ No more HTTP 502 errors  
✅ Auto-Fix System ready  

**⏰ Note**: Wait 2-3 minutes after fixing for SSL certificates to be fully issued and Cloudflare Tunnel to connect.

### 🔄 Auto-Fix Integration with Telegram Bot

```bash
# Telegram Bot commands for auto-fix
/auto-fix                 # Run comprehensive auto-fix
/auto-fix permissions     # Fix permissions
/auto-fix networks        # Fix Docker networks
/auto-fix database        # Fix PostgreSQL
/auto-fix ssl             # Fix SSL certificates
/auto-fix health          # Fix health monitor
/auto-fix status          # View auto-fix status
``` 
#!/bin/bash

# =============================================================================
# 🚀 SCRIPT CÀI ĐẶT N8N MULTI-DOMAIN TỰ ĐỘNG 2025 - ENHANCED VERSION 3.1
# =============================================================================
# Tác giả: Nguyễn Ngọc Thiện
# YouTube: https://www.youtube.com/@kalvinthiensocial
# Zalo: 08.8888.4749
# Cập nhật: 01/07/2025
# Features: Multi-Domain + PostgreSQL + Telegram Bot + Google Drive + Web Dashboard + SSL Auto-Fix
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Global variables
INSTALL_DIR="/home/n8n"
DOMAINS=()
API_DOMAIN=""
BEARER_TOKEN=""
TELEGRAM_BOT_TOKEN=""
TELEGRAM_CHAT_ID=""
SSL_EMAIL=""
ENABLE_NEWS_API=false
ENABLE_TELEGRAM=false
ENABLE_MULTI_DOMAIN=false
ENABLE_POSTGRESQL=false
ENABLE_GOOGLE_DRIVE=false
ENABLE_TELEGRAM_BOT=false
CLEAN_INSTALL=false
SKIP_DOCKER=false

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

show_banner() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}              🚀 N8N MULTI-DOMAIN INSTALLER 2025 - VERSION 3.1 🚀             ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${WHITE} ✨ Multi-Domain N8N + PostgreSQL + Telegram Bot + Google Drive            ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 🔒 SSL Certificate tự động với Caddy + Smart Email Detection              ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 📰 News Content API với FastAPI + Newspaper4k                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 📱 Telegram Bot Management + Backup                                      ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} ☁️ Google Drive Auto Backup                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 📊 Web Dashboard Management + Health Check                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 🛠️ Auto-Fix Permission + Container Names + Database Issues              ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${YELLOW} 👨‍💻 Tác giả: Nguyễn Ngọc Thiện                                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 📺 YouTube: https://www.youtube.com/@kalvinthiensocial                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 📱 Zalo: 08.8888.4749                                                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 🎬 ĐĂNG KÝ KÊNH ĐỂ ỦNG HỘ MÌNH NHÉ! 🔔                                 ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 📅 Cập nhật: 01/07/2025 - Version 3.1 Enhanced                         ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

# =============================================================================
# ARGUMENT PARSING
# =============================================================================

show_help() {
    echo "Sử dụng: $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help              Hiển thị trợ giúp này"
    echo "  -d, --dir DIR           Thư mục cài đặt (mặc định: /home/n8n)"
    echo "  -c, --clean             Xóa cài đặt cũ trước khi cài mới"
    echo "  -s, --skip-docker       Bỏ qua cài đặt Docker (nếu đã có)"
    echo "  -m, --multi-domain      Bật chế độ multi-domain"
    echo "  -p, --postgresql        Sử dụng PostgreSQL thay vì SQLite"
    echo "  -g, --google-drive      Bật Google Drive backup"
    echo "  -t, --telegram-bot      Bật Telegram Bot management"
    echo ""
    echo "Ví dụ:"
    echo "  $0                      # Cài đặt single domain cơ bản"
    echo "  $0 -m -p               # Multi-domain với PostgreSQL"
    echo "  $0 -m -p -g -t         # Full features"
    echo "  $0 --clean -m -p       # Clean install multi-domain"
    echo ""
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -d|--dir)
                INSTALL_DIR="$2"
                shift 2
                ;;
            -c|--clean)
                CLEAN_INSTALL=true
                shift
                ;;
            -s|--skip-docker)
                SKIP_DOCKER=true
                shift
                ;;
            -m|--multi-domain)
                ENABLE_MULTI_DOMAIN=true
                shift
                ;;
            -p|--postgresql)
                ENABLE_POSTGRESQL=true
                shift
                ;;
            -g|--google-drive)
                ENABLE_GOOGLE_DRIVE=true
                shift
                ;;
            -t|--telegram-bot)
                ENABLE_TELEGRAM_BOT=true
                shift
                ;;
            *)
                error "Tham số không hợp lệ: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# =============================================================================
# SYSTEM CHECKS
# =============================================================================

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "Script này cần chạy với quyền root. Sử dụng: sudo $0"
        exit 1
    fi
}

check_os() {
    if [[ ! -f /etc/os-release ]]; then
        error "Không thể xác định hệ điều hành"
        exit 1
    fi
    
    . /etc/os-release
    if [[ "$ID" != "ubuntu" ]]; then
        warning "Script được thiết kế cho Ubuntu. Hệ điều hành hiện tại: $ID"
        read -p "Bạn có muốn tiếp tục? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

detect_environment() {
    if grep -q Microsoft /proc/version 2>/dev/null; then
        info "Phát hiện môi trường WSL"
        export WSL_ENV=true
    else
        export WSL_ENV=false
    fi
}

check_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        export DOCKER_COMPOSE="docker-compose"
        info "Sử dụng docker-compose"
    elif docker compose version &> /dev/null 2>&1; then
        export DOCKER_COMPOSE="docker compose"
        info "Sử dụng docker compose"
    else
        export DOCKER_COMPOSE=""
    fi
}

# =============================================================================
# SWAP MANAGEMENT
# =============================================================================

setup_swap() {
    log "🔄 Thiết lập swap memory..."
    
    # Get total RAM in GB
    local ram_gb=$(free -g | awk '/^Mem:/{print $2}')
    local swap_size
    
    # Calculate swap size based on RAM and multi-domain
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        if [[ $ram_gb -le 2 ]]; then
            swap_size="4G"
        elif [[ $ram_gb -le 4 ]]; then
            swap_size="6G"
        else
            swap_size="8G"
        fi
    else
        if [[ $ram_gb -le 2 ]]; then
            swap_size="2G"
        elif [[ $ram_gb -le 4 ]]; then
            swap_size="4G"
        else
            swap_size="4G"
        fi
    fi
    
    # Check if swap already exists
    if swapon --show | grep -q "/swapfile"; then
        info "Swap file đã tồn tại"
        return 0
    fi
    
    # Create swap file
    log "Tạo swap file ${swap_size}..."
    fallocate -l $swap_size /swapfile || dd if=/dev/zero of=/swapfile bs=1024 count=$((${swap_size%G} * 1024 * 1024))
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    
    # Make swap permanent
    if ! grep -q "/swapfile" /etc/fstab; then
        echo "/swapfile none swap sw 0 0" >> /etc/fstab
    fi
    
    success "Đã thiết lập swap ${swap_size}"
}

# =============================================================================
# USER INPUT FUNCTIONS
# =============================================================================

get_installation_mode() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                           🎯 CHỌN CHỂ ĐỘ CÀI ĐẶT                            ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Chọn chế độ cài đặt:${NC}"
    echo -e "  ${GREEN}1.${NC} Single Domain (Cơ bản) - 1 N8N instance"
    echo -e "  ${GREEN}2.${NC} Multi-Domain (Nâng cao) - Nhiều N8N instances"
    echo -e "  ${GREEN}3.${NC} Multi-Domain + PostgreSQL (Khuyến nghị)"
    echo -e "  ${GREEN}4.${NC} Full Features (Multi-Domain + PostgreSQL + Google Drive + Telegram Bot)"
    echo ""
    
    while true; do
        read -p "🎯 Chọn chế độ (1-4): " mode
        case $mode in
            1)
                ENABLE_MULTI_DOMAIN=false
                ENABLE_POSTGRESQL=false
                ENABLE_GOOGLE_DRIVE=false
                ENABLE_TELEGRAM_BOT=false
                break
                ;;
            2)
                ENABLE_MULTI_DOMAIN=true
                ENABLE_POSTGRESQL=false
                ENABLE_GOOGLE_DRIVE=false
                ENABLE_TELEGRAM_BOT=false
                break
                ;;
            3)
                ENABLE_MULTI_DOMAIN=true
                ENABLE_POSTGRESQL=true
                ENABLE_GOOGLE_DRIVE=false
                ENABLE_TELEGRAM_BOT=false
                break
                ;;
            4)
                ENABLE_MULTI_DOMAIN=true
                ENABLE_POSTGRESQL=true
                ENABLE_GOOGLE_DRIVE=true
                ENABLE_TELEGRAM_BOT=true
                break
                ;;
            *)
                error "Lựa chọn không hợp lệ. Vui lòng chọn 1-4."
                ;;
        esac
    done
    
    info "Chế độ đã chọn: $([[ "$ENABLE_MULTI_DOMAIN" == "true" ]] && echo "Multi-Domain" || echo "Single Domain")"
    [[ "$ENABLE_POSTGRESQL" == "true" ]] && info "Database: PostgreSQL"
    [[ "$ENABLE_GOOGLE_DRIVE" == "true" ]] && info "Google Drive Backup: Enabled"
    [[ "$ENABLE_TELEGRAM_BOT" == "true" ]] && info "Telegram Bot: Enabled"
}

get_domain_input() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                           🌐 CẤU HÌNH DOMAIN                                ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        echo -e "${WHITE}Multi-Domain Mode:${NC}"
        echo -e "  • Nhập nhiều domains (không giới hạn số lượng)"
        echo -e "  • Mỗi domain sẽ có N8N instance riêng"
        echo -e "  • Chia sẻ News API và PostgreSQL"
        echo ""
        
        while true; do
            read -p "🌐 Nhập domain (ví dụ: n8n1.example.com): " domain
            if [[ -n "$domain" && "$domain" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$ ]]; then
                DOMAINS+=("$domain")
                info "Đã thêm domain: $domain"
                
                read -p "➕ Thêm domain khác? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    break
                fi
            else
                error "Domain không hợp lệ. Vui lòng nhập lại."
            fi
        done
        
        # Set API domain to first domain
        API_DOMAIN="api.${DOMAINS[0]}"
        
    else
        echo -e "${WHITE}Single Domain Mode:${NC}"
        while true; do
            read -p "🌐 Nhập domain chính cho N8N (ví dụ: n8n.example.com): " domain
            if [[ -n "$domain" && "$domain" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$ ]]; then
                DOMAINS=("$domain")
                API_DOMAIN="api.${domain}"
                break
            else
                error "Domain không hợp lệ. Vui lòng nhập lại."
            fi
        done
    fi
    
    echo ""
    info "📋 Tổng kết domains:"
    for i in "${!DOMAINS[@]}"; do
        info "  Instance $((i+1)): ${DOMAINS[$i]}"
    done
    info "  API Domain: ${API_DOMAIN}"
}

get_cleanup_option() {
    if [[ "$CLEAN_INSTALL" == "true" ]]; then
        return 0
    fi
    
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                           🗑️  CLEANUP OPTION                               ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ -d "$INSTALL_DIR" ]]; then
        warning "Phát hiện cài đặt N8N cũ tại: $INSTALL_DIR"
        read -p "🗑️  Bạn có muốn xóa cài đặt cũ và cài mới? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            CLEAN_INSTALL=true
        fi
    fi
}

get_ssl_email_config() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        🔒 SSL CERTIFICATE EMAIL                            ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}SSL Certificate Email được sử dụng để:${NC}"
    echo -e "  🔐 Đăng ký tài khoản Let's Encrypt"
    echo -e "  📧 Nhận thông báo về SSL certificates"
    echo -e "  🔄 Tự động renew certificates khi hết hạn"
    echo -e "  🚨 Cảnh báo khi certificates sắp hết hạn"
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        echo -e "  🌐 Quản lý SSL cho tất cả ${#DOMAINS[@]} domains"
    fi
    echo ""
    echo -e "${YELLOW}⚠️ Lưu ý quan trọng:${NC}"
    echo -e "  • KHÔNG sử dụng email @example.com (sẽ bị từ chối)"
    echo -e "  • Sử dụng email thật (Gmail, Yahoo, domain riêng...)"
    echo -e "  • Email này sẽ nhận notifications từ Let's Encrypt"
    echo -e "  • có thể nhập email rác, tuy nhiên sẽ khó theo dõi chứng chỉ này, nếu cảm thấy không cần thiết, có thể nhập mail rác."
    echo ""
    
    # Smart email detection from system
    SUGGESTED_EMAIL=""
    if [[ -n "$USER" && "$USER" != "root" ]]; then
        SUGGESTED_EMAIL="${USER}@gmail.com"
    elif command -v whoami &> /dev/null; then
        CURRENT_USER=$(whoami 2>/dev/null)
        if [[ -n "$CURRENT_USER" && "$CURRENT_USER" != "root" ]]; then
            SUGGESTED_EMAIL="${CURRENT_USER}@gmail.com"
        fi
    fi
    
    while true; do
        if [[ -n "$SUGGESTED_EMAIL" ]]; then
            echo -e "${BLUE}💡 Đề xuất: $SUGGESTED_EMAIL${NC}"
            read -p "📧 Nhập email cho SSL certificates (Enter=dùng đề xuất): " SSL_EMAIL
            if [[ -z "$SSL_EMAIL" ]]; then
                SSL_EMAIL="$SUGGESTED_EMAIL"
            fi
        else
            read -p "📧 Nhập email cho SSL certificates: " SSL_EMAIL
        fi
        
        # Validate email format và domain
        if [[ -n "$SSL_EMAIL" && "$SSL_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
            # Check for forbidden domains
            if [[ "$SSL_EMAIL" == *"@example.com" || "$SSL_EMAIL" == *"@example.org" || "$SSL_EMAIL" == *"@test.com" ]]; then
                error "Email domain bị cấm bởi Let's Encrypt. Vui lòng sử dụng email thật."
                continue
            fi
            
            # Confirm email
            echo ""
            info "Email SSL đã chọn: $SSL_EMAIL"
            read -p "✅ Xác nhận email này? (Y/n): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                break
            fi
        else
            error "Email không hợp lệ. Vui lòng nhập email đúng định dạng."
        fi
    done
    
    success "Đã thiết lập SSL email: $SSL_EMAIL"
}

get_news_api_config() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        📰 NEWS CONTENT API                                 ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}News Content API cho phép:${NC}"
    echo -e "  📰 Cào nội dung bài viết từ bất kỳ website nào"
    echo -e "  📡 Parse RSS feeds để lấy tin tức mới nhất"
    echo -e "  🔍 Tìm kiếm và phân tích nội dung tự động"
    echo -e "  🤖 Tích hợp trực tiếp vào N8N workflows"
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        echo -e "  🌐 Chia sẻ cho tất cả N8N instances"
    fi
    echo ""
    
    read -p "📰 Bạn có muốn cài đặt News Content API? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        ENABLE_NEWS_API=false
        return 0
    fi
    
    ENABLE_NEWS_API=true
    
    echo ""
    echo -e "${YELLOW}🔐 Thiết lập Bearer Token cho News API:${NC}"
    echo -e "  • Token phải có ít nhất 20 ký tự"
    echo -e "  • Chỉ chứa chữ cái và số"
    echo -e "  • Sẽ được sử dụng để xác thực API calls"
    echo ""
    
    while true; do
        read -p "🔑 Nhập Bearer Token (ít nhất 20 ký tự): " BEARER_TOKEN
        if [[ ${#BEARER_TOKEN} -ge 20 && "$BEARER_TOKEN" =~ ^[a-zA-Z0-9]+$ ]]; then
            break
        else
            error "Token phải có ít nhất 20 ký tự và chỉ chứa chữ cái, số."
        fi
    done
    
    success "Đã thiết lập Bearer Token cho News API"
}

get_telegram_config() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        📱 TELEGRAM BACKUP                                  ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Telegram Backup cho phép:${NC}"
    echo -e "  🔄 Tự động backup workflows & credentials mỗi ngày"
    echo -e "  📱 Gửi file backup qua Telegram Bot (nếu <50MB)"
    echo -e "  📊 Thông báo realtime về trạng thái backup"
    echo -e "  🗂️ Giữ 30 bản backup gần nhất tự động"
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        echo -e "  🌐 Backup tất cả N8N instances cùng lúc"
    fi
    echo ""
    
    read -p "📱 Bạn có muốn thiết lập Telegram Backup? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        ENABLE_TELEGRAM=false
        return 0
    fi
    
    ENABLE_TELEGRAM=true
    
    echo ""
    echo -e "${YELLOW}🤖 Hướng dẫn tạo Telegram Bot:${NC}"
    echo -e "  1. Mở Telegram, tìm @BotFather"
    echo -e "  2. Gửi lệnh: /newbot"
    echo -e "  3. Đặt tên và username cho bot"
    echo -e "  4. Copy Bot Token nhận được"
    echo ""
    
    while true; do
        read -p "🤖 Nhập Telegram Bot Token: " TELEGRAM_BOT_TOKEN
        if [[ -n "$TELEGRAM_BOT_TOKEN" && "$TELEGRAM_BOT_TOKEN" =~ ^[0-9]+:[a-zA-Z0-9_-]+$ ]]; then
            break
        else
            error "Bot Token không hợp lệ. Format: 123456789:ABCdefGHIjklMNOpqrsTUVwxyz"
        fi
    done
    
    echo ""
    echo -e "${YELLOW}🆔 Hướng dẫn lấy Chat ID:${NC}"
    echo -e "  • Cho cá nhân: Tìm @userinfobot, gửi /start"
    echo -e "  • Cho nhóm: Thêm bot vào nhóm, Chat ID bắt đầu bằng dấu trừ (-)"
    echo ""
    
    while true; do
        read -p "🆔 Nhập Telegram Chat ID: " TELEGRAM_CHAT_ID
        if [[ -n "$TELEGRAM_CHAT_ID" && "$TELEGRAM_CHAT_ID" =~ ^-?[0-9]+$ ]]; then
            break
        else
            error "Chat ID không hợp lệ. Phải là số (có thể có dấu trừ ở đầu)"
        fi
    done
    
    success "Đã thiết lập Telegram Backup"
}

get_google_drive_config() {
    if [[ "$ENABLE_GOOGLE_DRIVE" != "true" ]]; then
        return 0
    fi
    
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        ☁️  GOOGLE DRIVE BACKUP                             ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Google Drive Backup cho phép:${NC}"
    echo -e "  ☁️ Tự động upload backup lên Google Drive"
    echo -e "  📁 Tổ chức theo năm/tháng/domain"
    echo -e "  🔄 Easy restore từ bất kỳ đâu"
    echo -e "  🔐 OAuth2 authentication bảo mật"
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        echo -e "  🌐 Backup riêng cho từng domain"
    fi
    echo ""
    
    echo -e "${YELLOW}📋 Hướng dẫn thiết lập Google Drive API:${NC}"
    echo -e "  1. Truy cập: https://console.cloud.google.com/"
    echo -e "  2. Tạo project mới: 'N8N-Backup-System'"
    echo -e "  3. Enable Google Drive API"
    echo -e "  4. Tạo Service Account credentials"
    echo -e "  5. Download JSON credentials file"
    echo -e "  6. Share Google Drive folder với service account"
    echo ""
    
    read -p "☁️ Bạn đã thiết lập Google Drive API? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        warning "Bỏ qua Google Drive backup. Có thể thiết lập sau."
        ENABLE_GOOGLE_DRIVE=false
        return 0
    fi
    
    echo ""
    echo -e "${YELLOW}📁 Upload credentials file:${NC}"
    echo -e "  • Sử dụng SCP/SFTP để upload file JSON"
    echo -e "  • Đặt tại: /home/n8n/google_drive/credentials.json"
    echo -e "  • Script sẽ tự động detect và sử dụng"
    echo ""
    
    success "Google Drive backup sẽ được thiết lập"
}

get_telegram_bot_config() {
    if [[ "$ENABLE_TELEGRAM_BOT" != "true" ]]; then
        return 0
    fi
    
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        🤖 TELEGRAM BOT MANAGEMENT                          ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Telegram Bot Management cho phép:${NC}"
    echo -e "  🎛️ Quản lý từ xa hoàn toàn qua Telegram"
    echo -e "  📊 Real-time monitoring và alerts"
    echo -e "  🔄 Quick actions: restart, backup, logs"
    echo -e "  📈 Performance metrics realtime"
    echo -e "  🔒 Security: Chỉ Chat ID được ủy quyền"
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        echo -e "  🌐 Quản lý tất cả N8N instances"
    fi
    echo ""
    
    # Reuse Telegram config if already set
    if [[ -n "$TELEGRAM_BOT_TOKEN" && -n "$TELEGRAM_CHAT_ID" ]]; then
        info "Sử dụng Telegram config đã thiết lập cho Bot Management"
        return 0
    fi
    
    echo -e "${YELLOW}🤖 Thiết lập Telegram Bot cho Management:${NC}"
    echo -e "  • Có thể sử dụng bot khác với backup bot"
    echo -e "  • Hoặc sử dụng chung một bot"
    echo ""
    
    while true; do
        read -p "🤖 Nhập Telegram Bot Token cho Management: " TELEGRAM_BOT_TOKEN
        if [[ -n "$TELEGRAM_BOT_TOKEN" && "$TELEGRAM_BOT_TOKEN" =~ ^[0-9]+:[a-zA-Z0-9_-]+$ ]]; then
            break
        else
            error "Bot Token không hợp lệ. Format: 123456789:ABCdefGHIjklMNOpqrsTUVwxyz"
        fi
    done
    
    while true; do
        read -p "🆔 Nhập Telegram Chat ID cho Management: " TELEGRAM_CHAT_ID
        if [[ -n "$TELEGRAM_CHAT_ID" && "$TELEGRAM_CHAT_ID" =~ ^-?[0-9]+$ ]]; then
            break
        else
            error "Chat ID không hợp lệ. Phải là số (có thể có dấu trừ ở đầu)"
        fi
    done
    
    success "Đã thiết lập Telegram Bot Management"
}

# =============================================================================
# DNS VERIFICATION
# =============================================================================

verify_dns() {
    log "🔍 Kiểm tra DNS cho tất cả domains..."
    
    # Get server IP
    local server_ip=$(curl -s https://api.ipify.org || curl -s http://ipv4.icanhazip.com || echo "unknown")
    info "IP máy chủ: ${server_ip}"
    
    local dns_issues=false
    
    # Check each domain
    for domain in "${DOMAINS[@]}"; do
        local domain_ip=$(dig +short "$domain" A | tail -n1)
        info "IP của ${domain}: ${domain_ip:-"không tìm thấy"}"
        
        if [[ "$domain_ip" != "$server_ip" ]]; then
            warning "DNS chưa trỏ đúng cho domain: $domain"
            dns_issues=true
        fi
    done
    
    # Check API domain
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        local api_domain_ip=$(dig +short "$API_DOMAIN" A | tail -n1)
        info "IP của ${API_DOMAIN}: ${api_domain_ip:-"không tìm thấy"}"
        
        if [[ "$api_domain_ip" != "$server_ip" ]]; then
            warning "DNS chưa trỏ đúng cho API domain: $API_DOMAIN"
            dns_issues=true
        fi
    fi
    
    if [[ "$dns_issues" == "true" ]]; then
        warning "DNS chưa trỏ đúng về máy chủ!"
        echo ""
        echo -e "${YELLOW}Hướng dẫn cấu hình DNS:${NC}"
        echo -e "  1. Đăng nhập vào trang quản lý domain"
        echo -e "  2. Tạo các bản ghi A record:"
        for domain in "${DOMAINS[@]}"; do
            echo -e "     • ${domain} → ${server_ip}"
        done
        if [[ "$ENABLE_NEWS_API" == "true" ]]; then
            echo -e "     • ${API_DOMAIN} → ${server_ip}"
        fi
        echo -e "  3. Đợi 5-60 phút để DNS propagation"
        echo ""
        
        read -p "🤔 Bạn có muốn tiếp tục cài đặt? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        success "DNS đã được cấu hình đúng cho tất cả domains"
    fi
}

# =============================================================================
# CLEANUP FUNCTIONS
# =============================================================================

cleanup_old_installation() {
    if [[ "$CLEAN_INSTALL" != "true" ]]; then
        return 0
    fi
    
    log "🗑️ Xóa cài đặt cũ..."
    
    # Stop and remove containers
    if [[ -d "$INSTALL_DIR" ]]; then
        cd "$INSTALL_DIR"
        if [[ -n "$DOCKER_COMPOSE" ]]; then
            $DOCKER_COMPOSE down --volumes --remove-orphans 2>/dev/null || true
        fi
    fi
    
    # Remove Docker images
    docker rmi n8n-custom-ffmpeg:latest news-api:latest 2>/dev/null || true
    
    # Remove installation directory
    rm -rf "$INSTALL_DIR"
    
    # Remove cron jobs
    crontab -l 2>/dev/null | grep -v "/home/n8n" | crontab - 2>/dev/null || true
    
    # Remove systemd services
    systemctl stop n8n-telegram-bot 2>/dev/null || true
    systemctl disable n8n-telegram-bot 2>/dev/null || true
    rm -f /etc/systemd/system/n8n-telegram-bot.service
    
    systemctl stop n8n-dashboard 2>/dev/null || true
    systemctl disable n8n-dashboard 2>/dev/null || true
    rm -f /etc/systemd/system/n8n-dashboard.service
    
    systemctl daemon-reload
    
    success "Đã xóa cài đặt cũ"
}

# =============================================================================
# DOCKER INSTALLATION
# =============================================================================

install_docker() {
    if [[ "$SKIP_DOCKER" == "true" ]]; then
        info "Bỏ qua cài đặt Docker"
        return 0
    fi
    
    if command -v docker &> /dev/null; then
        info "Docker đã được cài đặt"
        
        # Check if Docker is running
        if ! docker info &> /dev/null; then
            log "Khởi động Docker daemon..."
            systemctl start docker
            systemctl enable docker
        fi
        
        # Install docker-compose if not available
        if [[ -z "$DOCKER_COMPOSE" ]]; then
            log "Cài đặt docker-compose..."
            apt update
            apt install -y docker-compose
            export DOCKER_COMPOSE="docker-compose"
        fi
        
        return 0
    fi
    
    log "📦 Cài đặt Docker..."
    
    # Update system
    apt update
    apt install -y apt-transport-https ca-certificates curl gnupg lsb-release python3 python3-pip
    
    # Add Docker GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-compose
    
    # Start and enable Docker
    systemctl start docker
    systemctl enable docker
    
    # Add current user to docker group
    usermod -aG docker $SUDO_USER 2>/dev/null || true
    
    export DOCKER_COMPOSE="docker-compose"
    success "Đã cài đặt Docker thành công"
}

# =============================================================================
# PROJECT SETUP
# =============================================================================

create_project_structure() {
    log "📁 Tạo cấu trúc thư mục..."
    
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Create directories
    mkdir -p files/backup_full
    mkdir -p files/temp
    mkdir -p files/youtube_content_anylystic
    mkdir -p logs
    
    # Create instance directories for multi-domain
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            mkdir -p "files/n8n_instance_$((i+1))"
        done
    fi
    
    # Create PostgreSQL data directory
    if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
        mkdir -p postgres_data
    fi
    
    # Create News API directory
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        mkdir -p news_api
    fi
    
    # Create Google Drive directory
    if [[ "$ENABLE_GOOGLE_DRIVE" == "true" ]]; then
        mkdir -p google_drive
    fi
    
    # Create Telegram Bot directory
    if [[ "$ENABLE_TELEGRAM_BOT" == "true" ]]; then
        mkdir -p telegram_bot
    fi
    
    # Create Dashboard directory
    mkdir -p dashboard
    
    # Create Security directory
    mkdir -p security
    
    # Create Management directory
    mkdir -p management
    
    # Copy fix script to installation directory
    if [[ -f "$(dirname "$0")/fix_n8n.sh" ]]; then
        cp "$(dirname "$0")/fix_n8n.sh" "$INSTALL_DIR/"
        chmod +x "$INSTALL_DIR/fix_n8n.sh"
        info "Đã copy script fix_n8n.sh vào thư mục cài đặt"
    else
        warning "Không tìm thấy fix_n8n.sh, sẽ tạo placeholder"
        cat > "$INSTALL_DIR/fix_n8n.sh" << 'FIXEOF'
#!/bin/bash
echo "Fix script sẽ được cập nhật sau. Vui lòng download từ:"
echo "https://github.com/your-repo/fix_n8n.sh"
FIXEOF
        chmod +x "$INSTALL_DIR/fix_n8n.sh"
    fi
    
    success "Đã tạo cấu trúc thư mục"
}

create_dockerfile() {
    log "🐳 Tạo Dockerfile cho N8N..."
    
    cat > "$INSTALL_DIR/Dockerfile" << 'EOF'
FROM n8nio/n8n:latest

USER root

# Install system dependencies
RUN apk add --no-cache \
    ffmpeg \
    python3 \
    python3-dev \
    py3-pip \
    chromium \
    chromium-chromedriver \
    curl \
    wget \
    git \
    build-base \
    linux-headers \
    postgresql-client

# Install yt-dlp
RUN pip3 install --break-system-packages yt-dlp

# Install Puppeteer dependencies
RUN npm install -g puppeteer

# Set Chrome path for Puppeteer
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Create directories
RUN mkdir -p /home/node/.n8n/nodes
RUN mkdir -p /data/youtube_content_anylystic

# Set permissions
RUN chown -R node:node /home/node/.n8n
RUN chown -R node:node /data

USER node

# Install additional N8N nodes
RUN npm install n8n-nodes-puppeteer

WORKDIR /data
EOF
    
    success "Đã tạo Dockerfile cho N8N"
}

create_postgresql_init() {
    if [[ "$ENABLE_POSTGRESQL" != "true" ]]; then
        return 0
    fi
    
    log "🐘 Tạo PostgreSQL init script..."
    
    cat > "$INSTALL_DIR/init-multi-db.sh" << 'EOF'
#!/bin/bash
set -e

# Create databases for each N8N instance
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create main database if not exists
    SELECT 'CREATE DATABASE n8n_db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'n8n_db')\gexec
    
    -- Create user if not exists
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'n8n_user') THEN
            CREATE USER n8n_user WITH PASSWORD 'n8n_password_2025';
        END IF;
    END
    \$\$;
    
    -- Grant privileges
    GRANT ALL PRIVILEGES ON DATABASE n8n_db TO n8n_user;
    ALTER USER n8n_user CREATEDB;
EOSQL

# Create instance-specific databases
for i in {1..10}; do
    DB_NAME="n8n_db_instance_$i"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL
        SELECT 'CREATE DATABASE $DB_NAME OWNER n8n_user' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME')\gexec
EOSQL
done

echo "PostgreSQL databases initialized successfully"
EOF
    
    chmod +x "$INSTALL_DIR/init-multi-db.sh"
    
    success "Đã tạo PostgreSQL init script"
}

create_news_api() {
    if [[ "$ENABLE_NEWS_API" != "true" ]]; then
        return 0
    fi
    
    log "📰 Tạo News Content API..."
    
    # Create requirements.txt
    cat > "$INSTALL_DIR/news_api/requirements.txt" << 'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
newspaper4k==0.9.3
user-agents==2.2.0
pydantic==2.5.0
python-multipart==0.0.6
requests==2.31.0
lxml==4.9.3
Pillow==10.1.0
nltk==3.8.1
beautifulsoup4==4.12.2
feedparser==6.0.10
python-dateutil==2.8.2
EOF
    
    # Create main.py (same as before but with enhanced features)
    cat > "$INSTALL_DIR/news_api/main.py" << 'EOF'
import os
import random
import logging
from datetime import datetime
from typing import List, Optional, Dict, Any
import feedparser
import requests
from fastapi import FastAPI, HTTPException, Depends, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
from pydantic import BaseModel, HttpUrl, Field
import newspaper
from newspaper import Article, Source
from user_agents import parse
import nltk

# Download required NLTK data
try:
    nltk.download('punkt', quiet=True)
    nltk.download('stopwords', quiet=True)
except:
    pass

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# FastAPI app
app = FastAPI(
    title="News Content API - Multi-Domain",
    description="Advanced News Content Extraction API with Multi-Domain Support",
    version="3.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Security
security = HTTPBearer()
NEWS_API_TOKEN = os.getenv("NEWS_API_TOKEN", "default_token")

# Random User Agents
USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:121.0) Gecko/20100101 Firefox/121.0",
    "Mozilla/5.0 (X11; Linux x86_64; rv:121.0) Gecko/20100101 Firefox/121.0",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Edge/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15"
]

def get_random_user_agent() -> str:
    """Get a random user agent string"""
    return random.choice(USER_AGENTS)

def verify_token(credentials: HTTPAuthorizationCredentials = Security(security)):
    """Verify Bearer token"""
    if credentials.credentials != NEWS_API_TOKEN:
        raise HTTPException(
            status_code=401,
            detail="Invalid authentication token"
        )
    return credentials.credentials

# Pydantic models
class ArticleRequest(BaseModel):
    url: HttpUrl
    language: str = Field(default="en", description="Language code (en, vi, zh, etc.)")
    extract_images: bool = Field(default=True, description="Extract images from article")
    summarize: bool = Field(default=False, description="Generate article summary")

class SourceRequest(BaseModel):
    url: HttpUrl
    max_articles: int = Field(default=10, ge=1, le=50, description="Maximum articles to extract")
    language: str = Field(default="en", description="Language code")

class FeedRequest(BaseModel):
    url: HttpUrl
    max_articles: int = Field(default=10, ge=1, le=50, description="Maximum articles to parse")

class ArticleResponse(BaseModel):
    title: str
    content: str
    summary: Optional[str] = None
    authors: List[str]
    publish_date: Optional[datetime] = None
    images: List[str]
    top_image: Optional[str] = None
    keywords: List[str]
    language: str
    word_count: int
    read_time_minutes: int
    url: str

class SourceResponse(BaseModel):
    source_url: str
    articles: List[ArticleResponse]
    total_articles: int
    categories: List[str]

class FeedResponse(BaseModel):
    feed_url: str
    feed_title: str
    articles: List[Dict[str, Any]]
    total_articles: int

# Helper functions
def create_newspaper_config(language: str = "en") -> newspaper.Config:
    """Create newspaper configuration with random user agent"""
    config = newspaper.Config()
    config.language = language
    config.browser_user_agent = get_random_user_agent()
    config.request_timeout = 30
    config.number_threads = 1
    config.thread_timeout_seconds = 30
    config.ignored_content_types_defaults = {
        'application/pdf', 'application/x-pdf', 'application/x-bzpdf',
        'application/x-gzpdf', 'application/msword', 'doc', 'text/plain'
    }
    return config

def extract_article_content(url: str, language: str = "en", extract_images: bool = True, summarize: bool = False) -> ArticleResponse:
    """Extract content from a single article"""
    try:
        config = create_newspaper_config(language)
        article = Article(url, config=config)
        
        # Download and parse
        article.download()
        article.parse()
        
        # Extract keywords and summary if requested
        keywords = []
        summary = None
        
        if article.text:
            try:
                article.nlp()
                keywords = article.keywords[:10]  # Limit to 10 keywords
                if summarize:
                    summary = article.summary
            except Exception as e:
                logger.warning(f"NLP processing failed for {url}: {e}")
        
        # Calculate read time (average 200 words per minute)
        word_count = len(article.text.split()) if article.text else 0
        read_time = max(1, round(word_count / 200))
        
        # Extract images
        images = []
        if extract_images:
            images = list(article.images)[:10]  # Limit to 10 images
        
        return ArticleResponse(
            title=article.title or "No title",
            content=article.text or "No content",
            summary=summary,
            authors=article.authors,
            publish_date=article.publish_date,
            images=images,
            top_image=article.top_image,
            keywords=keywords,
            language=language,
            word_count=word_count,
            read_time_minutes=read_time,
            url=url
        )
        
    except Exception as e:
        logger.error(f"Error extracting article {url}: {e}")
        raise HTTPException(status_code=400, detail=f"Failed to extract article: {str(e)}")

# API Routes
@app.get("/", response_class=HTMLResponse)
async def root():
    """API Homepage with documentation"""
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>News Content API - Multi-Domain</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }}
            .container {{ max-width: 900px; margin: 0 auto; background: white; padding: 40px; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }}
            h1 {{ color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 15px; margin-bottom: 30px; }}
            h2 {{ color: #34495e; margin-top: 40px; }}
            .endpoint {{ background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 15px 0; border-left: 4px solid #3498db; }}
            .method {{ background: #3498db; color: white; padding: 4px 12px; border-radius: 4px; font-size: 12px; font-weight: bold; }}
            .auth-info {{ background: linear-gradient(135deg, #e74c3c, #c0392b); color: white; padding: 20px; border-radius: 8px; margin: 25px 0; }}
            .token-change {{ background: linear-gradient(135deg, #f39c12, #e67e22); color: white; padding: 20px; border-radius: 8px; margin: 25px 0; }}
            code {{ background: #2c3e50; color: #ecf0f1; padding: 3px 8px; border-radius: 4px; font-family: 'Courier New', monospace; }}
            pre {{ background: #2c3e50; color: #ecf0f1; padding: 20px; border-radius: 8px; overflow-x: auto; font-family: 'Courier New', monospace; }}
            .feature {{ background: linear-gradient(135deg, #27ae60, #2ecc71); color: white; padding: 15px; border-radius: 8px; margin: 8px 0; }}
            .multi-domain {{ background: linear-gradient(135deg, #9b59b6, #8e44ad); color: white; padding: 20px; border-radius: 8px; margin: 25px 0; }}
            .stats {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin: 20px 0; }}
            .stat-card {{ background: linear-gradient(135deg, #34495e, #2c3e50); color: white; padding: 20px; border-radius: 8px; text-align: center; }}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 News Content API v3.0 - Multi-Domain</h1>
            <p>Advanced News Content Extraction API với <strong>Multi-Domain Support</strong>, <strong>Newspaper4k</strong> và <strong>Random User Agents</strong></p>
            
            <div class="multi-domain">
                <h3>🌐 Multi-Domain Features</h3>
                <p>API này được chia sẻ cho tất cả N8N instances trong hệ thống multi-domain:</p>
                <ul>
                    <li>✅ Shared API endpoint cho tất cả domains</li>
                    <li>✅ Optimized performance với connection pooling</li>
                    <li>✅ Centralized authentication và rate limiting</li>
                    <li>✅ Cross-domain CORS support</li>
                </ul>
            </div>
            
            <div class="auth-info">
                <h3>🔐 Authentication Required</h3>
                <p>Tất cả API calls yêu cầu Bearer Token trong header:</p>
                <code>Authorization: Bearer YOUR_TOKEN_HERE</code>
                <p><strong>Lưu ý:</strong> Token đã được đặt trong quá trình cài đặt và không hiển thị ở đây vì lý do bảo mật.</p>
            </div>

            <div class="token-change">
                <h3>🔧 Đổi Bearer Token</h3>
                <p><strong>One-liner command:</strong></p>
                <pre>cd /home/n8n && sed -i 's/NEWS_API_TOKEN=.*/NEWS_API_TOKEN="NEW_TOKEN"/' docker-compose.yml && docker-compose restart fastapi</pre>
            </div>
            
            <div class="stats">
                <div class="stat-card">
                    <h4>📊 API Version</h4>
                    <p>3.0.0</p>
                </div>
                <div class="stat-card">
                    <h4>🌍 Languages</h4>
                    <p>80+ Supported</p>
                </div>
                <div class="stat-card">
                    <h4>🎭 User Agents</h4>
                    <p>8 Random</p>
                </div>
                <div class="stat-card">
                    <h4>⚡ Performance</h4>
                    <p>Optimized</p>
                </div>
            </div>
            
            <h2>✨ Tính Năng</h2>
            <div class="feature">📰 Cào nội dung bài viết từ bất kỳ website nào</div>
            <div class="feature">📡 Parse RSS feeds để lấy tin tức mới nhất</div>
            <div class="feature">🔍 Tìm kiếm và phân tích nội dung tự động</div>
            <div class="feature">🌍 Hỗ trợ 80+ ngôn ngữ (Việt, Anh, Trung, Nhật...)</div>
            <div class="feature">🎭 Random User Agents để tránh bị block</div>
            <div class="feature">🤖 Tích hợp trực tiếp vào tất cả N8N instances</div>
            <div class="feature">🌐 Multi-domain support với shared resources</div>
            
            <h2>📖 API Endpoints</h2>
            
            <div class="endpoint">
                <span class="method">GET</span> <strong>/health</strong>
                <p>Kiểm tra trạng thái API và system info</p>
            </div>
            
            <div class="endpoint">
                <span class="method">POST</span> <strong>/extract-article</strong>
                <p>Lấy nội dung bài viết từ URL</p>
                <pre>{{"url": "https://example.com/article", "language": "vi", "extract_images": true, "summarize": true}}</pre>
            </div>
            
            <div class="endpoint">
                <span class="method">POST</span> <strong>/extract-source</strong>
                <p>Cào nhiều bài viết từ website</p>
                <pre>{{"url": "https://dantri.com.vn", "max_articles": 10, "language": "vi"}}</pre>
            </div>
            
            <div class="endpoint">
                <span class="method">POST</span> <strong>/parse-feed</strong>
                <p>Phân tích RSS feeds</p>
                <pre>{{"url": "https://dantri.com.vn/rss.xml", "max_articles": 10}}</pre>
            </div>
            
            <h2>🔗 Documentation</h2>
            <p>
                <a href="/docs" target="_blank" style="color: #3498db; text-decoration: none; font-weight: bold;">📚 Swagger UI</a> | 
                <a href="/redoc" target="_blank" style="color: #3498db; text-decoration: none; font-weight: bold;">📖 ReDoc</a>
            </p>
            
            <h2>💻 Ví Dụ cURL</h2>
            <pre>curl -X POST "https://api.yourdomain.com/extract-article" \\
     -H "Content-Type: application/json" \\
     -H "Authorization: Bearer YOUR_TOKEN" \\
     -d '{{"url": "https://dantri.com.vn/the-gioi.htm", "language": "vi"}}'</pre>
            
            <hr style="margin: 40px 0; border: none; height: 1px; background: linear-gradient(to right, transparent, #bdc3c7, transparent);">
            <p style="text-align: center; color: #7f8c8d; font-size: 14px;">
                🚀 Powered by <strong>Newspaper4k</strong> | 
                👨‍💻 Created by <strong>Nguyễn Ngọc Thiện</strong> | 
                📺 <a href="https://www.youtube.com/@kalvinthiensocial" style="color: #e74c3c;">YouTube Channel</a> |
                🌐 <strong>Multi-Domain Support</strong>
            </p>
        </div>
    </body>
    </html>
    """
    return html_content

@app.get("/health")
async def health_check():
    """Health check endpoint with system info"""
    return {
        "status": "healthy",
        "timestamp": datetime.now(),
        "version": "3.0.0",
        "mode": "multi-domain",
        "features": [
            "Article extraction",
            "Source crawling", 
            "RSS feed parsing",
            "Multi-language support",
            "Random User Agents",
            "Image extraction",
            "Keyword extraction",
            "Content summarization",
            "Multi-domain support",
            "Shared API resources"
        ]
    }

@app.post("/extract-article", response_model=ArticleResponse)
async def extract_article(
    request: ArticleRequest,
    token: str = Depends(verify_token)
):
    """Extract content from a single article URL"""
    logger.info(f"Extracting article: {request.url}")
    return extract_article_content(
        str(request.url),
        request.language,
        request.extract_images,
        request.summarize
    )

@app.post("/extract-source", response_model=SourceResponse)
async def extract_source(
    request: SourceRequest,
    token: str = Depends(verify_token)
):
    """Extract multiple articles from a news source"""
    try:
        logger.info(f"Extracting source: {request.url}")
        
        config = create_newspaper_config(request.language)
        source = Source(str(request.url), config=config)
        source.build()
        
        # Limit articles
        articles_to_process = source.articles[:request.max_articles]
        
        extracted_articles = []
        for article in articles_to_process:
            try:
                article_response = extract_article_content(
                    article.url,
                    request.language,
                    extract_images=True,
                    summarize=False
                )
                extracted_articles.append(article_response)
            except Exception as e:
                logger.warning(f"Failed to extract article {article.url}: {e}")
                continue
        
        return SourceResponse(
            source_url=str(request.url),
            articles=extracted_articles,
            total_articles=len(extracted_articles),
            categories=source.category_urls()[:10]  # Limit categories
        )
        
    except Exception as e:
        logger.error(f"Error extracting source {request.url}: {e}")
        raise HTTPException(status_code=400, detail=f"Failed to extract source: {str(e)}")

@app.post("/parse-feed", response_model=FeedResponse)
async def parse_feed(
    request: FeedRequest,
    token: str = Depends(verify_token)
):
    """Parse RSS/Atom feed and extract articles"""
    try:
        logger.info(f"Parsing feed: {request.url}")
        
        # Set random user agent for requests
        headers = {'User-Agent': get_random_user_agent()}
        
        # Parse feed
        feed = feedparser.parse(str(request.url), request_headers=headers)
        
        if feed.bozo:
            logger.warning(f"Feed parsing warning for {request.url}: {feed.bozo_exception}")
        
        # Extract articles
        articles = []
        entries_to_process = feed.entries[:request.max_articles]
        
        for entry in entries_to_process:
            article_data = {
                "title": getattr(entry, 'title', 'No title'),
                "link": getattr(entry, 'link', ''),
                "description": getattr(entry, 'description', ''),
                "published": getattr(entry, 'published', ''),
                "author": getattr(entry, 'author', ''),
                "tags": [tag.term for tag in getattr(entry, 'tags', [])],
                "summary": getattr(entry, 'summary', '')
            }
            articles.append(article_data)
        
        return FeedResponse(
            feed_url=str(request.url),
            feed_title=getattr(feed.feed, 'title', 'Unknown Feed'),
            articles=articles,
            total_articles=len(articles)
        )
        
    except Exception as e:
        logger.error(f"Error parsing feed {request.url}: {e}")
        raise HTTPException(status_code=400, detail=f"Failed to parse feed: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF
    
    # Create Dockerfile for News API
    cat > "$INSTALL_DIR/news_api/Dockerfile" << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libxml2-dev \
    libxslt-dev \
    libjpeg-dev \
    zlib1g-dev \
    libpng-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
EOF
    
    success "Đã tạo News Content API"
}

create_docker_compose() {
    log "🐳 Tạo docker-compose.yml..."
    
    cat > "$INSTALL_DIR/docker-compose.yml" << EOF
version: '3.8'

services:
EOF

    # Add N8N services
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            local instance_num=$((i+1))
            local domain="${DOMAINS[$i]}"
            local port=$((5678 + i))
            
            cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
  n8n_${instance_num}:
    build: .
    container_name: n8n-container-${instance_num}
    restart: unless-stopped
    ports:
      - "127.0.0.1:${port}:5678"
    environment:
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=production
      - WEBHOOK_URL=https://${domain}/
      - GENERIC_TIMEZONE=Asia/Ho_Chi_Minh
      - N8N_METRICS=true
      - N8N_LOG_LEVEL=info
      - N8N_LOG_OUTPUT=console
      - N8N_USER_FOLDER=/home/node
      - N8N_ENCRYPTION_KEY=\${N8N_ENCRYPTION_KEY_${instance_num}:-$(openssl rand -hex 32)}
EOF

            if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
                cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n_db_instance_${instance_num}
      - DB_POSTGRESDB_USER=n8n_user
      - DB_POSTGRESDB_PASSWORD=n8n_password_2025
      - DB_POSTGRESDB_SCHEMA=n8n_instance_${instance_num}
EOF
            else
                cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
      - DB_TYPE=sqlite
      - DB_SQLITE_DATABASE=/home/node/.n8n/database.sqlite
EOF
            fi

            cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
      - N8N_BASIC_AUTH_ACTIVE=false
      - N8N_DISABLE_PRODUCTION_MAIN_PROCESS=false
      - EXECUTIONS_TIMEOUT=3600
      - EXECUTIONS_TIMEOUT_MAX=7200
      - N8N_EXECUTIONS_DATA_MAX_SIZE=500MB
      - N8N_BINARY_DATA_TTL=1440
      - N8N_BINARY_DATA_MODE=filesystem
    volumes:
      - ./files/n8n_instance_${instance_num}:/home/node/.n8n
      - ./files/youtube_content_anylystic:/data/youtube_content_anylystic
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - n8n_network
EOF

            if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
                cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
    depends_on:
      - postgres
EOF
            fi

            echo "" >> "$INSTALL_DIR/docker-compose.yml"
        done
    else
        # Single domain setup
        cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
  n8n:
    build: .
    container_name: n8n-container
    restart: unless-stopped
    ports:
      - "127.0.0.1:5678:5678"
    environment:
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=production
      - WEBHOOK_URL=https://${DOMAINS[0]}/
      - GENERIC_TIMEZONE=Asia/Ho_Chi_Minh
      - N8N_METRICS=true
      - N8N_LOG_LEVEL=info
      - N8N_LOG_OUTPUT=console
      - N8N_USER_FOLDER=/home/node
      - N8N_ENCRYPTION_KEY=\${N8N_ENCRYPTION_KEY:-$(openssl rand -hex 32)}
EOF

        if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
            cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n_db
      - DB_POSTGRESDB_USER=n8n_user
      - DB_POSTGRESDB_PASSWORD=n8n_password_2025
EOF
        else
            cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
      - DB_TYPE=sqlite
      - DB_SQLITE_DATABASE=/home/node/.n8n/database.sqlite
EOF
        fi

        cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
      - N8N_BASIC_AUTH_ACTIVE=false
      - N8N_DISABLE_PRODUCTION_MAIN_PROCESS=false
      - EXECUTIONS_TIMEOUT=3600
      - EXECUTIONS_TIMEOUT_MAX=7200
      - N8N_EXECUTIONS_DATA_MAX_SIZE=500MB
      - N8N_BINARY_DATA_TTL=1440
      - N8N_BINARY_DATA_MODE=filesystem
    volumes:
      - ./files:/home/node/.n8n
      - ./files/youtube_content_anylystic:/data/youtube_content_anylystic
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - n8n_network
EOF

        if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
            cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
    depends_on:
      - postgres
EOF
        fi

        echo "" >> "$INSTALL_DIR/docker-compose.yml"
    fi

    # Add PostgreSQL service
    if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
        cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
  postgres:
    image: postgres:15-alpine
    container_name: postgres-n8n
    restart: unless-stopped
    environment:
      - POSTGRES_DB=postgres
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres_password_2025
    volumes:
      - ./postgres_data:/var/lib/postgresql/data
      - ./init-multi-db.sh:/docker-entrypoint-initdb.d/init-multi-db.sh
    networks:
      - n8n_network
    ports:
      - "127.0.0.1:5432:5432"

EOF
    fi

    # Add Caddy service
    cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
  caddy:
    image: caddy:latest
    container_name: caddy-proxy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    networks:
      - n8n_network
    depends_on:
EOF

    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            local instance_num=$((i+1))
            cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
      - n8n_${instance_num}
EOF
        done
    else
        cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
      - n8n
EOF
    fi

    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
      - fastapi

  fastapi:
    build: ./news_api
    container_name: news-api-container
    restart: unless-stopped
    ports:
      - "127.0.0.1:8000:8000"
    environment:
      - NEWS_API_TOKEN=${BEARER_TOKEN}
      - PYTHONUNBUFFERED=1
    networks:
      - n8n_network
EOF
    fi

    cat >> "$INSTALL_DIR/docker-compose.yml" << 'EOF'

volumes:
  caddy_data:
  caddy_config:

networks:
  n8n_network:
    driver: bridge
EOF
    
    success "Đã tạo docker-compose.yml"
}

create_caddyfile() {
    log "🌐 Tạo Caddyfile..."
    
    cat > "$INSTALL_DIR/Caddyfile" << EOF
{
    email ${SSL_EMAIL}
    acme_ca https://acme-v02.api.letsencrypt.org/directory
}

EOF

    # Add N8N domains
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            local instance_num=$((i+1))
            local domain="${DOMAINS[$i]}"
            
            cat >> "$INSTALL_DIR/Caddyfile" << EOF
${domain} {
    reverse_proxy n8n-container-${instance_num}:5678 {
        health_uri /healthz
        health_interval 30s
        health_timeout 10s
    }
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    
    encode gzip
    
    log {
        output file /var/log/caddy/n8n_${instance_num}.log {
            roll_size 10mb
            roll_keep 5
        }
        format json
    }
}

EOF
        done
    else
        cat >> "$INSTALL_DIR/Caddyfile" << EOF
${DOMAINS[0]} {
    reverse_proxy n8n-container:5678 {
        health_uri /healthz
        health_interval 30s
        health_timeout 10s
    }
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    
    encode gzip
    
    log {
        output file /var/log/caddy/n8n.log {
            roll_size 10mb
            roll_keep 5
        }
        format json
    }
}

EOF
    fi

    # Add API domain
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        cat >> "$INSTALL_DIR/Caddyfile" << EOF
${API_DOMAIN} {
    reverse_proxy news-api-container:8000 {
        health_uri /health
        health_interval 30s
        health_timeout 10s
    }
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
        Access-Control-Allow-Origin "*"
        Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
        Access-Control-Allow-Headers "Content-Type, Authorization"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    
    encode gzip
    
    log {
        output file /var/log/caddy/api.log {
            roll_size 10mb
            roll_keep 5
        }
        format json
    }
}
EOF
    fi
    
    success "Đã tạo Caddyfile với email SSL: $SSL_EMAIL"
}

# =============================================================================
# BACKUP SYSTEM
# =============================================================================

create_backup_scripts() {
    log "💾 Tạo hệ thống backup enhanced..."
    
    # Enhanced backup script
    cat > "$INSTALL_DIR/backup-workflows-enhanced.sh" << 'EOF'
#!/bin/bash

# =============================================================================
# N8N ENHANCED BACKUP SCRIPT - Multi-Domain Support
# =============================================================================

set -e

BACKUP_DIR="/home/n8n/files/backup_full"
LOG_FILE="$BACKUP_DIR/backup.log"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="n8n_backup_$TIMESTAMP"
TEMP_DIR="/tmp/$BACKUP_NAME"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}" | tee -a "$LOG_FILE"
}

# Check Docker Compose command
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    error "Docker Compose không tìm thấy!"
    exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"
mkdir -p "$TEMP_DIR"

log "🔄 Bắt đầu Enhanced N8N Backup..."

# Detect multi-domain setup
cd /home/n8n
MULTI_DOMAIN=false
INSTANCE_COUNT=0

if docker ps --filter "name=n8n-container-" --format "{{.Names}}" | grep -q "n8n-container-"; then
    MULTI_DOMAIN=true
    INSTANCE_COUNT=$(docker ps --filter "name=n8n-container-" --format "{{.Names}}" | wc -l)
    log "📊 Phát hiện Multi-Domain setup với $INSTANCE_COUNT instances"
else
    log "📊 Phát hiện Single Domain setup"
fi

# Create backup structure
mkdir -p "$TEMP_DIR/instances"
mkdir -p "$TEMP_DIR/config"
mkdir -p "$TEMP_DIR/ssl"

if [[ "$MULTI_DOMAIN" == "true" ]]; then
    mkdir -p "$TEMP_DIR/postgres"
fi

# Backup N8N instances
log "📋 Backup N8N instances..."

if [[ "$MULTI_DOMAIN" == "true" ]]; then
    # Multi-domain backup
    for i in $(seq 1 $INSTANCE_COUNT); do
        CONTAINER_NAME="n8n-container-$i"
        INSTANCE_DIR="$TEMP_DIR/instances/instance_$i"
        mkdir -p "$INSTANCE_DIR"
        
        log "📦 Backup instance $i ($CONTAINER_NAME)..."
        
        # Export workflows
        if docker exec $CONTAINER_NAME which n8n &> /dev/null; then
            docker exec $CONTAINER_NAME n8n export:workflow --all --output=/tmp/workflows.json 2>/dev/null || true
            docker cp $CONTAINER_NAME:/tmp/workflows.json "$INSTANCE_DIR/" 2>/dev/null || true
            
            docker exec $CONTAINER_NAME n8n export:credentials --all --output=/tmp/credentials.json 2>/dev/null || true
            docker cp $CONTAINER_NAME:/tmp/credentials.json "$INSTANCE_DIR/" 2>/dev/null || true
        fi
        
        # Copy instance data
        if [[ -d "/home/n8n/files/n8n_instance_$i" ]]; then
            cp -r "/home/n8n/files/n8n_instance_$i"/* "$INSTANCE_DIR/" 2>/dev/null || true
        fi
        
        # Create instance metadata
        cat > "$INSTANCE_DIR/metadata.json" << EOL
{
    "instance_id": $i,
    "container_name": "$CONTAINER_NAME",
    "backup_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "domain": "$(grep -E "^[a-zA-Z0-9.-]+.*reverse_proxy.*n8n_$i" /home/n8n/Caddyfile | awk '{print $1}' || echo 'unknown')",
    "database_type": "$(docker exec $CONTAINER_NAME printenv DB_TYPE 2>/dev/null || echo 'sqlite')"
}
EOL
    done
    
    # Backup PostgreSQL databases
    if docker ps | grep -q "postgres-n8n"; then
        log "🐘 Backup PostgreSQL databases..."
        
        for i in $(seq 1 $INSTANCE_COUNT); do
            DB_NAME="n8n_db_instance_$i"
            docker exec postgres-n8n pg_dump -U n8n_user -d $DB_NAME > "$TEMP_DIR/postgres/dump_instance_$i.sql" 2>/dev/null || true
        done
        
        # Backup main database
        docker exec postgres-n8n pg_dump -U n8n_user -d n8n_db > "$TEMP_DIR/postgres/dump_main.sql" 2>/dev/null || true
    fi
    
else
    # Single domain backup
    INSTANCE_DIR="$TEMP_DIR/instances/instance_1"
    mkdir -p "$INSTANCE_DIR"
    
    log "📦 Backup single N8N instance..."
    
    # Export workflows
    if docker exec n8n-container which n8n &> /dev/null; then
        docker exec n8n-container n8n export:workflow --all --output=/tmp/workflows.json 2>/dev/null || true
        docker cp n8n-container:/tmp/workflows.json "$INSTANCE_DIR/" 2>/dev/null || true
        
        docker exec n8n-container n8n export:credentials --all --output=/tmp/credentials.json 2>/dev/null || true
        docker cp n8n-container:/tmp/credentials.json "$INSTANCE_DIR/" 2>/dev/null || true
    fi
    
    # Copy instance data
    if [[ -d "/home/n8n/files" ]]; then
        cp -r /home/n8n/files/* "$INSTANCE_DIR/" 2>/dev/null || true
    fi
    
    # Create instance metadata
    cat > "$INSTANCE_DIR/metadata.json" << EOL
{
    "instance_id": 1,
    "container_name": "n8n-container",
    "backup_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "domain": "$(grep -E "^[a-zA-Z0-9.-]+.*reverse_proxy.*n8n:" /home/n8n/Caddyfile | awk '{print $1}' || echo 'unknown')",
    "database_type": "$(docker exec n8n-container printenv DB_TYPE 2>/dev/null || echo 'sqlite')"
}
EOL
fi

# Backup configuration files
log "🔧 Backup configuration files..."
cp docker-compose.yml "$TEMP_DIR/config/" 2>/dev/null || true
cp Caddyfile "$TEMP_DIR/config/" 2>/dev/null || true
cp telegram_config.txt "$TEMP_DIR/config/" 2>/dev/null || true

# Backup SSL certificates
log "🔒 Backup SSL certificates..."
if docker volume ls | grep -q "n8n_caddy_data"; then
    docker run --rm -v n8n_caddy_data:/data -v "$TEMP_DIR/ssl":/backup alpine tar czf /backup/caddy_data.tar.gz -C /data . 2>/dev/null || true
fi

# Create main backup metadata
log "📊 Tạo backup metadata..."
cat > "$TEMP_DIR/backup_metadata.json" << EOL
{
    "backup_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "backup_name": "$BACKUP_NAME",
    "backup_type": "enhanced_multi_domain",
    "multi_domain": $MULTI_DOMAIN,
    "instance_count": $INSTANCE_COUNT,
    "n8n_version": "$(docker exec $(docker ps --filter "name=n8n-container" --format "{{.Names}}" | head -1) n8n --version 2>/dev/null || echo 'unknown')",
    "postgresql_enabled": $(docker ps | grep -q "postgres-n8n" && echo "true" || echo "false"),
    "domains": [
$(if [[ "$MULTI_DOMAIN" == "true" ]]; then
    for i in $(seq 1 $INSTANCE_COUNT); do
        DOMAIN=$(grep -E "^[a-zA-Z0-9.-]+.*reverse_proxy.*n8n_$i" /home/n8n/Caddyfile | awk '{print $1}' || echo 'unknown')
        echo "        \"$DOMAIN\"$([ $i -lt $INSTANCE_COUNT ] && echo ",")"
    done
else
    DOMAIN=$(grep -E "^[a-zA-Z0-9.-]+.*reverse_proxy.*n8n:" /home/n8n/Caddyfile | awk '{print $1}' || echo 'unknown')
    echo "        \"$DOMAIN\""
fi)
    ],
    "files": {
        "instances": "$(find $TEMP_DIR/instances -name "*.json" | wc -l) files",
        "config": "$(find $TEMP_DIR/config -name "*" | wc -l) files",
        "ssl": "$(find $TEMP_DIR/ssl -name "*" | wc -l) files",
        "postgres": "$(find $TEMP_DIR/postgres -name "*.sql" 2>/dev/null | wc -l || echo 0) files"
    }
}
EOL

# Create compressed backup
log "📦 Tạo file backup nén..."
cd /tmp
zip -r "$BACKUP_DIR/$BACKUP_NAME.zip" "$BACKUP_NAME/" > /dev/null 2>&1

# Get backup size
BACKUP_SIZE=$(ls -lh "$BACKUP_DIR/$BACKUP_NAME.zip" | awk '{print $5}')
log "✅ Backup hoàn thành: $BACKUP_NAME.zip ($BACKUP_SIZE)"

# Cleanup temp directory
rm -rf "$TEMP_DIR"

# Keep only last 30 backups
log "🧹 Cleanup old backups..."
cd "$BACKUP_DIR"
ls -t n8n_backup_*.zip | tail -n +31 | xargs -r rm -f

# Create backup report
BACKUP_COUNT=$(ls -1 n8n_backup_*.zip 2>/dev/null | wc -l)
TOTAL_SIZE=$(du -sh . | awk '{print $1}')

cat > "$BACKUP_DIR/latest_backup_report.txt" << EOL
N8N Enhanced Backup Report
==========================
Date: $(date +'%Y-%m-%d %H:%M:%S')
Backup Name: $BACKUP_NAME.zip
Backup Size: $BACKUP_SIZE
Multi-Domain: $MULTI_DOMAIN
Instance Count: $INSTANCE_COUNT
PostgreSQL: $(docker ps | grep -q "postgres-n8n" && echo "Enabled" || echo "Disabled")

Domains:
$(if [[ "$MULTI_DOMAIN" == "true" ]]; then
    for i in $(seq 1 $INSTANCE_COUNT); do
        DOMAIN=$(grep -E "^[a-zA-Z0-9.-]+.*reverse_proxy.*n8n_$i" /home/n8n/Caddyfile | awk '{print $1}' || echo 'unknown')
        echo "  Instance $i: $DOMAIN"
    done
else
    DOMAIN=$(grep -E "^[a-zA-Z0-9.-]+.*reverse_proxy.*n8n:" /home/n8n/Caddyfile | awk '{print $1}' || echo 'unknown')
    echo "  Single Domain: $DOMAIN"
fi)

Backup Statistics:
  Total Backups: $BACKUP_COUNT
  Total Size: $TOTAL_SIZE
  Location: $BACKUP_DIR

Status: ✅ SUCCESS
EOL

# Send to Telegram if configured
if [[ -f "/home/n8n/telegram_config.txt" ]]; then
    source "/home/n8n/telegram_config.txt"
    
    if [[ -n "$TELEGRAM_BOT_TOKEN" && -n "$TELEGRAM_CHAT_ID" ]]; then
        log "📱 Gửi thông báo Telegram..."
        
        MESSAGE="🔄 *N8N Enhanced Backup Completed*

📅 Date: $(date +'%Y-%m-%d %H:%M:%S')
📦 File: \`$BACKUP_NAME.zip\`
💾 Size: $BACKUP_SIZE
🌐 Mode: $([ "$MULTI_DOMAIN" == "true" ] && echo "Multi-Domain ($INSTANCE_COUNT instances)" || echo "Single Domain")
🐘 PostgreSQL: $(docker ps | grep -q "postgres-n8n" && echo "✅ Enabled" || echo "❌ Disabled")
📊 Status: ✅ Success

🗂️ Backup Details:
$(if [[ "$MULTI_DOMAIN" == "true" ]]; then
    for i in $(seq 1 $INSTANCE_COUNT); do
        DOMAIN=$(grep -E "^[a-zA-Z0-9.-]+.*reverse_proxy.*n8n_$i" /home/n8n/Caddyfile | awk '{print $1}' || echo 'unknown')
        echo "• Instance $i: $DOMAIN"
    done
else
    DOMAIN=$(grep -E "^[a-zA-Z0-9.-]+.*reverse_proxy.*n8n:" /home/n8n/Caddyfile | awk '{print $1}' || echo 'unknown')
    echo "• Domain: $DOMAIN"
fi)

📍 Location: \`$BACKUP_DIR\`
📈 Total Backups: $BACKUP_COUNT"

        # Send message
        curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
            -d chat_id="$TELEGRAM_CHAT_ID" \
            -d text="$MESSAGE" \
            -d parse_mode="Markdown" > /dev/null || true
        
        # Send file if smaller than 50MB
        BACKUP_SIZE_BYTES=$(stat -c%s "$BACKUP_DIR/$BACKUP_NAME.zip")
        if [[ $BACKUP_SIZE_BYTES -lt 52428800 ]]; then
            curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendDocument" \
                -F chat_id="$TELEGRAM_CHAT_ID" \
                -F document="@$BACKUP_DIR/$BACKUP_NAME.zip" \
                -F caption="📦 N8N Enhanced Backup: $BACKUP_NAME.zip" > /dev/null || true
        fi
        
        # Upload to Google Drive if available
        if [[ -f "/home/n8n/google_drive/gdrive_backup.py" && -f "/home/n8n/google_drive/credentials.json" ]]; then
            log "☁️ Upload to Google Drive..."
            python3 /home/n8n/google_drive/gdrive_backup.py upload "$BACKUP_DIR/$BACKUP_NAME.zip" "All-Domains" || true
        fi
    fi
fi

log "🎉 Enhanced backup process completed successfully!"
EOF

    chmod +x "$INSTALL_DIR/backup-workflows-enhanced.sh"
    
    # Manual backup test script
    cat > "$INSTALL_DIR/backup-manual.sh" << 'EOF'
#!/bin/bash

echo "🧪 ENHANCED MANUAL BACKUP TEST"
echo "=============================="
echo ""

cd /home/n8n

echo "📋 Thông tin hệ thống:"
echo "• Thời gian: $(date)"
echo "• Disk usage: $(df -h /home/n8n | tail -1 | awk '{print $5}')"
echo "• Memory: $(free -h | grep Mem | awk '{print $3"/"$2}')"
echo "• Docker containers: $(docker ps --filter "name=n8n" --format "{{.Names}}" | wc -l)"
echo ""

echo "🔄 Chạy enhanced backup test..."
./backup-workflows-enhanced.sh

echo ""
echo "📊 Kết quả backup:"
ls -lah /home/n8n/files/backup_full/n8n_backup_*.zip | tail -5

echo ""
echo "📄 Backup report:"
cat /home/n8n/files/backup_full/latest_backup_report.txt

echo ""
echo "✅ Enhanced manual backup test completed!"
EOF

    chmod +x "$INSTALL_DIR/backup-manual.sh"
    
    success "Đã tạo hệ thống backup enhanced"
}

create_restore_script() {
    log "🔄 Tạo restore script..."
    
    cat > "$INSTALL_DIR/restore-from-backup.sh" << 'EOF'
#!/bin/bash

# =============================================================================
# N8N ENHANCED RESTORE SCRIPT - Multi-Domain Support
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Check arguments
if [[ $# -lt 1 ]]; then
    echo "Sử dụng: $0 <backup_file.zip> [domain_filter]"
    echo ""
    echo "Ví dụ:"
    echo "  $0 /path/to/n8n_backup_20250628_140000.zip"
    echo "  $0 /path/to/backup.zip domain.com"
    echo ""
    exit 1
fi

BACKUP_FILE="$1"
DOMAIN_FILTER="${2:-}"

# Check if backup file exists
if [[ ! -f "$BACKUP_FILE" ]]; then
    error "Backup file không tồn tại: $BACKUP_FILE"
    exit 1
fi

# Check Docker Compose command
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    error "Docker Compose không tìm thấy!"
    exit 1
fi

log "🔄 Bắt đầu restore từ backup: $(basename $BACKUP_FILE)"

# Create temp directory
TEMP_DIR="/tmp/n8n_restore_$(date +%s)"
mkdir -p "$TEMP_DIR"

# Extract backup
log "📦 Giải nén backup file..."
cd "$TEMP_DIR"
unzip -q "$BACKUP_FILE"

# Find backup directory
BACKUP_DIR=$(find . -name "n8n_backup_*" -type d | head -1)
if [[ -z "$BACKUP_DIR" ]]; then
    error "Không tìm thấy backup data trong file"
    rm -rf "$TEMP_DIR"
    exit 1
fi

cd "$BACKUP_DIR"

# Read backup metadata
if [[ -f "backup_metadata.json" ]]; then
    log "📊 Đọc backup metadata..."
    BACKUP_TYPE=$(python3 -c "import json; print(json.load(open('backup_metadata.json'))['backup_type'])" 2>/dev/null || echo "unknown")
    MULTI_DOMAIN=$(python3 -c "import json; print(json.load(open('backup_metadata.json'))['multi_domain'])" 2>/dev/null || echo "false")
    INSTANCE_COUNT=$(python3 -c "import json; print(json.load(open('backup_metadata.json'))['instance_count'])" 2>/dev/null || echo "1")
    
    info "Backup Type: $BACKUP_TYPE"
    info "Multi-Domain: $MULTI_DOMAIN"
    info "Instance Count: $INSTANCE_COUNT"
else
    warning "Không tìm thấy metadata, sử dụng restore mode cơ bản"
    MULTI_DOMAIN="false"
    INSTANCE_COUNT="1"
fi

# Confirm restore
echo ""
warning "⚠️  CẢNH BÁO: Restore sẽ ghi đè dữ liệu hiện tại!"
if [[ -n "$DOMAIN_FILTER" ]]; then
    info "Chỉ restore cho domain: $DOMAIN_FILTER"
fi
read -p "Bạn có chắc chắn muốn tiếp tục? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log "Hủy restore"
    rm -rf "$TEMP_DIR"
    exit 0
fi

# Stop services
log "🛑 Dừng N8N services..."
cd /home/n8n
$DOCKER_COMPOSE down

# Restore configuration files
if [[ -d "config" ]]; then
    log "🔧 Restore configuration files..."
    
    if [[ -f "config/docker-compose.yml" ]]; then
        cp "config/docker-compose.yml" /home/n8n/
    fi
    
    if [[ -f "config/Caddyfile" ]]; then
        cp "config/Caddyfile" /home/n8n/
    fi
    
    if [[ -f "config/telegram_config.txt" ]]; then
        cp "config/telegram_config.txt" /home/n8n/
    fi
fi

# Restore SSL certificates
if [[ -d "ssl" && -f "ssl/caddy_data.tar.gz" ]]; then
    log "🔒 Restore SSL certificates..."
    docker volume create n8n_caddy_data 2>/dev/null || true
    docker run --rm -v n8n_caddy_data:/data -v "$(pwd)/ssl":/backup alpine tar xzf /backup/caddy_data.tar.gz -C /data
fi

# Restore PostgreSQL databases
if [[ -d "postgres" && "$MULTI_DOMAIN" == "true" ]]; then
    log "🐘 Restore PostgreSQL databases..."
    
    # Start PostgreSQL first
    $DOCKER_COMPOSE up -d postgres
    sleep 10
    
    # Restore each instance database
    for sql_file in postgres/dump_instance_*.sql; do
        if [[ -f "$sql_file" ]]; then
            INSTANCE_NUM=$(echo "$sql_file" | grep -o '[0-9]\+')
            DB_NAME="n8n_db_instance_$INSTANCE_NUM"
            
            log "Restore database: $DB_NAME"
            docker exec -i postgres-n8n psql -U n8n_user -d $DB_NAME < "$sql_file" || true
        fi
    done
    
    # Restore main database
    if [[ -f "postgres/dump_main.sql" ]]; then
        log "Restore main database"
        docker exec -i postgres-n8n psql -U n8n_user -d n8n_db < "postgres/dump_main.sql" || true
    fi
fi

# Restore N8N instances
if [[ -d "instances" ]]; then
    log "📋 Restore N8N instances..."
    
    for instance_dir in instances/instance_*; do
        if [[ -d "$instance_dir" ]]; then
            INSTANCE_NUM=$(echo "$instance_dir" | grep -o '[0-9]\+')
            
            # Check domain filter
            if [[ -n "$DOMAIN_FILTER" && -f "$instance_dir/metadata.json" ]]; then
                INSTANCE_DOMAIN=$(python3 -c "import json; print(json.load(open('$instance_dir/metadata.json'))['domain'])" 2>/dev/null || echo "unknown")
                if [[ "$INSTANCE_DOMAIN" != "$DOMAIN_FILTER" ]]; then
                    info "Bỏ qua instance $INSTANCE_NUM (domain: $INSTANCE_DOMAIN)"
                    continue
                fi
            fi
            
            log "Restore instance $INSTANCE_NUM..."
            
            if [[ "$MULTI_DOMAIN" == "true" ]]; then
                TARGET_DIR="/home/n8n/files/n8n_instance_$INSTANCE_NUM"
            else
                TARGET_DIR="/home/n8n/files"
            fi
            
            mkdir -p "$TARGET_DIR"
            cp -r "$instance_dir"/* "$TARGET_DIR/" 2>/dev/null || true
            
            # Import workflows and credentials if available
            if [[ -f "$instance_dir/workflows.json" ]]; then
                log "Import workflows cho instance $INSTANCE_NUM"
                # Will be imported after containers start
            fi
            
            if [[ -f "$instance_dir/credentials.json" ]]; then
                log "Import credentials cho instance $INSTANCE_NUM"
                # Will be imported after containers start
            fi
        fi
    done
fi

# Start services
log "🚀 Khởi động N8N services..."
$DOCKER_COMPOSE up -d

# Wait for services to be ready
log "⏳ Đợi services khởi động..."
sleep 30

# Import workflows and credentials
if [[ -d "instances" ]]; then
    log "📥 Import workflows và credentials..."
    
    for instance_dir in instances/instance_*; do
        if [[ -d "$instance_dir" ]]; then
            INSTANCE_NUM=$(echo "$instance_dir" | grep -o '[0-9]\+')
            
            # Check domain filter
            if [[ -n "$DOMAIN_FILTER" && -f "$instance_dir/metadata.json" ]]; then
                INSTANCE_DOMAIN=$(python3 -c "import json; print(json.load(open('$instance_dir/metadata.json'))['domain'])" 2>/dev/null || echo "unknown")
                if [[ "$INSTANCE_DOMAIN" != "$DOMAIN_FILTER" ]]; then
                    continue
                fi
            fi
            
            if [[ "$MULTI_DOMAIN" == "true" ]]; then
                CONTAINER_NAME="n8n-container-$INSTANCE_NUM"
            else
                CONTAINER_NAME="n8n-container"
            fi
            
            # Import workflows
            if [[ -f "$instance_dir/workflows.json" ]]; then
                log "Import workflows vào $CONTAINER_NAME..."
                docker cp "$instance_dir/workflows.json" $CONTAINER_NAME:/tmp/
                docker exec $CONTAINER_NAME n8n import:workflow --input=/tmp/workflows.json 2>/dev/null || true
            fi
            
            # Import credentials
            if [[ -f "$instance_dir/credentials.json" ]]; then
                log "Import credentials vào $CONTAINER_NAME..."
                docker cp "$instance_dir/credentials.json" $CONTAINER_NAME:/tmp/
                docker exec $CONTAINER_NAME n8n import:credentials --input=/tmp/credentials.json 2>/dev/null || true
            fi
        fi
    done
fi

# Cleanup
rm -rf "$TEMP_DIR"

# Verify services
log "🔍 Kiểm tra services..."
sleep 10

if [[ "$MULTI_DOMAIN" == "true" ]]; then
    for i in $(seq 1 $INSTANCE_COUNT); do
        CONTAINER_NAME="n8n-container-$i"
        if docker ps | grep -q "$CONTAINER_NAME"; then
            log "✅ $CONTAINER_NAME đang chạy"
        else
            warning "❌ $CONTAINER_NAME không chạy"
        fi
    done
else
    if docker ps | grep -q "n8n-container"; then
        log "✅ N8N container đang chạy"
    else
        warning "❌ N8N container không chạy"
    fi
fi

if docker ps | grep -q "caddy-proxy"; then
    log "✅ Caddy proxy đang chạy"
else
    warning "❌ Caddy proxy không chạy"
fi

log "🎉 Restore completed successfully!"
echo ""
echo "📋 Thông tin sau restore:"
echo "• Backup file: $(basename $BACKUP_FILE)"
echo "• Restore time: $(date)"
if [[ -n "$DOMAIN_FILTER" ]]; then
    echo "• Domain filter: $DOMAIN_FILTER"
fi
echo "• Multi-domain: $MULTI_DOMAIN"
echo "• Instance count: $INSTANCE_COUNT"
echo ""
echo "🌐 Truy cập N8N:"
if [[ "$MULTI_DOMAIN" == "true" ]]; then
    for i in $(seq 1 $INSTANCE_COUNT); do
        DOMAIN=$(grep -E "^[a-zA-Z0-9.-]+.*reverse_proxy.*n8n_$i" /home/n8n/Caddyfile | awk '{print $1}' || echo 'unknown')
        echo "• Instance $i: https://$DOMAIN"
    done
else
    DOMAIN=$(grep -E "^[a-zA-Z0-9.-]+.*reverse_proxy.*n8n:" /home/n8n/Caddyfile | awk '{print $1}' || echo 'unknown')
    echo "• N8N: https://$DOMAIN"
fi
EOF

    chmod +x "$INSTALL_DIR/restore-from-backup.sh"
    
    success "Đã tạo restore script"
}

# =============================================================================
# GOOGLE DRIVE INTEGRATION
# =============================================================================

create_google_drive_integration() {
    if [[ "$ENABLE_GOOGLE_DRIVE" != "true" ]]; then
        return 0
    fi
    
    log "☁️ Tạo Google Drive integration..."
    
    # Install Google API dependencies
    pip3 install google-api-python-client google-auth google-auth-oauthlib google-auth-httplib2 || true
    
    # Create Google Drive backup script
    cat > "$INSTALL_DIR/google_drive/gdrive_backup.py" << 'EOF'
#!/usr/bin/env python3

import os
import sys
import json
import argparse
from datetime import datetime
from pathlib import Path

try:
    from google.oauth2.service_account import Credentials
    from googleapiclient.discovery import build
    from googleapiclient.http import MediaFileUpload
    from googleapiclient.errors import HttpError
except ImportError:
    print("❌ Google API libraries not installed. Run: pip3 install google-api-python-client google-auth")
    sys.exit(1)

class GoogleDriveBackup:
    def __init__(self, credentials_file):
        self.credentials_file = credentials_file
        self.service = None
        self.root_folder_id = None
        self.connect()
    
    def connect(self):
        """Connect to Google Drive API"""
        try:
            credentials = Credentials.from_service_account_file(
                self.credentials_file,
                scopes=['https://www.googleapis.com/auth/drive']
            )
            self.service = build('drive', 'v3', credentials=credentials)
            print("✅ Connected to Google Drive API")
        except Exception as e:
            print(f"❌ Failed to connect to Google Drive: {e}")
            sys.exit(1)
    
    def find_or_create_folder(self, name, parent_id=None):
        """Find or create a folder"""
        try:
            # Search for existing folder
            query = f"name='{name}' and mimeType='application/vnd.google-apps.folder'"
            if parent_id:
                query += f" and '{parent_id}' in parents"
            
            results = self.service.files().list(q=query).execute()
            items = results.get('files', [])
            
            if items:
                return items[0]['id']
            
            # Create new folder
            folder_metadata = {
                'name': name,
                'mimeType': 'application/vnd.google-apps.folder'
            }
            if parent_id:
                folder_metadata['parents'] = [parent_id]
            
            folder = self.service.files().create(body=folder_metadata).execute()
            print(f"📁 Created folder: {name}")
            return folder.get('id')
            
        except HttpError as e:
            print(f"❌ Error creating folder {name}: {e}")
            return None
    
    def get_folder_structure(self, domain):
        """Get or create folder structure: N8N-Backups/YYYY/MM-Month/Domain/"""
        now = datetime.now()
        year = now.strftime("%Y")
        month = now.strftime("%m-%B")
        
        # Find or create root folder
        if not self.root_folder_id:
            self.root_folder_id = self.find_or_create_folder("N8N-Backups")
        
        # Create year folder
        year_folder_id = self.find_or_create_folder(year, self.root_folder_id)
        
        # Create month folder
        month_folder_id = self.find_or_create_folder(month, year_folder_id)
        
        # Create domain folder
        domain_folder_id = self.find_or_create_folder(domain, month_folder_id)
        
        return domain_folder_id
    
    def upload_file(self, file_path, domain):
        """Upload backup file to Google Drive"""
        try:
            folder_id = self.get_folder_structure(domain)
            if not folder_id:
                print("❌ Failed to create folder structure")
                return False
            
            file_name = os.path.basename(file_path)
            file_metadata = {
                'name': file_name,
                'parents': [folder_id]
            }
            
            media = MediaFileUpload(file_path, resumable=True)
            
            print(f"☁️ Uploading {file_name} to Google Drive...")
            file = self.service.files().create(
                body=file_metadata,
                media_body=media,
                fields='id'
            ).execute()
            
            print(f"✅ Upload completed. File ID: {file.get('id')}")
            return True
            
        except HttpError as e:
            print(f"❌ Upload failed: {e}")
            return False
    
    def list_backups(self, domain=None):
        """List backup files"""
        try:
            if domain and domain != "all":
                # List backups for specific domain
                query = f"name contains 'n8n_backup_' and mimeType!='application/vnd.google-apps.folder'"
                # Add domain-specific search if needed
            else:
                # List all backups
                query = f"name contains 'n8n_backup_' and mimeType!='application/vnd.google-apps.folder'"
            
            results = self.service.files().list(
                q=query,
                orderBy='createdTime desc',
                fields='files(id, name, size, createdTime, parents)'
            ).execute()
            
            items = results.get('files', [])
            
            if not items:
                print("📁 No backup files found")
                return
            
            print(f"📋 Found {len(items)} backup files:")
            for item in items:
                size_mb = int(item.get('size', 0)) / (1024 * 1024)
                created = item.get('createdTime', 'Unknown')
                print(f"  • {item['name']} ({size_mb:.1f} MB) - {created}")
                print(f"    ID: {item['id']}")
            
        except HttpError as e:
            print(f"❌ Failed to list backups: {e}")
    
    def download_file(self, file_id, output_path):
        """Download backup file from Google Drive"""
        try:
            print(f"📥 Downloading file ID: {file_id}")
            
            request = self.service.files().get_media(fileId=file_id)
            
            with open(output_path, 'wb') as f:
                downloader = MediaIoBaseDownload(f, request)
                done = False
                while done is False:
                    status, done = downloader.next_chunk()
                    print(f"Download progress: {int(status.progress() * 100)}%")
            
            print(f"✅ Download completed: {output_path}")
            return True
            
        except HttpError as e:
            print(f"❌ Download failed: {e}")
            return False

def main():
    parser = argparse.ArgumentParser(description='Google Drive N8N Backup Manager')
    parser.add_argument('action', choices=['upload', 'list', 'download'], help='Action to perform')
    parser.add_argument('file_or_id', nargs='?', help='File path (for upload) or File ID (for download)')
    parser.add_argument('domain_or_output', nargs='?', help='Domain name (for upload) or Output path (for download)')
    
    args = parser.parse_args()
    
    # Check credentials file
    credentials_file = '/home/n8n/google_drive/credentials.json'
    if not os.path.exists(credentials_file):
        print(f"❌ Credentials file not found: {credentials_file}")
        print("Please upload your Google Service Account JSON file to this location.")
        sys.exit(1)
    
    # Initialize Google Drive backup
    gdrive = GoogleDriveBackup(credentials_file)
    
    if args.action == 'upload':
        if not args.file_or_id or not args.domain_or_output:
            print("Usage: python3 gdrive_backup.py upload <file_path> <domain>")
            sys.exit(1)
        
        if not os.path.exists(args.file_or_id):
            print(f"❌ File not found: {args.file_or_id}")
            sys.exit(1)
        
        success = gdrive.upload_file(args.file_or_id, args.domain_or_output)
        sys.exit(0 if success else 1)
    
    elif args.action == 'list':
        domain = args.file_or_id or "all"
        gdrive.list_backups(domain)
    
    elif args.action == 'download':
        if not args.file_or_id or not args.domain_or_output:
            print("Usage: python3 gdrive_backup.py download <file_id> <output_path>")
            sys.exit(1)
        
        success = gdrive.download_file(args.file_or_id, args.domain_or_output)
        sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
EOF
    
    chmod +x "$INSTALL_DIR/google_drive/gdrive_backup.py"
    
    # Create cleanup script
    cat > "$INSTALL_DIR/google_drive/cleanup_old_backups.py" << 'EOF'
#!/usr/bin/env python3

import os
import sys
import argparse
from datetime import datetime, timedelta

try:
    from google.oauth2.service_account import Credentials
    from googleapiclient.discovery import build
    from googleapiclient.errors import HttpError
except ImportError:
    print("❌ Google API libraries not installed")
    sys.exit(1)

def cleanup_old_backups(credentials_file, days=90):
    """Delete backup files older than specified days"""
    try:
        credentials = Credentials.from_service_account_file(
            credentials_file,
            scopes=['https://www.googleapis.com/auth/drive']
        )
        service = build('drive', 'v3', credentials=credentials)
        
        # Calculate cutoff date
        cutoff_date = datetime.now() - timedelta(days=days)
        cutoff_str = cutoff_date.isoformat() + 'Z'
        
        # Find old backup files
        query = f"name contains 'n8n_backup_' and createdTime < '{cutoff_str}'"
        
        results = service.files().list(
            q=query,
            fields='files(id, name, createdTime)'
        ).execute()
        
        items = results.get('files', [])
        
        if not items:
            print(f"📁 No backup files older than {days} days found")
            return
        
        print(f"🗑️ Found {len(items)} backup files older than {days} days:")
        
        for item in items:
            print(f"  • Deleting: {item['name']} ({item['createdTime']})")
            service.files().delete(fileId=item['id']).execute()
        
        print(f"✅ Cleanup completed. Deleted {len(items)} files.")
        
    except HttpError as e:
        print(f"❌ Cleanup failed: {e}")

def main():
    parser = argparse.ArgumentParser(description='Cleanup old N8N backups from Google Drive')
    parser.add_argument('--days', type=int, default=90, help='Delete files older than this many days (default: 90)')
    
    args = parser.parse_args()
    
    credentials_file = '/home/n8n/google_drive/credentials.json'
    if not os.path.exists(credentials_file):
        print(f"❌ Credentials file not found: {credentials_file}")
        sys.exit(1)
    
    cleanup_old_backups(credentials_file, args.days)

if __name__ == '__main__':
    main()
EOF
    
    chmod +x "$INSTALL_DIR/google_drive/cleanup_old_backups.py"
    
    # Create placeholder for credentials
    cat > "$INSTALL_DIR/google_drive/README.md" << 'EOF'
# Google Drive Backup Setup

## 1. Upload Credentials File

Upload your Google Service Account JSON file to:
```
/home/n8n/google_drive/credentials.json
```

## 2. Usage

### Upload backup
```bash
python3 /home/n8n/google_drive/gdrive_backup.py upload /path/to/backup.zip domain.com
```

### List backups
```bash
python3 /home/n8n/google_drive/gdrive_backup.py list all
python3 /home/n8n/google_drive/gdrive_backup.py list domain.com
```

### Download backup
```bash
python3 /home/n8n/google_drive/gdrive_backup.py download FILE_ID /path/to/output.zip
```

### Cleanup old backups
```bash
python3 /home/n8n/google_drive/cleanup_old_backups.py --days 90
```
EOF
    
    success "Đã tạo Google Drive integration"
}

# =============================================================================
# TELEGRAM BOT MANAGEMENT
# =============================================================================

create_telegram_bot() {
    if [[ "$ENABLE_TELEGRAM_BOT" != "true" ]]; then
        return 0
    fi
    
    log "🤖 Tạo Telegram Bot Management..."
    
    # Create Telegram bot script
    cat > "$INSTALL_DIR/telegram_bot/bot.py" << 'EOF'
#!/usr/bin/env python3

import os
import sys
import json
import subprocess
import time
from datetime import datetime
import logging

try:
    import requests
except ImportError:
    print("❌ requests library not installed. Run: pip3 install requests")
    sys.exit(1)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/home/n8n/logs/telegram_bot.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class N8NTelegramBot:
    def __init__(self, token, chat_id):
        self.token = token
        self.chat_id = chat_id
        self.base_url = f"https://api.telegram.org/bot{token}"
        self.last_update_id = 0
        
    def send_message(self, text, parse_mode="Markdown"):
        """Send message to Telegram"""
        try:
            url = f"{self.base_url}/sendMessage"
            data = {
                'chat_id': self.chat_id,
                'text': text,
                'parse_mode': parse_mode
            }
            response = requests.post(url, data=data, timeout=10)
            return response.json()
        except Exception as e:
            logger.error(f"Failed to send message: {e}")
            return None
    
    def get_updates(self):
        """Get updates from Telegram"""
        try:
            url = f"{self.base_url}/getUpdates"
            params = {'offset': self.last_update_id + 1, 'timeout': 10}
            response = requests.get(url, params=params, timeout=15)
            return response.json()
        except Exception as e:
            logger.error(f"Failed to get updates: {e}")
            return None
    
    def run_command(self, command):
        """Run shell command and return output"""
        try:
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=60,
                cwd='/home/n8n'
            )
            return result.stdout + result.stderr
        except subprocess.TimeoutExpired:
            return "❌ Command timeout (60s)"
        except Exception as e:
            return f"❌ Command failed: {e}"
    
    def get_system_status(self):
        """Get system status"""
        try:
            # System info
            uptime = self.run_command("uptime -p").strip()
            memory = self.run_command("free -h | grep Mem | awk '{print $3\"/\"$2}'").strip()
            disk = self.run_command("df -h /home/n8n | tail -1 | awk '{print $5}'").strip()
            
            # Container status
            containers = self.run_command("docker ps --format 'table {{.Names}}\t{{.Status}}' | grep -E '(n8n|caddy|postgres|news-api)'")
            
            # Domain info
            domains = []
            if os.path.exists('/home/n8n/Caddyfile'):
                caddyfile = open('/home/n8n/Caddyfile').read()
                for line in caddyfile.split('\n'):
                    if '{' in line and 'reverse_proxy' not in line:
                        domain = line.split()[0]
                        if '.' in domain:
                            domains.append(domain)
            
            message = f"""🚀 *N8N System Status*

📊 *System Info:*
• Uptime: {uptime}
• Memory: {memory}
• Disk Usage: {disk}

🌐 *Domains ({len(domains)}):*
{chr(10).join([f"• {domain}" for domain in domains[:10]])}

🐳 *Containers:*
```
{containers}
```"""
            
            return message
            
        except Exception as e:
            return f"❌ Failed to get system status: {e}"
    
    def get_performance_metrics(self):
        """Get performance metrics"""
        try:
            # CPU and memory usage
            cpu = self.run_command("top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1").strip()
            load = self.run_command("uptime | awk -F'load average:' '{print $2}'").strip()
            
            # Docker stats
            docker_stats = self.run_command("docker stats --no-stream --format 'table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}'")
            
            # Network connections
            connections = self.run_command("netstat -an | grep ESTABLISHED | wc -l").strip()
            
            message = f"""📈 *Performance Metrics*
📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

🐳 *Container Resources:*
```
{docker_stats}
```

⚡ *System Load:* {load}
🌐 *Active Connections:* {connections}"""
            
            return message
            
        except Exception as e:
            return f"❌ Failed to get performance metrics: {e}"
    
    def get_health_check(self):
        """Get detailed health check"""
        try:
            # Container status
            containers = self.run_command("docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'")
            
            # SSL status
            ssl_status = []
            if os.path.exists('/home/n8n/Caddyfile'):
                caddyfile = open('/home/n8n/Caddyfile').read()
                for line in caddyfile.split('\n'):
                    if '{' in line and 'reverse_proxy' not in line:
                        domain = line.split()[0]
                        if '.' in domain:
                            ssl_check = self.run_command(f"curl -I https://{domain} 2>/dev/null | head -1")
                            status = "✅" if "200 OK" in ssl_check else "❌"
                            ssl_status.append(f"{status} {domain}")
            
            # Recent backups
            backups = self.run_command("ls -la /home/n8n/files/backup_full/n8n_backup_*.zip 2>/dev/null | tail -3")
            
            message = f"""🏥 *Health Check Report*
📅 Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

🐳 *Container Status:*
```
{containers}
```

🔒 *SSL Status:*
{chr(10).join(ssl_status[:10])}

💾 *Recent Backups:*
```
{backups}
```"""
            
            return message
            
        except Exception as e:
            return f"❌ Failed to get health check: {e}"
    
    def restart_service(self, service):
        """Restart specific service"""
        try:
            if service == "all":
                output = self.run_command("docker-compose restart")
                return f"🔄 *Restarting all services...*\n```\n{output}\n```"
            elif service in ["n8n", "caddy", "postgres", "fastapi", "telegram-bot"]:
                if service == "telegram-bot":
                    output = self.run_command("systemctl restart n8n-telegram-bot")
                else:
                    output = self.run_command(f"docker-compose restart {service}")
                return f"🔄 *Restarting {service}...*\n```\n{output}\n```"
            else:
                return f"❌ Unknown service: {service}\nAvailable: all, n8n, caddy, postgres, fastapi, telegram-bot"
        except Exception as e:
            return f"❌ Failed to restart {service}: {e}"
    
    def get_logs(self, service, lines=20):
        """Get logs for specific service"""
        try:
            if service == "all":
                output = self.run_command(f"docker-compose logs --tail={lines}")
            elif service in ["n8n", "caddy", "postgres", "fastapi"]:
                output = self.run_command(f"docker-compose logs --tail={lines} {service}")
            elif service == "telegram-bot":
                output = self.run_command(f"journalctl -u n8n-telegram-bot --no-pager -n {lines}")
            else:
                return f"❌ Unknown service: {service}\nAvailable: all, n8n, caddy, postgres, fastapi, telegram-bot"
            
            # Truncate if too long
            if len(output) > 3000:
                output = output[-3000:] + "\n... (truncated)"
            
            return f"📋 *Logs for {service}:*\n```\n{output}\n```"
        except Exception as e:
            return f"❌ Failed to get logs for {service}: {e}"
    
    def run_backup(self):
        """Run manual backup"""
        try:
            output = self.run_command("/home/n8n/backup-workflows-enhanced.sh")
            return f"💾 *Manual Backup Started*\n```\n{output}\n```"
        except Exception as e:
            return f"❌ Failed to run backup: {e}"
    
    def run_troubleshoot(self):
        """Run troubleshoot script"""
        try:
            output = self.run_command("/home/n8n/troubleshoot.sh")
            # Truncate if too long
            if len(output) > 3000:
                output = output[-3000:] + "\n... (truncated)"
            return f"🔧 *Troubleshoot Report*\n```\n{output}\n```"
        except Exception as e:
            return f"❌ Failed to run troubleshoot: {e}"
    
    def process_command(self, text):
        """Process incoming command"""
        text = text.strip().lower()
        
        if text == "/start":
            return """🤖 *N8N Telegram Bot Management*

📋 *Available Commands:*
• `/status` - System status overview
• `/health` - Detailed health check
• `/performance` - Performance metrics
• `/restart <service>` - Restart service
• `/logs <service> [lines]` - View logs
• `/backup` - Run manual backup
• `/troubleshoot` - Run diagnostic
• `/help` - Show this help

🛠️ *Services:* all, n8n, caddy, postgres, fastapi, telegram-bot

👨‍💻 *Created by Nguyễn Ngọc Thiện*"""
        
        elif text == "/help":
            return self.process_command("/start")
        
        elif text == "/status":
            return self.get_system_status()
        
        elif text == "/health":
            return self.get_health_check()
        
        elif text == "/performance":
            return self.get_performance_metrics()
        
        elif text.startswith("/restart"):
            parts = text.split()
            service = parts[1] if len(parts) > 1 else "all"
            return self.restart_service(service)
        
        elif text.startswith("/logs"):
            parts = text.split()
            service = parts[1] if len(parts) > 1 else "all"
            lines = int(parts[2]) if len(parts) > 2 and parts[2].isdigit() else 20
            lines = min(lines, 100)  # Limit to 100 lines
            return self.get_logs(service, lines)
        
        elif text == "/backup":
            return self.run_backup()
        
        elif text == "/troubleshoot":
            return self.run_troubleshoot()
        
        else:
            return f"❌ Unknown command: {text}\nUse /help for available commands"
    
    def run(self):
        """Main bot loop"""
        logger.info("🤖 N8N Telegram Bot started")
        self.send_message("🤖 *N8N Telegram Bot Started*\n\nUse /help for available commands")
        
        while True:
            try:
                updates = self.get_updates()
                if not updates or not updates.get('ok'):
                    time.sleep(5)
                    continue
                
                for update in updates.get('result', []):
                    self.last_update_id = update['update_id']
                    
                    if 'message' not in update:
                        continue
                    
                    message = update['message']
                    chat_id = message['chat']['id']
                    
                    # Check if message is from authorized chat
                    if str(chat_id) != str(self.chat_id):
                        logger.warning(f"Unauthorized access attempt from chat_id: {chat_id}")
                        continue
                    
                    if 'text' not in message:
                        continue
                    
                    text = message['text']
                    logger.info(f"Received command: {text}")
                    
                    # Process command
                    response = self.process_command(text)
                    
                    # Send response
                    self.send_message(response)
                
                time.sleep(1)
                
            except KeyboardInterrupt:
                logger.info("Bot stopped by user")
                break
            except Exception as e:
                logger.error(f"Bot error: {e}")
                time.sleep(10)

def main():
    # Load config
    config_file = '/home/n8n/telegram_config.txt'
    if not os.path.exists(config_file):
        print(f"❌ Config file not found: {config_file}")
        sys.exit(1)
    
    # Parse config
    config = {}
    with open(config_file) as f:
        for line in f:
            if '=' in line:
                key, value = line.strip().split('=', 1)
                config[key] = value.strip('"')
    
    token = config.get('TELEGRAM_BOT_TOKEN')
    chat_id = config.get('TELEGRAM_CHAT_ID')
    
    if not token or not chat_id:
        print("❌ Missing TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID in config")
        sys.exit(1)
    
    # Start bot
    bot = N8NTelegramBot(token, chat_id)
    bot.run()

if __name__ == '__main__':
    main()
EOF
    
    chmod +x "$INSTALL_DIR/telegram_bot/bot.py"
    
    # Create bot startup script
    cat > "$INSTALL_DIR/telegram_bot/start_bot.sh" << 'EOF'
#!/bin/bash

# Install required Python packages
pip3 install requests

# Start Telegram bot
cd /home/n8n
python3 /home/n8n/telegram_bot/bot.py
EOF
    
    chmod +x "$INSTALL_DIR/telegram_bot/start_bot.sh"
    
    success "Đã tạo Telegram Bot Management"
}

# =============================================================================
# WEB DASHBOARD
# =============================================================================

create_web_dashboard() {
    log "📊 Tạo Web Dashboard..."
    
    # Create dashboard HTML
    cat > "$INSTALL_DIR/dashboard/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>N8N Multi-Domain Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .header {
            text-align: center;
            color: white;
            margin-bottom: 30px;
        }
        
        .header h1 {
            font-size: 2.5rem;
            margin-bottom: 10px;
        }
        
        .header p {
            font-size: 1.1rem;
            opacity: 0.9;
        }
        
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            backdrop-filter: blur(10px);
        }
        
        .card h3 {
            color: #2c3e50;
            margin-bottom: 20px;
            font-size: 1.3rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .status-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px solid #ecf0f1;
        }
        
        .status-item:last-child {
            border-bottom: none;
        }
        
        .status-running {
            background: #27ae60;
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: bold;
        }
        
        .status-stopped {
            background: #e74c3c;
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: bold;
        }
        
        .status-warning {
            background: #f39c12;
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: bold;
        }
        
        .actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-top: 30px;
        }
        
        .btn {
            background: linear-gradient(135deg, #3498db, #2980b9);
            color: white;
            border: none;
            padding: 12px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 0.9rem;
            font-weight: bold;
            transition: all 0.3s ease;
            text-decoration: none;
            text-align: center;
            display: inline-block;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(52, 152, 219, 0.4);
        }
        
        .btn-success {
            background: linear-gradient(135deg, #27ae60, #229954);
        }
        
        .btn-warning {
            background: linear-gradient(135deg, #f39c12, #e67e22);
        }
        
        .btn-danger {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
        }
        
        .btn-info {
            background: linear-gradient(135deg, #17a2b8, #138496);
        }
        
        .last-updated {
            text-align: center;
            color: white;
            margin-top: 20px;
            opacity: 0.8;
        }
        
        .loading {
            text-align: center;
            color: #7f8c8d;
            font-style: italic;
        }
        
        .metric-value {
            font-size: 1.5rem;
            font-weight: bold;
            color: #2c3e50;
        }
        
        .metric-label {
            font-size: 0.9rem;
            color: #7f8c8d;
        }
        
        @media (max-width: 768px) {
            .dashboard-grid {
                grid-template-columns: 1fr;
            }
            
            .header h1 {
                font-size: 2rem;
            }
            
            .actions {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 N8N Multi-Domain Dashboard</h1>
            <p>Real-time monitoring and management</p>
        </div>
        
        <div class="dashboard-grid">
            <div class="card">
                <h3>📊 System Overview</h3>
                <div id="system-overview" class="loading">Loading...</div>
            </div>
            
            <div class="card">
                <h3>🐳 Container Status</h3>
                <div id="container-status" class="loading">Loading...</div>
            </div>
            
            <div class="card">
                <h3>🌐 N8N Instances</h3>
                <div id="n8n-instances" class="loading">Loading...</div>
            </div>
            
            <div class="card">
                <h3>🔒 SSL Certificates</h3>
                <div id="ssl-status" class="loading">Loading...</div>
            </div>
            
            <div class="card">
                <h3>💾 Backup Status</h3>
                <div id="backup-status" class="loading">Loading...</div>
            </div>
            
            <div class="card">
                <h3>📈 Performance Metrics</h3>
                <div id="performance-metrics" class="loading">Loading...</div>
            </div>
        </div>
        
        <div class="actions">
            <button class="btn" onclick="refreshData()">🔄 Refresh Data</button>
            <button class="btn btn-warning" onclick="restartAll()">🔄 Restart All</button>
            <button class="btn btn-success" onclick="runBackup()">💾 Manual Backup</button>
            <a href="/logs" class="btn btn-info" target="_blank">📋 View Logs</a>
            <button class="btn btn-warning" onclick="updateSystem()">⬆️ Update System</button>
            <a href="/troubleshoot" class="btn btn-danger" target="_blank">🔧 Troubleshoot</a>
        </div>
        
        <div class="last-updated">
            Last updated: <span id="last-updated">Never</span>
        </div>
    </div>

    <script>
        let autoRefreshInterval;
        
        async function fetchSystemData() {
            try {
                const response = await fetch('/api/system-status');
                const data = await response.json();
                updateDashboard(data);
                document.getElementById('last-updated').textContent = new Date().toLocaleString();
            } catch (error) {
                console.error('Failed to fetch system data:', error);
            }
        }
        
        function updateDashboard(data) {
            // System Overview
            document.getElementById('system-overview').innerHTML = `
                <div class="status-item">
                    <span>Uptime</span>
                    <span class="metric-value">${data.uptime || 'Unknown'}</span>
                </div>
                <div class="status-item">
                    <span>Memory Usage</span>
                    <span class="metric-value">${data.memory || 'Unknown'}</span>
                </div>
                <div class="status-item">
                    <span>Disk Usage</span>
                    <span class="metric-value">${data.disk || 'Unknown'}</span>
                </div>
                <div class="status-item">
                    <span>Load Average</span>
                    <span class="metric-value">${data.load || 'Unknown'}</span>
                </div>
            `;
            
            // Container Status
            let containerHtml = '';
            if (data.containers && data.containers.length > 0) {
                data.containers.forEach(container => {
                    const statusClass = container.state === 'running' ? 'status-running' : 'status-stopped';
                    containerHtml += `
                        <div class="status-item">
                            <span>${container.name}</span>
                            <span class="${statusClass}">${container.state}</span>
                        </div>
                    `;
                });
            } else {
                containerHtml = '<div class="loading">No container data</div>';
            }
            document.getElementById('container-status').innerHTML = containerHtml;
            
            // N8N Instances
            let instancesHtml = '';
            if (data.instances && data.instances.length > 0) {
                data.instances.forEach(instance => {
                    const statusClass = instance.status === 'healthy' ? 'status-running' : 'status-warning';
                    instancesHtml += `
                        <div class="status-item">
                            <span>${instance.domain}</span>
                            <span class="${statusClass}">${instance.status}</span>
                        </div>
                    `;
                });
            } else {
                instancesHtml = '<div class="loading">No instance data</div>';
            }
            document.getElementById('n8n-instances').innerHTML = instancesHtml;
            
            // SSL Status
            let sslHtml = '';
            if (data.ssl && data.ssl.length > 0) {
                data.ssl.forEach(ssl => {
                    const statusClass = ssl.valid ? 'status-running' : 'status-warning';
                    const statusText = ssl.valid ? 'Valid' : 'Invalid';
                    sslHtml += `
                        <div class="status-item">
                            <span>${ssl.domain}</span>
                            <span class="${statusClass}">${statusText}</span>
                        </div>
                    `;
                });
            } else {
                sslHtml = '<div class="loading">No SSL data</div>';
            }
            document.getElementById('ssl-status').innerHTML = sslHtml;
            
            // Backup Status
            document.getElementById('backup-status').innerHTML = `
                <div class="status-item">
                    <span>Backup Count</span>
                    <span class="metric-value">${data.backup?.count || '0'}</span>
                </div>
                <div class="status-item">
                    <span>Last Backup</span>
                    <span class="metric-label">${data.backup?.last || 'Never'}</span>
                </div>
                <div class="status-item">
                    <span>Total Size</span>
                    <span class="metric-value">${data.backup?.size || '0 MB'}</span>
                </div>
            `;
            
            // Performance Metrics
            document.getElementById('performance-metrics').innerHTML = `
                <div class="status-item">
                    <span>CPU Usage</span>
                    <span class="metric-value">${data.performance?.cpu || 'Unknown'}</span>
                </div>
                <div class="status-item">
                    <span>Network I/O</span>
                    <span class="metric-value">${data.performance?.network || 'Normal'}</span>
                </div>
                <div class="status-item">
                    <span>Active Connections</span>
                    <span class="metric-value">${data.performance?.connections || '0'}</span>
                </div>
            `;
        }
        
        async function refreshData() {
            await fetchSystemData();
        }
        
        async function restartAll() {
            if (confirm('Are you sure you want to restart all services?')) {
                try {
                    const response = await fetch('/api/restart-all', { method: 'POST' });
                    const result = await response.text();
                    alert('Restart initiated. Please wait a few minutes and refresh.');
                } catch (error) {
                    alert('Failed to restart services: ' + error.message);
                }
            }
        }
        
        async function runBackup() {
            if (confirm('Run manual backup now?')) {
                try {
                    const response = await fetch('/api/backup', { method: 'POST' });
                    const result = await response.text();
                    alert('Backup started. Check Telegram for status updates.');
                } catch (error) {
                    alert('Failed to start backup: ' + error.message);
                }
            }
        }
        
        async function updateSystem() {
            if (confirm('Update system now? This may take several minutes.')) {
                try {
                    const response = await fetch('/api/update', { method: 'POST' });
                    const result = await response.text();
                    alert('System update started. Please wait and refresh in a few minutes.');
                } catch (error) {
                    alert('Failed to start update: ' + error.message);
                }
            }
        }
        
        // Auto-refresh every 30 seconds
        function startAutoRefresh() {
            autoRefreshInterval = setInterval(fetchSystemData, 30000);
        }
        
        function stopAutoRefresh() {
            if (autoRefreshInterval) {
                clearInterval(autoRefreshInterval);
            }
        }
        
        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            if (e.key === 'r' || e.key === 'R') {
                e.preventDefault();
                refreshData();
            } else if (e.key === 'b' || e.key === 'B') {
                e.preventDefault();
                runBackup();
            } else if (e.key === 'l' || e.key === 'L') {
                e.preventDefault();
                window.open('/logs', '_blank');
            } else if (e.key === 't' || e.key === 'T') {
                e.preventDefault();
                window.open('/troubleshoot', '_blank');
            }
        });
        
        // Initialize
        fetchSystemData();
        startAutoRefresh();
        
        // Stop auto-refresh when page is hidden
        document.addEventListener('visibilitychange', function() {
            if (document.hidden) {
                stopAutoRefresh();
            } else {
                startAutoRefresh();
            }
        });
    </script>
</body>
</html>
EOF
    
    # Create dashboard server
    cat > "$INSTALL_DIR/dashboard/server.py" << 'EOF'
#!/usr/bin/env python3

import os
import json
import subprocess
import threading
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import time

class DashboardHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        
        if path == '/' or path == '/index.html':
            self.serve_file('/home/n8n/dashboard/index.html', 'text/html')
        elif path == '/api/system-status':
            self.serve_system_status()
        elif path == '/logs':
            self.serve_logs()
        elif path == '/troubleshoot':
            self.serve_troubleshoot()
        else:
            self.send_error(404)
    
    def do_POST(self):
        parsed_path = urlparse(self.path)
        path = parsed_path.path
        
        if path == '/api/restart-all':
            self.restart_all_services()
        elif path == '/api/backup':
            self.run_backup()
        elif path == '/api/update':
            self.update_system()
        else:
            self.send_error(404)
    
    def serve_file(self, file_path, content_type):
        try:
            with open(file_path, 'r') as f:
                content = f.read()
            
            self.send_response(200)
            self.send_header('Content-type', content_type)
            self.end_headers()
            self.wfile.write(content.encode())
        except FileNotFoundError:
            self.send_error(404)
    
    def run_command(self, command):
        try:
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=30,
                cwd='/home/n8n'
            )
            return result.stdout + result.stderr
        except:
            return "Command failed"
    
    def serve_system_status(self):
        try:
            # System info
            uptime = self.run_command("uptime -p").strip()
            memory = self.run_command("free -h | grep Mem | awk '{print $3\"/\"$2}'").strip()
            disk = self.run_command("df -h /home/n8n | tail -1 | awk '{print $5}'").strip()
            load = self.run_command("uptime | awk -F'load average:' '{print $2}'").strip()
            
            # Container status
            containers = []
            container_output = self.run_command("docker ps --format '{{.Names}}\t{{.State}}'")
            for line in container_output.split('\n'):
                if line.strip():
                    parts = line.split('\t')
                    if len(parts) >= 2:
                        containers.append({
                            'name': parts[0],
                            'state': 'running' if 'running' in parts[1].lower() else 'stopped'
                        })
            
            # N8N instances
            instances = []
            if os.path.exists('/home/n8n/Caddyfile'):
                with open('/home/n8n/Caddyfile') as f:
                    caddyfile = f.read()
                    for line in caddyfile.split('\n'):
                        if '{' in line and 'reverse_proxy' not in line:
                            domain = line.split()[0]
                            if '.' in domain:
                                # Simple health check
                                health = self.run_command(f"curl -I https://{domain} 2>/dev/null | head -1")
                                status = 'healthy' if '200 OK' in health else 'unhealthy'
                                instances.append({
                                    'domain': domain,
                                    'status': status
                                })
            
            # SSL status
            ssl_status = []
            for instance in instances:
                domain = instance['domain']
                ssl_check = self.run_command(f"curl -I https://{domain} 2>/dev/null | head -1")
                ssl_status.append({
                    'domain': domain,
                    'valid': '200 OK' in ssl_check
                })
            
            # Backup status
            backup_count = self.run_command("ls -1 /home/n8n/files/backup_full/n8n_backup_*.zip 2>/dev/null | wc -l").strip()
            backup_size = self.run_command("du -sh /home/n8n/files/backup_full 2>/dev/null | awk '{print $1}'").strip()
            latest_backup = self.run_command("ls -t /home/n8n/files/backup_full/n8n_backup_*.zip 2>/dev/null | head -1 | xargs basename 2>/dev/null").strip()
            
            # Performance metrics
            cpu = self.run_command("top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1").strip()
            connections = self.run_command("netstat -an | grep ESTABLISHED | wc -l").strip()
            
            data = {
                'uptime': uptime,
                'memory': memory,
                'disk': disk,
                'load': load,
                'containers': containers,
                'instances': instances,
                'ssl': ssl_status,
                'backup': {
                    'count': backup_count,
                    'size': backup_size,
                    'last': latest_backup
                },
                'performance': {
                    'cpu': f"{cpu}%" if cpu else "Unknown",
                    'network': "Normal",
                    'connections': connections
                }
            }
            
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps(data).encode())
            
        except Exception as e:
            self.send_error(500, str(e))
    
    def restart_all_services(self):
        try:
            def restart_async():
                self.run_command("docker-compose restart")
            
            thread = threading.Thread(target=restart_async)
            thread.start()
            
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'Restart initiated')
        except Exception as e:
            self.send_error(500, str(e))
    
    def run_backup(self):
        try:
            def backup_async():
                self.run_command("/home/n8n/backup-workflows-enhanced.sh")
            
            thread = threading.Thread(target=backup_async)
            thread.start()
            
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'Backup started')
        except Exception as e:
            self.send_error(500, str(e))
    
    def update_system(self):
        try:
            def update_async():
                if os.path.exists('/home/n8n/update-n8n.sh'):
                    self.run_command("/home/n8n/update-n8n.sh")
            
            thread = threading.Thread(target=update_async)
            thread.start()
            
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'Update started')
        except Exception as e:
            self.send_error(500, str(e))
    
    def serve_logs(self):
        try:
            logs = self.run_command("docker-compose logs --tail=100")
            
            html = f"""
            <!DOCTYPE html>
            <html>
            <head>
                <title>N8N Logs</title>
                <style>
                    body {{ font-family: monospace; background: #2c3e50; color: #ecf0f1; padding: 20px; }}
                    pre {{ white-space: pre-wrap; word-wrap: break-word; }}
                    .header {{ color: #3498db; margin-bottom: 20px; }}
                </style>
            </head>
            <body>
                <div class="header">
                    <h1>🔍 N8N System Logs</h1>
                    <p>Last 100 lines - Auto-refresh every 30 seconds</p>
                </div>
                <pre>{logs}</pre>
                <script>
                    setTimeout(() => location.reload(), 30000);
                </script>
            </body>
            </html>
            """
            
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(html.encode())
        except Exception as e:
            self.send_error(500, str(e))
    
    def serve_troubleshoot(self):
        try:
            troubleshoot = self.run_command("/home/n8n/troubleshoot.sh")
            
            html = f"""
            <!DOCTYPE html>
            <html>
            <head>
                <title>N8N Troubleshoot</title>
                <style>
                    body {{ font-family: monospace; background: #2c3e50; color: #ecf0f1; padding: 20px; }}
                    pre {{ white-space: pre-wrap; word-wrap: break-word; }}
                    .header {{ color: #e74c3c; margin-bottom: 20px; }}
                </style>
            </head>
            <body>
                <div class="header">
                    <h1>🔧 N8N Troubleshoot Report</h1>
                    <p>Generated: {time.strftime('%Y-%m-%d %H:%M:%S')}</p>
                </div>
                <pre>{troubleshoot}</pre>
            </body>
            </html>
            """
            
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(html.encode())
        except Exception as e:
            self.send_error(500, str(e))

def run_dashboard():
    server_address = ('0.0.0.0', 8080)
    httpd = HTTPServer(server_address, DashboardHandler)
    print(f"🌐 Dashboard server running on http://0.0.0.0:8080")
    httpd.serve_forever()

if __name__ == '__main__':
    run_dashboard()
EOF
    
    chmod +x "$INSTALL_DIR/dashboard/server.py"
    
    success "Đã tạo Web Dashboard"
}

# =============================================================================
# TROUBLESHOOTING SCRIPT
# =============================================================================

create_troubleshooting_script() {
    log "🔧 Tạo script chẩn đoán enhanced..."
    
    cat > "$INSTALL_DIR/troubleshoot.sh" << 'EOF'
#!/bin/bash

# =============================================================================
# N8N ENHANCED TROUBLESHOOTING SCRIPT - Multi-Domain Support
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${WHITE}                🔧 N8N ENHANCED TROUBLESHOOTING SCRIPT                       ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check Docker Compose command
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    echo -e "${RED}❌ Docker Compose không tìm thấy!${NC}"
    exit 1
fi

cd /home/n8n

echo -e "${BLUE}📍 1. System Information:${NC}"
echo "• OS: $(lsb_release -d | cut -f2 2>/dev/null || echo 'Unknown')"
echo "• Kernel: $(uname -r)"
echo "• Docker: $(docker --version 2>/dev/null || echo 'Not installed')"
echo "• Docker Compose: $($DOCKER_COMPOSE --version 2>/dev/null || echo 'Not installed')"
echo "• Disk Usage: $(df -h /home/n8n | tail -1 | awk '{print $5}' 2>/dev/null || echo 'Unknown')"
echo "• Memory: $(free -h | grep Mem | awk '{print $3"/"$2}' 2>/dev/null || echo 'Unknown')"
echo "• Uptime: $(uptime -p 2>/dev/null || echo 'Unknown')"
echo "• Swap: $(swapon --show | grep -v NAME | awk '{print $3}' | head -1 || echo 'None')"
echo ""

echo -e "${BLUE}📍 2. Multi-Domain Detection:${NC}"
MULTI_DOMAIN=false
INSTANCE_COUNT=0

if docker ps --filter "name=n8n-container-" --format "{{.Names}}" | grep -q "n8n-container-"; then
    MULTI_DOMAIN=true
    INSTANCE_COUNT=$(docker ps --filter "name=n8n-container-" --format "{{.Names}}" | wc -l)
    echo "• Mode: Multi-Domain"
    echo "• Instance Count: $INSTANCE_COUNT"
else
    echo "• Mode: Single Domain"
    INSTANCE_COUNT=1
fi

# PostgreSQL detection
if docker ps | grep -q "postgres-n8n"; then
    echo "• Database: PostgreSQL"
else
    echo "• Database: SQLite"
fi
echo ""

echo -e "${BLUE}📍 3. Container Status:${NC}"
$DOCKER_COMPOSE ps 2>/dev/null || echo "No containers found"
echo ""

echo -e "${BLUE}📍 4. Docker Images:${NC}"
docker images | grep -E "(n8n|caddy|news-api|postgres)" || echo "No relevant images found"
echo ""

echo -e "${BLUE}📍 5. Network Status:${NC}"
echo "• Port 80: $(netstat -tulpn 2>/dev/null | grep :80 | wc -l) connections"
echo "• Port 443: $(netstat -tulpn 2>/dev/null | grep :443 | wc -l) connections"
echo "• Port 8080: $(netstat -tulpn 2>/dev/null | grep :8080 | wc -l) connections (Dashboard)"
echo "• Docker Networks:"
docker network ls | grep n8n || echo "  No N8N networks found"
echo ""

echo -e "${BLUE}📍 6. Domain & SSL Status:${NC}"
if [[ -f "Caddyfile" ]]; then
    echo "• Domains configured:"
    grep -E "^[a-zA-Z0-9.-]+\s*{" Caddyfile | awk '{print "  - " $1}' || echo "  No domains found"
    
    echo "• SSL Certificate Status:"
    grep -E "^[a-zA-Z0-9.-]+\s*{" Caddyfile | awk '{print $1}' | while read domain; do
        if [[ -n "$domain" && "$domain" != "{" ]]; then
            SSL_STATUS=$(timeout 10 curl -I "https://$domain" 2>/dev/null | head -1 || echo "Connection failed")
            if echo "$SSL_STATUS" | grep -q "200 OK"; then
                echo "  ✅ $domain: SSL OK"
            else
                echo "  ❌ $domain: SSL Failed ($SSL_STATUS)"
            fi
        fi
    done
else
    echo "• No Caddyfile found"
fi
echo ""

echo -e "${BLUE}📍 7. Service Health Checks:${NC}"
if [[ "$MULTI_DOMAIN" == "true" ]]; then
    for i in $(seq 1 $INSTANCE_COUNT); do
        CONTAINER_NAME="n8n-container-$i"
        if docker ps | grep -q "$CONTAINER_NAME"; then
            echo "  ✅ $CONTAINER_NAME: Running"
            # Check if N8N is responding
            PORT=$((5677 + i))
            HEALTH=$(curl -s "http://localhost:$PORT/healthz" 2>/dev/null || echo "No response")
            echo "    Health: $HEALTH"
        else
            echo "  ❌ $CONTAINER_NAME: Not running"
        fi
    done
else
    if docker ps | grep -q "n8n-container"; then
        echo "  ✅ n8n-container: Running"
        HEALTH=$(curl -s "http://localhost:5678/healthz" 2>/dev/null || echo "No response")
        echo "    Health: $HEALTH"
    else
        echo "  ❌ n8n-container: Not running"
    fi
fi

# Check other services
if docker ps | grep -q "caddy-proxy"; then
    echo "  ✅ caddy-proxy: Running"
else
    echo "  ❌ caddy-proxy: Not running"
fi

if docker ps | grep -q "postgres-n8n"; then
    echo "  ✅ postgres-n8n: Running"
    # Check PostgreSQL connection
    PG_STATUS=$(docker exec postgres-n8n pg_isready -U n8n_user 2>/dev/null || echo "Connection failed")
    echo "    PostgreSQL: $PG_STATUS"
else
    echo "  ℹ️ postgres-n8n: Not configured"
fi

if docker ps | grep -q "news-api-container"; then
    echo "  ✅ news-api-container: Running"
    API_STATUS=$(curl -s "http://localhost:8000/health" 2>/dev/null | grep -o '"status":"[^"]*"' || echo "No response")
    echo "    API Health: $API_STATUS"
else
    echo "  ℹ️ news-api-container: Not configured"
fi
echo ""

echo -e "${BLUE}📍 8. Recent Logs (last 10 lines):${NC}"
echo -e "${YELLOW}N8N Logs:${NC}"
if [[ "$MULTI_DOMAIN" == "true" ]]; then
    for i in $(seq 1 $INSTANCE_COUNT); do
        echo "  Instance $i:"
        $DOCKER_COMPOSE logs --tail=5 "n8n_$i" 2>/dev/null | sed 's/^/    /' || echo "    No logs available"
    done
else
    $DOCKER_COMPOSE logs --tail=10 n8n 2>/dev/null || echo "No N8N logs"
fi

echo ""
echo -e "${YELLOW}Caddy Logs:${NC}"
$DOCKER_COMPOSE logs --tail=10 caddy 2>/dev/null || echo "No Caddy logs"

if docker ps | grep -q "news-api"; then
    echo ""
    echo -e "${YELLOW}News API Logs:${NC}"
    $DOCKER_COMPOSE logs --tail=10 fastapi 2>/dev/null || echo "No News API logs"
fi

if docker ps | grep -q "postgres-n8n"; then
    echo ""
    echo -e "${YELLOW}PostgreSQL Logs:${NC}"
    $DOCKER_COMPOSE logs --tail=10 postgres 2>/dev/null || echo "No PostgreSQL logs"
fi
echo ""

echo -e "${BLUE}📍 9. Backup Status:${NC}"
if [[ -d "/home/n8n/files/backup_full" ]]; then
    BACKUP_COUNT=$(ls -1 /home/n8n/files/backup_full/n8n_backup_*.zip 2>/dev/null | wc -l)
    echo "• Backup files: $BACKUP_COUNT"
    if [[ $BACKUP_COUNT -gt 0 ]]; then
        echo "• Latest backup: $(ls -t /home/n8n/files/backup_full/n8n_backup_*.zip 2>/dev/null | head -1 | xargs basename 2>/dev/null)"
        echo "• Latest backup size: $(ls -lh /home/n8n/files/backup_full/n8n_backup_*.zip 2>/dev/null | head -1 | awk '{print $5}')"
        echo "• Total backup size: $(du -sh /home/n8n/files/backup_full 2>/dev/null | awk '{print $1}')"
    fi
    
    # Check backup report
    if [[ -f "/home/n8n/files/backup_full/latest_backup_report.txt" ]]; then
        echo "• Latest backup report available"
    fi
else
    echo "• No backup directory found"
fi

# Check Google Drive integration
if [[ -f "/home/n8n/google_drive/credentials.json" ]]; then
    echo "• Google Drive: Configured"
else
    echo "• Google Drive: Not configured"
fi
echo ""

echo -e "${BLUE}📍 10. Cron Jobs & Services:${NC}"
echo "• Cron jobs:"
crontab -l 2>/dev/null | grep -E "(n8n|backup)" | sed 's/^/  /' || echo "  No N8N cron jobs found"

echo "• Systemd services:"
if systemctl is-active --quiet n8n-telegram-bot; then
    echo "  ✅ n8n-telegram-bot: Active"
else
    echo "  ❌ n8n-telegram-bot: Inactive"
fi

if systemctl is-active --quiet n8n-dashboard; then
    echo "  ✅ n8n-dashboard: Active"
else
    echo "  ❌ n8n-dashboard: Inactive"
fi
echo ""

echo -e "${BLUE}📍 11. Configuration Files:${NC}"
echo "• docker-compose.yml: $([ -f docker-compose.yml ] && echo "✅ Present" || echo "❌ Missing")"
echo "• Caddyfile: $([ -f Caddyfile ] && echo "✅ Present" || echo "❌ Missing")"
echo "• telegram_config.txt: $([ -f telegram_config.txt ] && echo "✅ Present" || echo "❌ Missing")"
echo "• Dockerfile: $([ -f Dockerfile ] && echo "✅ Present" || echo "❌ Missing")"

if [[ "$MULTI_DOMAIN" == "true" ]]; then
    echo "• init-multi-db.sh: $([ -f init-multi-db.sh ] && echo "✅ Present" || echo "❌ Missing")"
fi
echo ""

echo -e "${BLUE}📍 12. Resource Usage:${NC}"
echo "• Docker system usage:"
docker system df 2>/dev/null | sed 's/^/  /' || echo "  Unable to get Docker usage"

echo "• Top processes:"
ps aux --sort=-%cpu | head -6 | sed 's/^/  /' || echo "  Unable to get process list"
echo ""

echo -e "${GREEN}🔧 QUICK FIX COMMANDS:${NC}"
echo -e "${YELLOW}• Restart all services:${NC} cd /home/n8n && $DOCKER_COMPOSE restart"
echo -e "${YELLOW}• View live logs:${NC} cd /home/n8n && $DOCKER_COMPOSE logs -f"
echo -e "${YELLOW}• Rebuild containers:${NC} cd /home/n8n && $DOCKER_COMPOSE down && $DOCKER_COMPOSE up -d --build"
echo -e "${YELLOW}• Manual backup:${NC} /home/n8n/backup-manual.sh"
echo -e "${YELLOW}• Enhanced backup:${NC} /home/n8n/backup-workflows-enhanced.sh"
echo -e "${YELLOW}• Web dashboard:${NC} http://$(curl -s https://api.ipify.org):8080"

if [[ "$MULTI_DOMAIN" == "true" ]]; then
    echo -e "${YELLOW}• Check specific instance:${NC} docker logs n8n-container-1"
    echo -e "${YELLOW}• PostgreSQL shell:${NC} docker exec -it postgres-n8n psql -U n8n_user -d n8n_db"
fi

echo -e "${YELLOW}• Check SSL for domain:${NC} curl -I https://YOUR_DOMAIN"
echo ""

echo -e "${CYAN}✅ Enhanced troubleshooting completed!${NC}"
echo -e "${CYAN}📊 Dashboard: http://$(curl -s https://api.ipify.org 2>/dev/null):8080${NC}"
echo -e "${CYAN}📋 For detailed logs: /home/n8n/logs/${NC}"
EOF

    chmod +x "$INSTALL_DIR/troubleshoot.sh"
    
    success "Đã tạo script chẩn đoán enhanced"
}

# =============================================================================
# SYSTEMD SERVICES
# =============================================================================

create_systemd_services() {
    log "⚙️ Tạo systemd services..."
    
    # Telegram Bot service
    if [[ "$ENABLE_TELEGRAM_BOT" == "true" ]]; then
        cat > /etc/systemd/system/n8n-telegram-bot.service << 'EOF'
[Unit]
Description=N8N Telegram Bot Management
After=docker.service
Requires=docker.service

[Service]
Type=simple
User=root
WorkingDirectory=/home/n8n
ExecStart=/home/n8n/telegram_bot/start_bot.sh
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
        
        systemctl daemon-reload
        systemctl enable n8n-telegram-bot
        systemctl start n8n-telegram-bot
        
        success "Đã tạo Telegram Bot service"
    fi
    
    # Dashboard service
    cat > /etc/systemd/system/n8n-dashboard.service << 'EOF'
[Unit]
Description=N8N Web Dashboard
After=docker.service
Requires=docker.service

[Service]
Type=simple
User=root
WorkingDirectory=/home/n8n
ExecStart=/usr/bin/python3 /home/n8n/dashboard/server.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable n8n-dashboard
    systemctl start n8n-dashboard
    
    success "Đã tạo Dashboard service"
}

# =============================================================================
# TELEGRAM CONFIGURATION
# =============================================================================

setup_telegram_config() {
    if [[ "$ENABLE_TELEGRAM" != "true" && "$ENABLE_TELEGRAM_BOT" != "true" ]]; then
        return 0
    fi
    
    log "📱 Thiết lập cấu hình Telegram..."
    
    cat > "$INSTALL_DIR/telegram_config.txt" << EOF
TELEGRAM_BOT_TOKEN="$TELEGRAM_BOT_TOKEN"
TELEGRAM_CHAT_ID="$TELEGRAM_CHAT_ID"
EOF
    
    chmod 600 "$INSTALL_DIR/telegram_config.txt"
    
    # Test Telegram connection
    log "🧪 Test kết nối Telegram..."
    
    local domain_list=""
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            domain_list="$domain_list• Instance $((i+1)): ${DOMAINS[$i]}\n"
        done
    else
        domain_list="• Domain: ${DOMAINS[0]}\n"
    fi
    
    TEST_MESSAGE="🚀 *N8N Enhanced Installation Completed*

📅 Date: $(date +'%Y-%m-%d %H:%M:%S')
🌐 Mode: $([[ "$ENABLE_MULTI_DOMAIN" == "true" ]] && echo "Multi-Domain (${#DOMAINS[@]} instances)" || echo "Single Domain")
🐘 PostgreSQL: $([[ "$ENABLE_POSTGRESQL" == "true" ]] && echo "✅ Enabled" || echo "❌ Disabled")
📰 News API: $([[ "$ENABLE_NEWS_API" == "true" ]] && echo "✅ Enabled" || echo "❌ Disabled")
☁️ Google Drive: $([[ "$ENABLE_GOOGLE_DRIVE" == "true" ]] && echo "✅ Enabled" || echo "❌ Disabled")
🤖 Telegram Bot: $([[ "$ENABLE_TELEGRAM_BOT" == "true" ]] && echo "✅ Enabled" || echo "❌ Disabled")

🌐 Domains:
$domain_list
📊 Dashboard: http://$(curl -s https://api.ipify.org 2>/dev/null):8080

✅ System is ready!"

    if curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d text="$TEST_MESSAGE" \
        -d parse_mode="Markdown" > /dev/null; then
        success "✅ Telegram test thành công"
    else
        warning "⚠️ Telegram test thất bại - kiểm tra lại Bot Token và Chat ID"
    fi
}

# =============================================================================
# CRON JOBS
# =============================================================================

setup_cron_jobs() {
    log "⏰ Thiết lập cron jobs..."
    
    # Remove existing cron jobs for n8n
    crontab -l 2>/dev/null | grep -v "/home/n8n" | crontab - 2>/dev/null || true
    
    # Add enhanced backup job (daily at 2:00 AM)
    (crontab -l 2>/dev/null; echo "0 2 * * * /home/n8n/backup-workflows-enhanced.sh") | crontab -
    
    # Add Google Drive cleanup job (weekly)
    if [[ "$ENABLE_GOOGLE_DRIVE" == "true" ]]; then
        (crontab -l 2>/dev/null; echo "0 3 * * 0 /usr/bin/python3 /home/n8n/google_drive/cleanup_old_backups.py --days 90") | crontab -
    fi
    
    success "Đã thiết lập cron jobs"
}

# =============================================================================
# SSL RATE LIMIT DETECTION
# =============================================================================

check_ssl_rate_limit() {
    log "🔒 Kiểm tra SSL certificate..."
    
    # Wait for containers to start
    sleep 30
    
    # Check Caddy logs for rate limit
    local rate_limit_detected=false
    
    if $DOCKER_COMPOSE logs caddy 2>/dev/null | grep -q "rateLimited\|too many certificates"; then
        rate_limit_detected=true
    fi
    
    if [[ "$rate_limit_detected" == "true" ]]; then
        error "🚨 PHÁT HIỆN SSL RATE LIMIT!"
        echo ""
        echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║${WHITE}                        ⚠️  SSL RATE LIMIT DETECTED                          ${RED}║${NC}"
        echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}🔍 NGUYÊN NHÂN:${NC}"
        echo -e "  • Let's Encrypt giới hạn 5 certificates/domain/tuần"
        echo -e "  • Domain này đã đạt giới hạn miễn phí"
        echo -e "  • Cần đợi đến tuần sau để cấp SSL mới"
        echo ""
        echo -e "${YELLOW}💡 GIẢI PHÁP:${NC}"
        echo -e "  ${GREEN}1. SỬ DỤNG STAGING SSL (KHUYẾN NGHỊ):${NC}"
        echo -e "     • Website sẽ hiển thị 'Not Secure' nhưng vẫn hoạt động"
        echo -e "     • Chức năng N8N và API hoạt động đầy đủ"
        echo -e "     • Có thể chuyển về production SSL sau"
        echo ""
        echo -e "  ${GREEN}2. ĐỢI ĐẾN TUẦN SAU:${NC}"
        echo -e "     • Đợi đến sau ngày rate limit reset"
        echo -e "     • Chạy lại script để cấp SSL mới"
        echo ""
        
        read -p "🤔 Bạn muốn tiếp tục với Staging SSL? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            setup_staging_ssl
        else
            echo ""
            echo -e "${CYAN}📋 HƯỚNG DẪN KHẮC PHỤC:${NC}"
            echo -e "  1. Đợi rate limit reset (thường 1 tuần)"
            echo -e "  2. Sử dụng subdomain khác"
            echo -e "  3. Chạy lại script với domains mới"
            echo ""
            exit 1
        fi
    else
        # Test SSL for all domains
        sleep 60
        local ssl_success=true
        
        for domain in "${DOMAINS[@]}"; do
            if curl -I "https://$domain" &>/dev/null; then
                success "✅ SSL certificate đã được cấp cho $domain"
            else
                warning "⚠️ SSL cho $domain có thể chưa sẵn sàng"
                ssl_success=false
            fi
        done
        
        if [[ "$ENABLE_NEWS_API" == "true" ]]; then
            if curl -I "https://$API_DOMAIN" &>/dev/null; then
                success "✅ SSL certificate đã được cấp cho $API_DOMAIN"
            else
                warning "⚠️ SSL cho $API_DOMAIN có thể chưa sẵn sàng"
                ssl_success=false
            fi
        fi
        
        if [[ "$ssl_success" == "false" ]]; then
            warning "⚠️ Một số SSL certificates chưa sẵn sàng - đợi thêm vài phút"
        fi
    fi
}

setup_staging_ssl() {
    warning "🔧 Thiết lập Staging SSL..."
    
    # Stop containers
    $DOCKER_COMPOSE down
    
    # Remove SSL volumes
    docker volume rm n8n_caddy_data n8n_caddy_config 2>/dev/null || true
    
    # Update Caddyfile for staging
    cat > "$INSTALL_DIR/Caddyfile" << EOF
{
    email admin@${DOMAINS[0]}
    acme_ca https://acme-staging-v02.api.letsencrypt.org/directory
    debug
}

EOF

    # Add N8N domains with staging SSL
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            local instance_num=$((i+1))
            local domain="${DOMAINS[$i]}"
            
            cat >> "$INSTALL_DIR/Caddyfile" << EOF
${domain} {
    reverse_proxy n8n-container-${instance_num}:5678 {
        health_uri /healthz
        health_interval 30s
        health_timeout 10s
    }
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    
    encode gzip
    
    log {
        output file /var/log/caddy/n8n_${instance_num}.log {
            roll_size 10mb
            roll_keep 5
        }
        format json
    }
}

EOF
        done
    else
        cat >> "$INSTALL_DIR/Caddyfile" << EOF
${DOMAINS[0]} {
    reverse_proxy n8n-container:5678 {
        health_uri /healthz
        health_interval 30s
        health_timeout 10s
    }
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    
    encode gzip
    
    log {
        output file /var/log/caddy/n8n.log {
            roll_size 10mb
            roll_keep 5
        }
        format json
    }
}

EOF
    fi

    # Add API domain with staging SSL
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        cat >> "$INSTALL_DIR/Caddyfile" << EOF
${API_DOMAIN} {
    reverse_proxy news-api-container:8000 {
        health_uri /health
        health_interval 30s
        health_timeout 10s
    }
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
        Access-Control-Allow-Origin "*"
        Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
        Access-Control-Allow-Headers "Content-Type, Authorization"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    
    encode gzip
    
    log {
        output file /var/log/caddy/api.log {
            roll_size 10mb
            roll_keep 5
        }
        format json
    }
}
EOF
    fi
    
    # Restart containers
    $DOCKER_COMPOSE up -d
    
    success "✅ Đã thiết lập Staging SSL"
    warning "⚠️ Website sẽ hiển thị 'Not Secure' - đây là bình thường với staging certificate"
}

# =============================================================================
# DEPLOYMENT
# =============================================================================

build_and_deploy() {
    log "🏗️ Build và deploy containers..."
    
    cd "$INSTALL_DIR"
    
    # Build images
    log "📦 Build Docker images..."
    $DOCKER_COMPOSE build --no-cache
    
    # Start services
    log "🚀 Khởi động services..."
    $DOCKER_COMPOSE up -d
    
    # Wait for services
    log "⏳ Đợi services khởi động..."
    sleep 30
    
    # Check container status
    log "🔍 Kiểm tra trạng thái containers..."
    if $DOCKER_COMPOSE ps | grep -q "Up"; then
        success "✅ Containers đã khởi động thành công"
    else
        error "❌ Có lỗi khi khởi động containers"
        $DOCKER_COMPOSE logs
        exit 1
    fi
}

# =============================================================================
# FINAL SUMMARY
# =============================================================================

show_final_summary() {
    clear
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${WHITE}                🎉 N8N ENHANCED SYSTEM ĐÃ ĐƯỢC CÀI ĐẶT THÀNH CÔNG!            ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}🌐 TRUY CẬP DỊCH VỤ:${NC}"
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            echo -e "  • N8N Instance $((i+1)): ${WHITE}https://${DOMAINS[$i]}${NC}"
        done
    else
        echo -e "  • N8N: ${WHITE}https://${DOMAINS[0]}${NC}"
    fi
    
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        echo -e "  • News API: ${WHITE}https://${API_DOMAIN}${NC}"
        echo -e "  • API Docs: ${WHITE}https://${API_DOMAIN}/docs${NC}"
        echo -e "  • Bearer Token: ${YELLOW}Đã được đặt (không hiển thị vì bảo mật)${NC}"
    fi
    
    # Get server IP for dashboard
    local server_ip=$(curl -s https://api.ipify.org || echo "YOUR_SERVER_IP")
    echo -e "  • Web Dashboard: ${WHITE}http://${server_ip}:8080${NC}"
    
    echo ""
    echo -e "${CYAN}📁 THÔNG TIN HỆ THỐNG:${NC}"
    echo -e "  • Chế độ: ${WHITE}$([[ "$ENABLE_MULTI_DOMAIN" == "true" ]] && echo "Multi-Domain (${#DOMAINS[@]} instances)" || echo "Single Domain")${NC}"
    echo -e "  • Database: ${WHITE}$([[ "$ENABLE_POSTGRESQL" == "true" ]] && echo "PostgreSQL" || echo "SQLite")${NC}"
    echo -e "  • SSL Email: ${WHITE}${SSL_EMAIL}${NC}"
    echo -e "  • Thư mục cài đặt: ${WHITE}${INSTALL_DIR}${NC}"
    echo -e "  • Script chẩn đoán: ${WHITE}${INSTALL_DIR}/troubleshoot.sh${NC}"
    echo -e "  • Script fix lỗi: ${WHITE}${INSTALL_DIR}/fix_n8n.sh${NC}"
    echo -e "  • Test backup: ${WHITE}${INSTALL_DIR}/backup-manual.sh${NC}"
    echo -e "  • Enhanced backup: ${WHITE}${INSTALL_DIR}/backup-workflows-enhanced.sh${NC}"
    echo ""
    
    echo -e "${CYAN}💾 CẤU HÌNH BACKUP & MONITORING:${NC}"
    local swap_info=$(swapon --show | grep -v NAME | awk '{print $3}' | head -1)
    echo -e "  • Swap: ${WHITE}${swap_info:-"Không có"}${NC}"
    echo -e "  • Telegram backup: ${WHITE}$([[ "$ENABLE_TELEGRAM" == "true" ]] && echo "Enabled" || echo "Disabled")${NC}"
    echo -e "  • Telegram Bot: ${WHITE}$([[ "$ENABLE_TELEGRAM_BOT" == "true" ]] && echo "Enabled" || echo "Disabled")${NC}"
    echo -e "  • Google Drive: ${WHITE}$([[ "$ENABLE_GOOGLE_DRIVE" == "true" ]] && echo "Enabled" || echo "Disabled")${NC}"
    echo -e "  • Backup tự động: ${WHITE}Hàng ngày lúc 2:00 AM${NC}"
    echo -e "  • Backup location: ${WHITE}${INSTALL_DIR}/files/backup_full/${NC}"
    echo ""
    
    if [[ "$ENABLE_TELEGRAM_BOT" == "true" ]]; then
        echo -e "${CYAN}🤖 TELEGRAM BOT COMMANDS:${NC}"
        echo -e "  • ${WHITE}/status${NC} - Trạng thái tất cả instances"
        echo -e "  • ${WHITE}/health${NC} - Health check chi tiết"
        echo -e "  • ${WHITE}/restart n8n${NC} - Restart N8N container"
        echo -e "  • ${WHITE}/backup${NC} - Chạy backup manual"
        echo -e "  • ${WHITE}/logs caddy 50${NC} - Xem 50 dòng logs Caddy"
        echo -e "  • ${WHITE}/performance${NC} - Performance metrics"
        echo ""
    fi
    
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        echo -e "${CYAN}🔧 ĐỔI BEARER TOKEN:${NC}"
        echo -e "  ${WHITE}cd /home/n8n && sed -i 's/NEWS_API_TOKEN=.*/NEWS_API_TOKEN=\"NEW_TOKEN\"/' docker-compose.yml && $DOCKER_COMPOSE restart fastapi${NC}"
        echo ""
    fi
    
    if [[ "$ENABLE_GOOGLE_DRIVE" == "true" ]]; then
        echo -e "${CYAN}☁️ GOOGLE DRIVE SETUP:${NC}"
        echo -e "  1. Upload credentials.json to: ${WHITE}/home/n8n/google_drive/credentials.json${NC}"
        echo -e "  2. Test upload: ${WHITE}python3 /home/n8n/google_drive/gdrive_backup.py list all${NC}"
        echo ""
    fi
    
    echo -e "${CYAN}🚀 TÁC GIẢ:${NC}"
    echo -e "  • Tên: ${WHITE}Nguyễn Ngọc Thiện${NC}"
    echo -e "  • YouTube: ${WHITE}https://www.youtube.com/@kalvinthiensocial?sub_confirmation=1${NC}"
    echo -e "  • Zalo: ${WHITE}08.8888.4749${NC}"
    echo -e "  • Facebook: ${WHITE}https://www.facebook.com/Ban.Thien.Handsome/${NC}"
    echo -e "  • Cập nhật: ${WHITE}01/07/2025${NC}"
    echo -e "  • Version: ${WHITE}3.1 Enhanced - SSL Auto-Fix${NC}"
    echo ""
    
    echo -e "${YELLOW}🎬 ĐĂNG KÝ KÊNH YOUTUBE ĐỂ ỦNG HỘ MÌNH NHÉ! 🔔${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    # Parse arguments
    parse_arguments "$@"
    
    # Show banner
    show_banner
    
    # System checks
    check_root
    check_os
    detect_environment
    check_docker_compose
    
    # Setup swap
    setup_swap
    
    # Get installation mode if not set by arguments
    if [[ "$ENABLE_MULTI_DOMAIN" == "false" && "$ENABLE_POSTGRESQL" == "false" && "$ENABLE_GOOGLE_DRIVE" == "false" && "$ENABLE_TELEGRAM_BOT" == "false" ]]; then
        get_installation_mode
    fi
    
    # Get user input
    get_domain_input
    get_cleanup_option
    get_ssl_email_config
    get_news_api_config
    get_telegram_config
    get_google_drive_config
    get_telegram_bot_config
    
    # Verify DNS
    verify_dns
    
    # Cleanup old installation
    cleanup_old_installation
    
    # Install Docker
    install_docker
    
    # Create project structure
    create_project_structure
    
    # Create configuration files
    create_dockerfile
    create_postgresql_init
    create_news_api
    create_docker_compose
    create_caddyfile
    
    # Create scripts
    create_backup_scripts
    create_restore_script
    create_troubleshooting_script
    
    # Create advanced features
    create_google_drive_integration
    create_telegram_bot
    create_web_dashboard
    
    # Setup services
    create_systemd_services
    
    # Setup Telegram
    setup_telegram_config
    
    # Setup cron jobs
    setup_cron_jobs
    
    # Build and deploy
    build_and_deploy
    
    # Check SSL and rate limits
    check_ssl_rate_limit
    
    # Show final summary
    show_final_summary
}

# Run main function
main "$@"

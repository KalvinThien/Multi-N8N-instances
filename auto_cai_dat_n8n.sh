#!/bin/bash

# =============================================================================
# 🚀 SCRIPT CÀI ĐẶT N8N TỰ ĐỘNG 2025 - PHIÊN BẢN HOÀN CHỈNH
# =============================================================================
# Tác giả: Nguyễn Ngọc Thiện
# YouTube: https://www.youtube.com/@kalvinthiensocial
# Zalo: 08.8888.4749
# Cập nhật: 28/06/2025
# Version: 3.0 - Multi-Domain + PostgreSQL + Management Dashboard
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
ENABLE_NEWS_API=false
ENABLE_TELEGRAM=false
ENABLE_AUTO_UPDATE=false
ENABLE_MULTI_DOMAIN=false
ENABLE_POSTGRESQL=false
CLEAN_INSTALL=false
SKIP_DOCKER=false
POSTGRES_PASSWORD=""

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

show_banner() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                🚀 SCRIPT CÀI ĐẶT N8N TỰ ĐỘNG 2025 - V3.0 🚀                ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${WHITE} ✨ Multi-Domain + PostgreSQL + Management Dashboard                       ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 🔒 SSL Certificate tự động với Caddy                                      ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 📰 News Content API với FastAPI + Newspaper4k                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 📱 Telegram Backup tự động với ZIP compression                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 🔄 Auto-Update với tùy chọn                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 📊 Management Dashboard cho tất cả instances                             ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 🔧 Migration tools cho chuyển đổi server                                 ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${YELLOW} 👨‍💻 Tác giả: Nguyễn Ngọc Thiện                                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 📺 YouTube: https://www.youtube.com/@kalvinthiensocial                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 📱 Zalo: 08.8888.4749                                                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 🎬 Đăng ký kênh để ủng hộ mình nhé! 🔔                                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 📅 Cập nhật: 28/06/2025 - Version 3.0                                  ${CYAN}║${NC}"
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
    echo "  -h, --help          Hiển thị trợ giúp này"
    echo "  -d, --dir DIR       Thư mục cài đặt (mặc định: /home/n8n)"
    echo "  -c, --clean         Xóa cài đặt cũ trước khi cài mới"
    echo "  -s, --skip-docker   Bỏ qua cài đặt Docker (nếu đã có)"
    echo "  -m, --multi-domain  Bật chế độ multi-domain"
    echo "  -p, --postgresql    Sử dụng PostgreSQL thay vì SQLite"
    echo ""
    echo "Ví dụ:"
    echo "  $0                          # Cài đặt bình thường"
    echo "  $0 --clean                 # Xóa cài đặt cũ và cài mới"
    echo "  $0 -m -p                   # Multi-domain với PostgreSQL"
    echo "  $0 --multi-domain --postgresql --clean  # Full install"
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
    log "Tạo swap file ${swap_size} cho multi-domain..."
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

get_domain_input() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                           🌐 CẤU HÌNH DOMAIN                                ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        echo -e "${WHITE}🌐 MULTI-DOMAIN MODE${NC}"
        echo -e "  • Bạn có thể thêm nhiều domains cho N8N"
        echo -e "  • Mỗi domain sẽ có N8N instance riêng"
        echo -e "  • Tất cả sẽ chia sẻ News API và PostgreSQL"
        echo ""
        
        while true; do
            read -p "🌐 Nhập domain thứ $((${#DOMAINS[@]} + 1)) (Enter để kết thúc): " domain
            if [[ -z "$domain" ]]; then
                if [[ ${#DOMAINS[@]} -eq 0 ]]; then
                    error "Cần ít nhất 1 domain!"
                    continue
                else
                    break
                fi
            fi
            
            if [[ "$domain" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$ ]]; then
                DOMAINS+=("$domain")
                success "Đã thêm domain: $domain"
            else
                error "Domain không hợp lệ. Vui lòng nhập lại."
            fi
        done
        
        # Set API domain to first domain
        API_DOMAIN="api.${DOMAINS[0]}"
        
        echo ""
        echo -e "${GREEN}📋 DANH SÁCH DOMAINS:${NC}"
        for i in "${!DOMAINS[@]}"; do
            echo -e "  $((i+1)). N8N Instance: ${DOMAINS[i]}"
        done
        echo -e "  📰 News API: ${API_DOMAIN}"
        
    else
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
        
        info "Domain N8N: ${DOMAINS[0]}"
        info "Domain API: ${API_DOMAIN}"
    fi
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

get_postgresql_config() {
    if [[ "$ENABLE_POSTGRESQL" != "true" ]]; then
        return 0
    fi
    
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        🐘 POSTGRESQL DATABASE                              ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}PostgreSQL sẽ thay thế SQLite với:${NC}"
    echo -e "  🚀 Hiệu suất cao hơn cho multi-domain"
    echo -e "  🔄 Concurrent connections tốt hơn"
    echo -e "  💾 Backup và restore dễ dàng"
    echo -e "  🔒 Database riêng cho mỗi N8N instance"
    echo -e "  💰 Hoàn toàn miễn phí (PostgreSQL 15)"
    echo ""
    
    # Generate random password
    POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    success "Đã tạo PostgreSQL password tự động"
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
    echo -e "  📱 Gửi file backup ZIP qua Telegram Bot"
    echo -e "  📊 Báo cáo chi tiết từng N8N instance"
    echo -e "  🗂️ Giữ backup local nếu gửi Telegram thất bại"
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

get_auto_update_config() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        🔄 AUTO-UPDATE                                      ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Auto-Update sẽ:${NC}"
    echo -e "  🔄 Tự động cập nhật N8N mỗi 12 giờ"
    echo -e "  📦 Cập nhật yt-dlp, FFmpeg và các dependencies"
    echo -e "  📋 Ghi log chi tiết quá trình update"
    echo -e "  🔒 Backup trước khi update"
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        echo -e "  🌐 Update tất cả N8N instances cùng lúc"
    fi
    echo ""
    
    read -p "🔄 Bạn có muốn bật Auto-Update? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        ENABLE_AUTO_UPDATE=false
    else
        ENABLE_AUTO_UPDATE=true
        success "Đã bật Auto-Update"
    fi
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
            dns_issues=true
        fi
    done
    
    # Check API domain if enabled
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        local api_domain_ip=$(dig +short "$API_DOMAIN" A | tail -n1)
        info "IP của ${API_DOMAIN}: ${api_domain_ip:-"không tìm thấy"}"
        
        if [[ "$api_domain_ip" != "$server_ip" ]]; then
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
    docker rmi $(docker images --filter "reference=n8n-custom-*" -q) 2>/dev/null || true
    docker rmi news-api:latest postgres:15-alpine 2>/dev/null || true
    
    # Remove installation directory
    rm -rf "$INSTALL_DIR"
    
    # Remove cron jobs
    crontab -l 2>/dev/null | grep -v "/home/n8n" | crontab - 2>/dev/null || true
    
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
    apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
    
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
    mkdir -p management
    
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
    
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        mkdir -p news_api
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
    title="News Content API",
    description="Advanced News Content Extraction API with Newspaper4k - Multi-Domain Support",
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
            body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }}
            .container {{ max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }}
            h1 {{ color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }}
            h2 {{ color: #34495e; margin-top: 30px; }}
            .endpoint {{ background: #ecf0f1; padding: 15px; border-radius: 5px; margin: 10px 0; }}
            .method {{ background: #3498db; color: white; padding: 3px 8px; border-radius: 3px; font-size: 12px; }}
            .auth-info {{ background: #e74c3c; color: white; padding: 15px; border-radius: 5px; margin: 20px 0; }}
            .token-change {{ background: #f39c12; color: white; padding: 15px; border-radius: 5px; margin: 20px 0; }}
            code {{ background: #2c3e50; color: #ecf0f1; padding: 2px 5px; border-radius: 3px; }}
            pre {{ background: #2c3e50; color: #ecf0f1; padding: 15px; border-radius: 5px; overflow-x: auto; }}
            .feature {{ background: #27ae60; color: white; padding: 10px; border-radius: 5px; margin: 5px 0; }}
            .multi-domain {{ background: #9b59b6; color: white; padding: 15px; border-radius: 5px; margin: 20px 0; }}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 News Content API v3.0 - Multi-Domain</h1>
            <p>Advanced News Content Extraction API với <strong>Newspaper4k</strong> và <strong>Multi-Domain Support</strong></p>
            
            <div class="multi-domain">
                <h3>🌐 Multi-Domain Support</h3>
                <p>API này được chia sẻ cho tất cả N8N instances trong hệ thống multi-domain.</p>
                <p><strong>Tối ưu hóa:</strong> Một API phục vụ nhiều N8N instances, tiết kiệm tài nguyên server.</p>
            </div>
            
            <div class="auth-info">
                <h3>🔐 Authentication Required</h3>
                <p>Tất cả API calls yêu cầu Bearer Token trong header:</p>
                <code>Authorization: Bearer YOUR_TOKEN</code>
                <p><strong>Lưu ý:</strong> Token đã được đặt trong quá trình cài đặt và không hiển thị ở đây vì lý do bảo mật.</p>
            </div>

            <div class="token-change">
                <h3>🔧 Đổi Bearer Token</h3>
                <p><strong>One-liner command:</strong></p>
                <pre>cd /home/n8n && sed -i 's/NEWS_API_TOKEN=.*/NEWS_API_TOKEN="NEW_TOKEN"/' docker-compose.yml && docker-compose restart fastapi</pre>
            </div>
            
            <h2>✨ Tính Năng</h2>
            <div class="feature">📰 Cào nội dung bài viết từ bất kỳ website nào</div>
            <div class="feature">📡 Parse RSS feeds để lấy tin tức mới nhất</div>
            <div class="feature">🔍 Tìm kiếm và phân tích nội dung tự động</div>
            <div class="feature">🌍 Hỗ trợ 80+ ngôn ngữ (Việt, Anh, Trung, Nhật...)</div>
            <div class="feature">🎭 Random User Agents để tránh bị block</div>
            <div class="feature">🌐 Multi-Domain: Chia sẻ cho tất cả N8N instances</div>
            <div class="feature">🤖 Tích hợp trực tiếp vào N8N workflows</div>
            
            <h2>📖 API Endpoints</h2>
            
            <div class="endpoint">
                <span class="method">GET</span> <strong>/health</strong>
                <p>Kiểm tra trạng thái API</p>
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
                <a href="/docs" target="_blank">📚 Swagger UI</a> | 
                <a href="/redoc" target="_blank">📖 ReDoc</a>
            </p>
            
            <h2>💻 Ví Dụ cURL</h2>
            <pre>curl -X POST "https://api.yourdomain.com/extract-article" \\
     -H "Content-Type: application/json" \\
     -H "Authorization: Bearer YOUR_TOKEN" \\
     -d '{{"url": "https://dantri.com.vn/the-gioi.htm", "language": "vi"}}'</pre>
            
            <hr style="margin: 30px 0;">
            <p style="text-align: center; color: #7f8c8d;">
                🚀 Powered by <strong>Newspaper4k</strong> | 
                🌐 <strong>Multi-Domain Support</strong> |
                👨‍💻 Created by <strong>Nguyễn Ngọc Thiện</strong> | 
                📺 <a href="https://www.youtube.com/@kalvinthiensocial">YouTube Channel</a>
            </p>
        </div>
    </body>
    </html>
    """
    return html_content

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.now(),
        "version": "3.0.0",
        "multi_domain_support": True,
        "features": [
            "Article extraction",
            "Source crawling", 
            "RSS feed parsing",
            "Multi-language support",
            "Random User Agents",
            "Image extraction",
            "Keyword extraction",
            "Content summarization",
            "Multi-domain sharing"
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
    
    success "Đã tạo News Content API với Multi-Domain support"
}

create_docker_compose() {
    log "🐳 Tạo docker-compose.yml..."
    
    cat > "$INSTALL_DIR/docker-compose.yml" << EOF
version: '3.8'

services:
EOF

    # Add PostgreSQL if enabled
    if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
        cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
  postgres:
    image: postgres:15-alpine
    container_name: postgres-n8n
    restart: unless-stopped
    environment:
      - POSTGRES_DB=n8n_db
      - POSTGRES_USER=n8n_user
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_MULTIPLE_DATABASES=n8n_db
    volumes:
      - ./postgres_data:/var/lib/postgresql/data
      - ./init-multi-db.sh:/docker-entrypoint-initdb.d/init-multi-db.sh:ro
    ports:
      - "127.0.0.1:5432:5432"
    networks:
      - n8n_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U n8n_user -d n8n_db"]
      interval: 10s
      timeout: 5s
      retries: 5

EOF
    fi

    # Add N8N instances
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            local instance_num=$((i+1))
            local port=$((5678+i))
            local db_config=""
            
            if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
                db_config="
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n_db_instance_${instance_num}
      - DB_POSTGRESDB_USER=n8n_user
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
      - DB_POSTGRESDB_SCHEMA=n8n_instance_${instance_num}"
            else
                db_config="
      - DB_TYPE=sqlite
      - DB_SQLITE_DATABASE=/home/node/.n8n/database.sqlite"
            fi

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
      - WEBHOOK_URL=https://${DOMAINS[i]}/
      - GENERIC_TIMEZONE=Asia/Ho_Chi_Minh
      - N8N_METRICS=true
      - N8N_LOG_LEVEL=info
      - N8N_LOG_OUTPUT=console
      - N8N_USER_FOLDER=/home/node
      - N8N_ENCRYPTION_KEY=\${N8N_ENCRYPTION_KEY_${instance_num}:-$(openssl rand -hex 32)}${db_config}
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
      postgres:
        condition: service_healthy
EOF
            fi
            echo "" >> "$INSTALL_DIR/docker-compose.yml"
        done
    else
        # Single domain setup
        local db_config=""
        if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
            db_config="
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n_db
      - DB_POSTGRESDB_USER=n8n_user
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}"
        else
            db_config="
      - DB_TYPE=sqlite
      - DB_SQLITE_DATABASE=/home/node/.n8n/database.sqlite"
        fi

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
      - N8N_ENCRYPTION_KEY=\${N8N_ENCRYPTION_KEY:-$(openssl rand -hex 32)}${db_config}
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
      postgres:
        condition: service_healthy
EOF
        fi
        echo "" >> "$INSTALL_DIR/docker-compose.yml"
    fi

    # Add Caddy
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

    # Add dependencies for Caddy
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            local instance_num=$((i+1))
            echo "      - n8n_${instance_num}" >> "$INSTALL_DIR/docker-compose.yml"
        done
    else
        echo "      - n8n" >> "$INSTALL_DIR/docker-compose.yml"
    fi

    # Add News API if enabled
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

    # Add volumes and networks
    cat >> "$INSTALL_DIR/docker-compose.yml" << 'EOF'

volumes:
  caddy_data:
  caddy_config:

networks:
  n8n_network:
    driver: bridge
EOF
    
    success "Đã tạo docker-compose.yml với Multi-Domain support"
}

create_postgresql_init_script() {
    if [[ "$ENABLE_POSTGRESQL" != "true" ]]; then
        return 0
    fi
    
    log "🐘 Tạo PostgreSQL initialization script..."
    
    cat > "$INSTALL_DIR/init-multi-db.sh" << 'EOF'
#!/bin/bash
set -e

# Create databases for each N8N instance
if [ "$ENABLE_MULTI_DOMAIN" = "true" ]; then
    for i in {1..10}; do
        DB_NAME="n8n_db_instance_$i"
        SCHEMA_NAME="n8n_instance_$i"
        
        echo "Creating database: $DB_NAME"
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
            CREATE DATABASE $DB_NAME;
            GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $POSTGRES_USER;
EOSQL
        
        echo "Creating schema: $SCHEMA_NAME in database: $DB_NAME"
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$DB_NAME" <<-EOSQL
            CREATE SCHEMA IF NOT EXISTS $SCHEMA_NAME;
            GRANT ALL ON SCHEMA $SCHEMA_NAME TO $POSTGRES_USER;
EOSQL
    done
fi

echo "PostgreSQL multi-database initialization completed"
EOF
    
    chmod +x "$INSTALL_DIR/init-multi-db.sh"
    
    success "Đã tạo PostgreSQL initialization script"
}

create_caddyfile() {
    log "🌐 Tạo Caddyfile..."
    
    cat > "$INSTALL_DIR/Caddyfile" << EOF
{
    email admin@${DOMAINS[0]}
    acme_ca https://acme-v02.api.letsencrypt.org/directory
}

EOF

    # Add N8N domains
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            local instance_num=$((i+1))
            local port=$((5678+i))
            
            cat >> "$INSTALL_DIR/Caddyfile" << EOF
${DOMAINS[i]} {
    reverse_proxy n8n_${instance_num}:5678
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
    }
    
    encode gzip
    
    log {
        output file /var/log/caddy/n8n_instance_${instance_num}.log
        format json
    }
}

EOF
        done
    else
        cat >> "$INSTALL_DIR/Caddyfile" << EOF
${DOMAINS[0]} {
    reverse_proxy n8n:5678
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
    }
    
    encode gzip
    
    log {
        output file /var/log/caddy/n8n.log
        format json
    }
}

EOF
    fi

    # Add News API domain if enabled
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        cat >> "$INSTALL_DIR/Caddyfile" << EOF
${API_DOMAIN} {
    reverse_proxy fastapi:8000
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
        Access-Control-Allow-Origin "*"
        Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
        Access-Control-Allow-Headers "Content-Type, Authorization"
    }
    
    encode gzip
    
    log {
        output file /var/log/caddy/api.log
        format json
    }
}
EOF
    fi
    
    success "Đã tạo Caddyfile với Multi-Domain support"
}

# =============================================================================
# MANAGEMENT DASHBOARD
# =============================================================================

create_management_dashboard() {
    log "📊 Tạo Management Dashboard..."
    
    cat > "$INSTALL_DIR/management/dashboard.sh" << 'EOF'
#!/bin/bash

# =============================================================================
# N8N MANAGEMENT DASHBOARD - Multi-Domain Support
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Check Docker Compose command
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    echo -e "${RED}❌ Docker Compose không tìm thấy!${NC}"
    exit 1
fi

show_header() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                    📊 N8N MANAGEMENT DASHBOARD                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}                      Multi-Domain Support                                  ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_system_info() {
    echo -e "${BLUE}🖥️  SYSTEM INFORMATION${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "• OS: $(lsb_release -d | cut -f2)"
    echo "• Kernel: $(uname -r)"
    echo "• Uptime: $(uptime -p)"
    echo "• Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    echo ""
    
    echo -e "${BLUE}💾 MEMORY & DISK${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    free -h | grep -E "(Mem|Swap)" | while read line; do
        echo "• $line"
    done
    echo "• Disk Usage: $(df -h /home/n8n | tail -1 | awk '{print $3"/"$2" ("$5")"}')"
    echo ""
}

show_docker_status() {
    echo -e "${BLUE}🐳 DOCKER CONTAINERS${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    cd /home/n8n
    
    # Get container status with custom format
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "name=n8n" --filter "name=caddy" --filter "name=postgres" --filter "name=news-api"
    echo ""
    
    # Show resource usage
    echo -e "${BLUE}📊 RESOURCE USAGE${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" --filter "name=n8n" --filter "name=caddy" --filter "name=postgres" --filter "name=news-api"
    echo ""
}

show_n8n_instances() {
    echo -e "${BLUE}🚀 N8N INSTANCES${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Get N8N containers
    local n8n_containers=$(docker ps --filter "name=n8n-container" --format "{{.Names}}")
    
    if [[ -z "$n8n_containers" ]]; then
        echo -e "${RED}❌ Không tìm thấy N8N containers${NC}"
        return
    fi
    
    local instance_count=0
    for container in $n8n_containers; do
        instance_count=$((instance_count + 1))
        
        # Get container info
        local status=$(docker inspect $container --format '{{.State.Status}}')
        local started=$(docker inspect $container --format '{{.State.StartedAt}}' | cut -d'T' -f1)
        local domain=$(docker inspect $container --format '{{range .Config.Env}}{{if contains "WEBHOOK_URL" .}}{{.}}{{end}}{{end}}' | cut -d'=' -f2 | sed 's|https://||' | sed 's|/||')
        
        # Get health status
        local health="Unknown"
        if [[ "$status" == "running" ]]; then
            if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$((5677 + instance_count))" | grep -q "200\|302"; then
                health="${GREEN}✅ Healthy${NC}"
            else
                health="${YELLOW}⚠️  Starting${NC}"
            fi
        else
            health="${RED}❌ Down${NC}"
        fi
        
        echo -e "Instance $instance_count:"
        echo -e "  • Container: $container"
        echo -e "  • Domain: ${WHITE}$domain${NC}"
        echo -e "  • Status: $health"
        echo -e "  • Started: $started"
        echo ""
    done
    
    echo -e "${GREEN}📈 Total N8N Instances: $instance_count${NC}"
    echo ""
}

show_database_info() {
    echo -e "${BLUE}🐘 DATABASE INFORMATION${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if docker ps --filter "name=postgres-n8n" --format "{{.Names}}" | grep -q "postgres-n8n"; then
        echo -e "${GREEN}✅ PostgreSQL is running${NC}"
        
        # Get database info
        local db_version=$(docker exec postgres-n8n psql -U n8n_user -d n8n_db -t -c "SELECT version();" 2>/dev/null | head -1 | xargs)
        echo "• Version: ${db_version}"
        
        # Get database list
        echo "• Databases:"
        docker exec postgres-n8n psql -U n8n_user -l 2>/dev/null | grep "n8n_db" | while read line; do
            local db_name=$(echo $line | awk '{print $1}')
            local db_size=$(echo $line | awk '{print $7}')
            echo "  - $db_name ($db_size)"
        done
        
        # Get connection count
        local connections=$(docker exec postgres-n8n psql -U n8n_user -d n8n_db -t -c "SELECT count(*) FROM pg_stat_activity;" 2>/dev/null | xargs)
        echo "• Active connections: $connections"
        
    else
        echo -e "${YELLOW}⚠️  Using SQLite databases${NC}"
        
        # Show SQLite files
        find /home/n8n/files -name "database.sqlite" -exec ls -lh {} \; | while read line; do
            echo "• $line"
        done
    fi
    echo ""
}

show_backup_info() {
    echo -e "${BLUE}💾 BACKUP INFORMATION${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local backup_dir="/home/n8n/files/backup_full"
    
    if [[ -d "$backup_dir" ]]; then
        local backup_count=$(ls -1 "$backup_dir"/n8n_backup_*.tar.gz 2>/dev/null | wc -l)
        echo "• Total backups: $backup_count"
        
        if [[ $backup_count -gt 0 ]]; then
            local latest_backup=$(ls -t "$backup_dir"/n8n_backup_*.tar.gz | head -1)
            local backup_size=$(ls -lh "$latest_backup" | awk '{print $5}')
            local backup_date=$(stat -c %y "$latest_backup" | cut -d' ' -f1)
            
            echo "• Latest backup: $(basename "$latest_backup")"
            echo "• Size: $backup_size"
            echo "• Date: $backup_date"
            
            # Show disk usage of backup directory
            local backup_total_size=$(du -sh "$backup_dir" | awk '{print $1}')
            echo "• Total backup size: $backup_total_size"
        fi
    else
        echo -e "${RED}❌ Backup directory not found${NC}"
    fi
    
    # Check cron jobs
    echo ""
    echo "• Scheduled backups:"
    crontab -l 2>/dev/null | grep -E "(backup|n8n)" | while read line; do
        echo "  - $line"
    done
    echo ""
}

show_ssl_info() {
    echo -e "${BLUE}🔒 SSL CERTIFICATES${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Get domains from Caddyfile
    local domains=$(grep -E "^[a-zA-Z0-9.-]+\s*{" /home/n8n/Caddyfile | awk '{print $1}')
    
    for domain in $domains; do
        echo -n "• $domain: "
        
        # Test SSL
        if timeout 5 curl -s -I "https://$domain" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ SSL Active${NC}"
            
            # Get certificate info
            local cert_info=$(timeout 5 openssl s_client -connect "$domain:443" -servername "$domain" </dev/null 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)
            if [[ -n "$cert_info" ]]; then
                local expiry=$(echo "$cert_info" | grep "notAfter" | cut -d'=' -f2)
                echo "  Expires: $expiry"
            fi
        else
            echo -e "${RED}❌ SSL Error${NC}"
        fi
    done
    echo ""
}

show_logs_summary() {
    echo -e "${BLUE}📋 RECENT LOGS SUMMARY${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    cd /home/n8n
    
    # Show recent errors from all containers
    echo "• Recent errors (last 24 hours):"
    $DOCKER_COMPOSE logs --since 24h 2>/dev/null | grep -i "error\|fail\|exception" | tail -5 | while read line; do
        echo "  - $line"
    done
    
    echo ""
    echo "• Container restart count (last 24 hours):"
    docker ps --filter "name=n8n" --filter "name=caddy" --filter "name=postgres" --filter "name=news-api" --format "{{.Names}}" | while read container; do
        local restarts=$(docker inspect $container --format '{{.RestartCount}}')
        echo "  - $container: $restarts restarts"
    done
    echo ""
}

show_quick_actions() {
    echo -e "${BLUE}⚡ QUICK ACTIONS${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${YELLOW}1.${NC} Restart all services: ${WHITE}cd /home/n8n && docker-compose restart${NC}"
    echo -e "${YELLOW}2.${NC} View live logs: ${WHITE}cd /home/n8n && docker-compose logs -f${NC}"
    echo -e "${YELLOW}3.${NC} Manual backup: ${WHITE}/home/n8n/backup-manual.sh${NC}"
    echo -e "${YELLOW}4.${NC} Update N8N: ${WHITE}/home/n8n/update-n8n.sh${NC}"
    echo -e "${YELLOW}5.${NC} Troubleshoot: ${WHITE}/home/n8n/troubleshoot.sh${NC}"
    echo -e "${YELLOW}6.${NC} Management menu: ${WHITE}/home/n8n/management/menu.sh${NC}"
    echo ""
}

# Main execution
cd /home/n8n 2>/dev/null || {
    echo -e "${RED}❌ N8N installation not found at /home/n8n${NC}"
    exit 1
}

show_header
show_system_info
show_docker_status
show_n8n_instances
show_database_info
show_backup_info
show_ssl_info
show_logs_summary
show_quick_actions

echo -e "${GREEN}✅ Dashboard updated: $(date)${NC}"
echo -e "${CYAN}🔄 Auto-refresh every 30 seconds. Press Ctrl+C to exit.${NC}"
echo ""

# Auto-refresh option
if [[ "$1" == "--watch" ]]; then
    while true; do
        sleep 30
        exec "$0"
    done
fi
EOF

    chmod +x "$INSTALL_DIR/management/dashboard.sh"
    
    success "Đã tạo Management Dashboard"
}

create_management_menu() {
    log "📋 Tạo Management Menu..."
    
    cat > "$INSTALL_DIR/management/menu.sh" << 'EOF'
#!/bin/bash

# =============================================================================
# N8N MANAGEMENT MENU - Multi-Domain Support
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Check Docker Compose command
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    echo -e "${RED}❌ Docker Compose không tìm thấy!${NC}"
    exit 1
fi

show_menu() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                      🎛️  N8N MANAGEMENT MENU                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}                       Multi-Domain Support                                 ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${BLUE}📊 MONITORING & STATUS${NC}"
    echo -e "${YELLOW}1.${NC} Dashboard (Real-time)"
    echo -e "${YELLOW}2.${NC} Container Status"
    echo -e "${YELLOW}3.${NC} View Logs (Live)"
    echo -e "${YELLOW}4.${NC} Resource Usage"
    echo -e "${YELLOW}5.${NC} SSL Certificate Status"
    echo ""
    
    echo -e "${BLUE}🔧 MANAGEMENT${NC}"
    echo -e "${YELLOW}6.${NC} Restart All Services"
    echo -e "${YELLOW}7.${NC} Restart Specific Instance"
    echo -e "${YELLOW}8.${NC} Update N8N"
    echo -e "${YELLOW}9.${NC} Rebuild Containers"
    echo ""
    
    echo -e "${BLUE}💾 BACKUP & RESTORE${NC}"
    echo -e "${YELLOW}10.${NC} Manual Backup"
    echo -e "${YELLOW}11.${NC} List Backups"
    echo -e "${YELLOW}12.${NC} Restore from Backup"
    echo -e "${YELLOW}13.${NC} Export for Migration"
    echo ""
    
    echo -e "${BLUE}🔧 CONFIGURATION${NC}"
    echo -e "${YELLOW}14.${NC} Change News API Token"
    echo -e "${YELLOW}15.${NC} Update Telegram Config"
    echo -e "${YELLOW}16.${NC} Add New Domain"
    echo -e "${YELLOW}17.${NC} Remove Domain"
    echo ""
    
    echo -e "${BLUE}🚨 TROUBLESHOOTING${NC}"
    echo -e "${YELLOW}18.${NC} Run Diagnostics"
    echo -e "${YELLOW}19.${NC} Fix Common Issues"
    echo -e "${YELLOW}20.${NC} Clean Docker System"
    echo ""
    
    echo -e "${YELLOW}0.${NC} Exit"
    echo ""
    echo -n "Chọn tùy chọn (0-20): "
}

dashboard() {
    /home/n8n/management/dashboard.sh --watch
}

container_status() {
    echo -e "${BLUE}🐳 Container Status${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cd /home/n8n
    $DOCKER_COMPOSE ps
    echo ""
    read -p "Press Enter to continue..."
}

view_logs() {
    echo -e "${BLUE}📋 Select logs to view:${NC}"
    echo "1. All containers"
    echo "2. N8N instances only"
    echo "3. Caddy proxy"
    echo "4. PostgreSQL"
    echo "5. News API"
    echo ""
    read -p "Choose option (1-5): " log_choice
    
    cd /home/n8n
    case $log_choice in
        1) $DOCKER_COMPOSE logs -f ;;
        2) $DOCKER_COMPOSE logs -f $(docker ps --filter "name=n8n-container" --format "{{.Names}}" | tr '\n' ' ') ;;
        3) $DOCKER_COMPOSE logs -f caddy ;;
        4) $DOCKER_COMPOSE logs -f postgres ;;
        5) $DOCKER_COMPOSE logs -f fastapi ;;
        *) echo "Invalid option" ;;
    esac
}

resource_usage() {
    echo -e "${BLUE}📊 Resource Usage${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    docker stats --no-stream
    echo ""
    echo -e "${BLUE}💾 Disk Usage${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    df -h /home/n8n
    echo ""
    read -p "Press Enter to continue..."
}

ssl_status() {
    echo -e "${BLUE}🔒 SSL Certificate Status${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local domains=$(grep -E "^[a-zA-Z0-9.-]+\s*{" /home/n8n/Caddyfile | awk '{print $1}')
    
    for domain in $domains; do
        echo -n "Testing $domain: "
        if timeout 5 curl -s -I "https://$domain" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ SSL Active${NC}"
        else
            echo -e "${RED}❌ SSL Error${NC}"
        fi
    done
    echo ""
    read -p "Press Enter to continue..."
}

restart_all() {
    echo -e "${YELLOW}🔄 Restarting all services...${NC}"
    cd /home/n8n
    $DOCKER_COMPOSE restart
    echo -e "${GREEN}✅ All services restarted${NC}"
    sleep 2
}

restart_instance() {
    echo -e "${BLUE}🔄 Available N8N instances:${NC}"
    local instances=$(docker ps --filter "name=n8n-container" --format "{{.Names}}")
    local i=1
    
    for instance in $instances; do
        echo "$i. $instance"
        i=$((i+1))
    done
    
    echo ""
    read -p "Select instance to restart (number): " instance_num
    
    local selected_instance=$(echo "$instances" | sed -n "${instance_num}p")
    if [[ -n "$selected_instance" ]]; then
        echo -e "${YELLOW}🔄 Restarting $selected_instance...${NC}"
        cd /home/n8n
        $DOCKER_COMPOSE restart "$selected_instance"
        echo -e "${GREEN}✅ $selected_instance restarted${NC}"
    else
        echo -e "${RED}❌ Invalid selection${NC}"
    fi
    sleep 2
}

update_n8n() {
    echo -e "${YELLOW}🔄 Updating N8N...${NC}"
    /home/n8n/update-n8n.sh
    echo ""
    read -p "Press Enter to continue..."
}

rebuild_containers() {
    echo -e "${YELLOW}⚠️  This will rebuild all containers. Continue? (y/N): ${NC}"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}🏗️  Rebuilding containers...${NC}"
        cd /home/n8n
        $DOCKER_COMPOSE down
        $DOCKER_COMPOSE up -d --build
        echo -e "${GREEN}✅ Containers rebuilt${NC}"
    fi
    sleep 2
}

manual_backup() {
    echo -e "${YELLOW}💾 Running manual backup...${NC}"
    /home/n8n/backup-manual.sh
    echo ""
    read -p "Press Enter to continue..."
}

list_backups() {
    echo -e "${BLUE}💾 Available Backups${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local backup_dir="/home/n8n/files/backup_full"
    if [[ -d "$backup_dir" ]]; then
        ls -lah "$backup_dir"/n8n_backup_*.tar.gz 2>/dev/null | while read line; do
            echo "$line"
        done
    else
        echo -e "${RED}❌ No backup directory found${NC}"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

restore_backup() {
    echo -e "${BLUE}🔄 Restore from Backup${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local backup_dir="/home/n8n/files/backup_full"
    if [[ ! -d "$backup_dir" ]]; then
        echo -e "${RED}❌ No backup directory found${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo "Available backups:"
    local backups=($(ls -t "$backup_dir"/n8n_backup_*.tar.gz 2>/dev/null))
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        echo -e "${RED}❌ No backups found${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    for i in "${!backups[@]}"; do
        echo "$((i+1)). $(basename "${backups[i]}")"
    done
    
    echo ""
    read -p "Select backup to restore (number): " backup_num
    
    if [[ $backup_num -ge 1 && $backup_num -le ${#backups[@]} ]]; then
        local selected_backup="${backups[$((backup_num-1))]}"
        echo -e "${YELLOW}⚠️  This will stop all services and restore data. Continue? (y/N): ${NC}"
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            /home/n8n/management/restore.sh "$selected_backup"
        fi
    else
        echo -e "${RED}❌ Invalid selection${NC}"
    fi
    sleep 2
}

export_migration() {
    echo -e "${BLUE}📦 Export for Migration${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    /home/n8n/management/export-migration.sh
    echo ""
    read -p "Press Enter to continue..."
}

change_api_token() {
    echo -e "${BLUE}🔑 Change News API Token${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    read -p "Enter new Bearer Token (min 20 chars): " new_token
    
    if [[ ${#new_token} -ge 20 && "$new_token" =~ ^[a-zA-Z0-9]+$ ]]; then
        cd /home/n8n
        sed -i "s/NEWS_API_TOKEN=.*/NEWS_API_TOKEN=$new_token/" docker-compose.yml
        $DOCKER_COMPOSE restart fastapi
        echo -e "${GREEN}✅ API Token updated successfully${NC}"
    else
        echo -e "${RED}❌ Invalid token format${NC}"
    fi
    sleep 2
}

update_telegram() {
    echo -e "${BLUE}📱 Update Telegram Config${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    read -p "Enter Telegram Bot Token: " bot_token
    read -p "Enter Telegram Chat ID: " chat_id
    
    if [[ -n "$bot_token" && -n "$chat_id" ]]; then
        cat > /home/n8n/telegram_config.txt << EOF
TELEGRAM_BOT_TOKEN="$bot_token"
TELEGRAM_CHAT_ID="$chat_id"
EOF
        chmod 600 /home/n8n/telegram_config.txt
        echo -e "${GREEN}✅ Telegram config updated${NC}"
    else
        echo -e "${RED}❌ Invalid input${NC}"
    fi
    sleep 2
}

add_domain() {
    echo -e "${BLUE}🌐 Add New Domain${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${YELLOW}⚠️  This feature requires manual configuration.${NC}"
    echo "Please run the installation script again with --multi-domain option."
    echo ""
    read -p "Press Enter to continue..."
}

remove_domain() {
    echo -e "${BLUE}🗑️  Remove Domain${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${YELLOW}⚠️  This feature requires manual configuration.${NC}"
    echo "Please contact support for domain removal."
    echo ""
    read -p "Press Enter to continue..."
}

run_diagnostics() {
    echo -e "${BLUE}🔧 Running Diagnostics${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    /home/n8n/troubleshoot.sh
    echo ""
    read -p "Press Enter to continue..."
}

fix_issues() {
    echo -e "${BLUE}🔧 Fix Common Issues${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    echo "1. Restart all services"
    echo "2. Rebuild containers"
    echo "3. Clean Docker system"
    echo "4. Fix permissions"
    echo "5. Reset SSL certificates"
    echo ""
    read -p "Select fix (1-5): " fix_choice
    
    case $fix_choice in
        1) restart_all ;;
        2) rebuild_containers ;;
        3) clean_docker ;;
        4) fix_permissions ;;
        5) reset_ssl ;;
        *) echo "Invalid option" ;;
    esac
}

clean_docker() {
    echo -e "${YELLOW}🧹 Cleaning Docker system...${NC}"
    docker system prune -f
    docker volume prune -f
    echo -e "${GREEN}✅ Docker system cleaned${NC}"
    sleep 2
}

fix_permissions() {
    echo -e "${YELLOW}🔧 Fixing permissions...${NC}"
    chown -R $SUDO_USER:$SUDO_USER /home/n8n
    chmod +x /home/n8n/*.sh
    chmod +x /home/n8n/management/*.sh
    echo -e "${GREEN}✅ Permissions fixed${NC}"
    sleep 2
}

reset_ssl() {
    echo -e "${YELLOW}⚠️  This will reset all SSL certificates. Continue? (y/N): ${NC}"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd /home/n8n
        $DOCKER_COMPOSE down caddy
        docker volume rm n8n_caddy_data n8n_caddy_config 2>/dev/null || true
        $DOCKER_COMPOSE up -d caddy
        echo -e "${GREEN}✅ SSL certificates reset${NC}"
    fi
    sleep 2
}

# Main loop
while true; do
    show_menu
    read choice
    
    case $choice in
        1) dashboard ;;
        2) container_status ;;
        3) view_logs ;;
        4) resource_usage ;;
        5) ssl_status ;;
        6) restart_all ;;
        7) restart_instance ;;
        8) update_n8n ;;
        9) rebuild_containers ;;
        10) manual_backup ;;
        11) list_backups ;;
        12) restore_backup ;;
        13) export_migration ;;
        14) change_api_token ;;
        15) update_telegram ;;
        16) add_domain ;;
        17) remove_domain ;;
        18) run_diagnostics ;;
        19) fix_issues ;;
        20) clean_docker ;;
        0) echo -e "${GREEN}👋 Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}❌ Invalid option${NC}"; sleep 1 ;;
    esac
done
EOF

    chmod +x "$INSTALL_DIR/management/menu.sh"
    
    success "Đã tạo Management Menu"
}

# =============================================================================
# ADVANCED BACKUP SYSTEM
# =============================================================================

create_advanced_backup_system() {
    log "💾 Tạo Advanced Backup System..."
    
    # Enhanced backup script with ZIP and multi-domain support
    cat > "$INSTALL_DIR/backup-workflows.sh" << 'EOF'
#!/bin/bash

# =============================================================================
# N8N ADVANCED BACKUP SCRIPT - Multi-Domain Support with ZIP
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

log "🔄 Bắt đầu Advanced Backup N8N Multi-Domain..."

# Detect N8N instances
N8N_CONTAINERS=$(docker ps --filter "name=n8n-container" --format "{{.Names}}")
INSTANCE_COUNT=$(echo "$N8N_CONTAINERS" | wc -l)

if [[ -z "$N8N_CONTAINERS" ]]; then
    error "Không tìm thấy N8N containers!"
    exit 1
fi

log "📊 Phát hiện $INSTANCE_COUNT N8N instances"

# Create instance directories
mkdir -p "$TEMP_DIR/instances"
mkdir -p "$TEMP_DIR/postgres"
mkdir -p "$TEMP_DIR/config"
mkdir -p "$TEMP_DIR/ssl"

# Backup each N8N instance
instance_num=1
for container in $N8N_CONTAINERS; do
    log "📋 Backup N8N Instance $instance_num ($container)..."
    
    instance_dir="$TEMP_DIR/instances/instance_$instance_num"
    mkdir -p "$instance_dir"
    
    # Get domain for this instance
    domain=$(docker inspect $container --format '{{range .Config.Env}}{{if contains "WEBHOOK_URL" .}}{{.}}{{end}}{{end}}' | cut -d'=' -f2 | sed 's|https://||' | sed 's|/||')
    
    # Export workflows via N8N CLI
    if docker exec $container which n8n &> /dev/null; then
        log "  📄 Export workflows for $domain..."
        docker exec $container n8n export:workflow --all --output=/tmp/workflows_$instance_num.json 2>/dev/null || true
        docker cp $container:/tmp/workflows_$instance_num.json "$instance_dir/workflows.json" 2>/dev/null || true
        
        # Export credentials
        docker exec $container n8n export:credentials --all --output=/tmp/credentials_$instance_num.json 2>/dev/null || true
        docker cp $container:/tmp/credentials_$instance_num.json "$instance_dir/credentials.json" 2>/dev/null || true
    fi
    
    # Backup database file (if SQLite)
    if docker exec $container test -f /home/node/.n8n/database.sqlite 2>/dev/null; then
        log "  💾 Backup SQLite database for $domain..."
        docker cp $container:/home/node/.n8n/database.sqlite "$instance_dir/database.sqlite" 2>/dev/null || true
    fi
    
    # Backup encryption key
    if docker exec $container test -f /home/node/.n8n/config 2>/dev/null; then
        log "  🔑 Backup encryption key for $domain..."
        docker cp $container:/home/node/.n8n/config "$instance_dir/config" 2>/dev/null || true
    fi
    
    # Create instance metadata
    cat > "$instance_dir/metadata.json" << EOL
{
    "instance_number": $instance_num,
    "container_name": "$container",
    "domain": "$domain",
    "backup_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "n8n_version": "$(docker exec $container n8n --version 2>/dev/null || echo 'unknown')",
    "database_type": "$(docker exec $container printenv DB_TYPE 2>/dev/null || echo 'sqlite')"
}
EOL
    
    instance_num=$((instance_num + 1))
done

# Backup PostgreSQL if available
if docker ps --filter "name=postgres-n8n" --format "{{.Names}}" | grep -q "postgres-n8n"; then
    log "🐘 Backup PostgreSQL databases..."
    
    # Backup main database
    docker exec postgres-n8n pg_dump -U n8n_user -d n8n_db > "$TEMP_DIR/postgres/dump_main.sql" 2>/dev/null || true
    
    # Backup instance databases
    for i in $(seq 1 10); do
        db_name="n8n_db_instance_$i"
        if docker exec postgres-n8n psql -U n8n_user -lqt | cut -d \| -f 1 | grep -qw "$db_name"; then
            log "  📊 Backup database: $db_name"
            docker exec postgres-n8n pg_dump -U n8n_user -d "$db_name" > "$TEMP_DIR/postgres/dump_instance_$i.sql" 2>/dev/null || true
        fi
    done
    
    # Backup PostgreSQL globals
    docker exec postgres-n8n pg_dumpall -U n8n_user -g > "$TEMP_DIR/postgres/globals.sql" 2>/dev/null || true
fi

# Backup configuration files
log "🔧 Backup configuration files..."
cd /home/n8n
cp docker-compose.yml "$TEMP_DIR/config/" 2>/dev/null || true
cp Caddyfile "$TEMP_DIR/config/" 2>/dev/null || true
cp telegram_config.txt "$TEMP_DIR/config/" 2>/dev/null || true

# Backup SSL certificates
if docker volume ls | grep -q "n8n_caddy_data"; then
    log "🔒 Backup SSL certificates..."
    docker run --rm -v n8n_caddy_data:/data -v "$TEMP_DIR/ssl":/backup alpine tar czf /backup/caddy_data.tar.gz -C /data . 2>/dev/null || true
fi

# Create comprehensive metadata
log "📊 Tạo backup metadata..."
cat > "$TEMP_DIR/backup_metadata.json" << EOL
{
    "backup_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "backup_name": "$BACKUP_NAME",
    "backup_type": "multi_domain_full",
    "server_info": {
        "hostname": "$(hostname)",
        "os": "$(lsb_release -d | cut -f2)",
        "kernel": "$(uname -r)",
        "docker_version": "$(docker --version)",
        "docker_compose_version": "$($DOCKER_COMPOSE --version)"
    },
    "instances": {
        "total_count": $INSTANCE_COUNT,
        "containers": [$(echo "$N8N_CONTAINERS" | sed 's/^/"/;s/$/"/;$!s/$/,/' | tr '\n' ' ')]
    },
    "database": {
        "type": "$(docker ps --filter "name=postgres-n8n" --format "{{.Names}}" | grep -q "postgres-n8n" && echo "postgresql" || echo "sqlite")",
        "postgresql_available": $(docker ps --filter "name=postgres-n8n" --format "{{.Names}}" | grep -q "postgres-n8n" && echo "true" || echo "false")
    },
    "components": {
        "news_api": $(docker ps --filter "name=news-api" --format "{{.Names}}" | grep -q "news-api" && echo "true" || echo "false"),
        "caddy_proxy": $(docker ps --filter "name=caddy-proxy" --format "{{.Names}}" | grep -q "caddy-proxy" && echo "true" || echo "false")
    },
    "backup_size_mb": 0,
    "files": {
        "instances": "$INSTANCE_COUNT directories",
        "postgres_dumps": "$(find $TEMP_DIR/postgres -name "*.sql" 2>/dev/null | wc -l) files",
        "config_files": "$(find $TEMP_DIR/config -type f 2>/dev/null | wc -l) files",
        "ssl_backup": "$(test -f $TEMP_DIR/ssl/caddy_data.tar.gz && echo "available" || echo "not_available")"
    }
}
EOL

# Create ZIP backup (preferred over tar.gz for better compression)
log "📦 Tạo file backup ZIP..."
cd /tmp
zip -r "$BACKUP_DIR/$BACKUP_NAME.zip" "$BACKUP_NAME/" -q

# Get backup size and update metadata
BACKUP_SIZE_BYTES=$(stat -c%s "$BACKUP_DIR/$BACKUP_NAME.zip")
BACKUP_SIZE_MB=$((BACKUP_SIZE_BYTES / 1024 / 1024))
BACKUP_SIZE_HUMAN=$(ls -lh "$BACKUP_DIR/$BACKUP_NAME.zip" | awk '{print $5}')

# Update metadata with actual size
sed -i "s/\"backup_size_mb\": 0/\"backup_size_mb\": $BACKUP_SIZE_MB/" "$TEMP_DIR/backup_metadata.json"

log "✅ Backup hoàn thành: $BACKUP_NAME.zip ($BACKUP_SIZE_HUMAN)"

# Cleanup temp directory
rm -rf "$TEMP_DIR"

# Keep only last 30 backups
log "🧹 Cleanup old backups..."
cd "$BACKUP_DIR"
ls -t n8n_backup_*.zip 2>/dev/null | tail -n +31 | xargs -r rm -f

# Send to Telegram if configured
TELEGRAM_SENT=false
if [[ -f "/home/n8n/telegram_config.txt" ]]; then
    source "/home/n8n/telegram_config.txt"
    
    if [[ -n "$TELEGRAM_BOT_TOKEN" && -n "$TELEGRAM_CHAT_ID" ]]; then
        log "📱 Gửi thông báo Telegram..."
        
        # Create detailed message
        MESSAGE="🔄 *N8N Multi-Domain Backup Completed*

📅 Date: $(date +'%Y-%m-%d %H:%M:%S')
📦 File: \`$BACKUP_NAME.zip\`
💾 Size: $BACKUP_SIZE_HUMAN
🌐 Instances: $INSTANCE_COUNT N8N instances
🐘 Database: $(docker ps --filter "name=postgres-n8n" --format "{{.Names}}" | grep -q "postgres-n8n" && echo "PostgreSQL" || echo "SQLite")
📊 Status: ✅ Success

🗂️ Backup location: \`$BACKUP_DIR\`
🔄 Auto-cleanup: Keep 30 latest backups

📋 *Instance Details:*"

        # Add instance details
        instance_num=1
        for container in $N8N_CONTAINERS; do
            domain=$(docker inspect $container --format '{{range .Config.Env}}{{if contains "WEBHOOK_URL" .}}{{.}}{{end}}{{end}}' | cut -d'=' -f2 | sed 's|https://||' | sed 's|/||')
            MESSAGE="$MESSAGE
• Instance $instance_num: \`$domain\`"
            instance_num=$((instance_num + 1))
        done

        # Send message
        if curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
            -d chat_id="$TELEGRAM_CHAT_ID" \
            -d text="$MESSAGE" \
            -d parse_mode="Markdown" > /dev/null; then
            
            # Send file if smaller than 50MB (Telegram limit)
            if [[ $BACKUP_SIZE_BYTES -lt 52428800 ]]; then
                if curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendDocument" \
                    -F chat_id="$TELEGRAM_CHAT_ID" \
                    -F document="@$BACKUP_DIR/$BACKUP_NAME.zip" \
                    -F caption="📦 N8N Multi-Domain Backup: $BACKUP_NAME.zip" > /dev/null; then
                    TELEGRAM_SENT=true
                    log "✅ Backup file sent to Telegram"
                else
                    warning "⚠️ Failed to send backup file to Telegram (file sent notification only)"
                fi
            else
                warning "⚠️ Backup file too large for Telegram (>50MB), notification sent only"
            fi
        else
            warning "⚠️ Failed to send Telegram notification"
        fi
    fi
fi

# Final summary
log "🎉 Advanced Backup Process Completed!"
log "📊 Summary:"
log "   • Instances backed up: $INSTANCE_COUNT"
log "   • Backup size: $BACKUP_SIZE_HUMAN"
log "   • Telegram sent: $([ "$TELEGRAM_SENT" = true ] && echo "✅ Yes" || echo "❌ No")"
log "   • Location: $BACKUP_DIR/$BACKUP_NAME.zip"

# Create backup report
cat > "$BACKUP_DIR/latest_backup_report.txt" << EOL
N8N Multi-Domain Backup Report
==============================
Date: $(date +'%Y-%m-%d %H:%M:%S')
Backup File: $BACKUP_NAME.zip
Size: $BACKUP_SIZE_HUMAN ($BACKUP_SIZE_MB MB)
Instances: $INSTANCE_COUNT
Database: $(docker ps --filter "name=postgres-n8n" --format "{{.Names}}" | grep -q "postgres-n8n" && echo "PostgreSQL" || echo "SQLite")
Telegram: $([ "$TELEGRAM_SENT" = true ] && echo "Sent" || echo "Failed/Not configured")
Status: Success

Instance Details:
$(instance_num=1; for container in $N8N_CONTAINERS; do domain=$(docker inspect $container --format '{{range .Config.Env}}{{if contains "WEBHOOK_URL" .}}{{.}}{{end}}{{end}}' | cut -d'=' -f2 | sed 's|https://||' | sed 's|/||'); echo "• Instance $instance_num: $domain"; instance_num=$((instance_num + 1)); done)

Backup Contents:
• N8N workflows and credentials for all instances
• Database dumps (PostgreSQL/SQLite)
• Configuration files (docker-compose.yml, Caddyfile)
• SSL certificates
• Instance metadata

Location: $BACKUP_DIR/$BACKUP_NAME.zip
EOL

log "📋 Backup report saved: $BACKUP_DIR/latest_backup_report.txt"
EOF

    chmod +x "$INSTALL_DIR/backup-workflows.sh"
    
    success "Đã tạo Advanced Backup System với ZIP support"
}

create_restore_system() {
    log "🔄 Tạo Restore System..."
    
    cat > "$INSTALL_DIR/management/restore.sh" << 'EOF'
#!/bin/bash

# =============================================================================
# N8N RESTORE SYSTEM - Multi-Domain Support
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

if [[ $# -ne 1 ]]; then
    error "Usage: $0 <backup_file.zip>"
    exit 1
fi

BACKUP_FILE="$1"
RESTORE_DIR="/tmp/n8n_restore_$(date +%s)"

if [[ ! -f "$BACKUP_FILE" ]]; then
    error "Backup file not found: $BACKUP_FILE"
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

log "🔄 Starting N8N Multi-Domain Restore Process..."
log "📦 Backup file: $(basename "$BACKUP_FILE")"

# Create restore directory
mkdir -p "$RESTORE_DIR"
cd "$RESTORE_DIR"

# Extract backup
log "📂 Extracting backup file..."
if [[ "$BACKUP_FILE" == *.zip ]]; then
    unzip -q "$BACKUP_FILE"
elif [[ "$BACKUP_FILE" == *.tar.gz ]]; then
    tar -xzf "$BACKUP_FILE"
else
    error "Unsupported backup format. Use .zip or .tar.gz"
    exit 1
fi

# Find backup directory
BACKUP_DIR=$(find . -maxdepth 1 -type d -name "n8n_backup_*" | head -1)
if [[ -z "$BACKUP_DIR" ]]; then
    error "Invalid backup structure"
    exit 1
fi

cd "$BACKUP_DIR"

# Read metadata
if [[ -f "backup_metadata.json" ]]; then
    log "📊 Reading backup metadata..."
    BACKUP_DATE=$(jq -r '.backup_date' backup_metadata.json 2>/dev/null || echo "unknown")
    INSTANCE_COUNT=$(jq -r '.instances.total_count' backup_metadata.json 2>/dev/null || echo "unknown")
    DATABASE_TYPE=$(jq -r '.database.type' backup_metadata.json 2>/dev/null || echo "unknown")
    
    info "Backup Date: $BACKUP_DATE"
    info "Instances: $INSTANCE_COUNT"
    info "Database: $DATABASE_TYPE"
else
    warning "No metadata found, proceeding with basic restore"
fi

# Confirm restore
echo ""
warning "⚠️  This will REPLACE all current N8N data!"
warning "⚠️  Make sure you have a current backup before proceeding!"
echo ""
read -p "Continue with restore? (type 'YES' to confirm): " confirm

if [[ "$confirm" != "YES" ]]; then
    error "Restore cancelled"
    exit 1
fi

# Stop all services
log "🛑 Stopping all N8N services..."
cd /home/n8n
$DOCKER_COMPOSE down

# Restore configuration files
if [[ -d "$RESTORE_DIR/$BACKUP_DIR/config" ]]; then
    log "🔧 Restoring configuration files..."
    
    if [[ -f "$RESTORE_DIR/$BACKUP_DIR/config/docker-compose.yml" ]]; then
        cp "$RESTORE_DIR/$BACKUP_DIR/config/docker-compose.yml" /home/n8n/
        info "Restored docker-compose.yml"
    fi
    
    if [[ -f "$RESTORE_DIR/$BACKUP_DIR/config/Caddyfile" ]]; then
        cp "$RESTORE_DIR/$BACKUP_DIR/config/Caddyfile" /home/n8n/
        info "Restored Caddyfile"
    fi
    
    if [[ -f "$RESTORE_DIR/$BACKUP_DIR/config/telegram_config.txt" ]]; then
        cp "$RESTORE_DIR/$BACKUP_DIR/config/telegram_config.txt" /home/n8n/
        info "Restored Telegram config"
    fi
fi

# Restore SSL certificates
if [[ -f "$RESTORE_DIR/$BACKUP_DIR/ssl/caddy_data.tar.gz" ]]; then
    log "🔒 Restoring SSL certificates..."
    
    # Remove existing SSL data
    docker volume rm n8n_caddy_data n8n_caddy_config 2>/dev/null || true
    
    # Create new volume and restore data
    docker volume create n8n_caddy_data
    docker run --rm -v n8n_caddy_data:/data -v "$RESTORE_DIR/$BACKUP_DIR/ssl":/backup alpine tar xzf /backup/caddy_data.tar.gz -C /data
    info "Restored SSL certificates"
fi

# Restore PostgreSQL databases
if [[ -d "$RESTORE_DIR/$BACKUP_DIR/postgres" && "$DATABASE_TYPE" == "postgresql" ]]; then
    log "🐘 Restoring PostgreSQL databases..."
    
    # Start PostgreSQL first
    $DOCKER_COMPOSE up -d postgres
    sleep 30
    
    # Restore main database
    if [[ -f "$RESTORE_DIR/$BACKUP_DIR/postgres/dump_main.sql" ]]; then
        docker exec -i postgres-n8n psql -U n8n_user -d n8n_db < "$RESTORE_DIR/$BACKUP_DIR/postgres/dump_main.sql"
        info "Restored main database"
    fi
    
    # Restore instance databases
    for dump_file in "$RESTORE_DIR/$BACKUP_DIR/postgres"/dump_instance_*.sql; do
        if [[ -f "$dump_file" ]]; then
            instance_num=$(basename "$dump_file" | sed 's/dump_instance_//' | sed 's/.sql//')
            db_name="n8n_db_instance_$instance_num"
            
            # Create database if not exists
            docker exec postgres-n8n psql -U n8n_user -d n8n_db -c "CREATE DATABASE $db_name;" 2>/dev/null || true
            
            # Restore data
            docker exec -i postgres-n8n psql -U n8n_user -d "$db_name" < "$dump_file"
            info "Restored database: $db_name"
        fi
    done
fi

# Restore N8N instances
if [[ -d "$RESTORE_DIR/$BACKUP_DIR/instances" ]]; then
    log "🚀 Restoring N8N instances..."
    
    for instance_dir in "$RESTORE_DIR/$BACKUP_DIR/instances"/instance_*; do
        if [[ -d "$instance_dir" ]]; then
            instance_num=$(basename "$instance_dir" | sed 's/instance_//')
            target_dir="/home/n8n/files/n8n_instance_$instance_num"
            
            # Create target directory
            mkdir -p "$target_dir"
            
            # Restore workflows
            if [[ -f "$instance_dir/workflows.json" ]]; then
                cp "$instance_dir/workflows.json" "$target_dir/"
                info "Restored workflows for instance $instance_num"
            fi
            
            # Restore credentials
            if [[ -f "$instance_dir/credentials.json" ]]; then
                cp "$instance_dir/credentials.json" "$target_dir/"
                info "Restored credentials for instance $instance_num"
            fi
            
            # Restore SQLite database (if using SQLite)
            if [[ -f "$instance_dir/database.sqlite" && "$DATABASE_TYPE" != "postgresql" ]]; then
                cp "$instance_dir/database.sqlite" "$target_dir/"
                info "Restored SQLite database for instance $instance_num"
            fi
            
            # Restore config
            if [[ -f "$instance_dir/config" ]]; then
                cp "$instance_dir/config" "$target_dir/"
                info "Restored config for instance $instance_num"
            fi
        fi
    done
fi

# Fix permissions
log "🔧 Fixing permissions..."
chown -R 1000:1000 /home/n8n/files/

# Start all services
log "🚀 Starting all services..."
$DOCKER_COMPOSE up -d

# Wait for services to start
log "⏳ Waiting for services to start..."
sleep 60

# Import workflows and credentials
if [[ -d "$RESTORE_DIR/$BACKUP_DIR/instances" ]]; then
    log "📥 Importing workflows and credentials..."
    
    # Wait a bit more for N8N to be fully ready
    sleep 30
    
    for instance_dir in "$RESTORE_DIR/$BACKUP_DIR/instances"/instance_*; do
        if [[ -d "$instance_dir" ]]; then
            instance_num=$(basename "$instance_dir" | sed 's/instance_//')
            container_name="n8n-container-$instance_num"
            
            # Check if container exists
            if docker ps --format "{{.Names}}" | grep -q "$container_name"; then
                # Import workflows
                if [[ -f "$instance_dir/workflows.json" ]]; then
                    docker cp "$instance_dir/workflows.json" "$container_name:/tmp/"
                    docker exec "$container_name" n8n import:workflow --input=/tmp/workflows.json 2>/dev/null || warning "Failed to import workflows for instance $instance_num"
                fi
                
                # Import credentials
                if [[ -f "$instance_dir/credentials.json" ]]; then
                    docker cp "$instance_dir/credentials.json" "$container_name:/tmp/"
                    docker exec "$container_name" n8n import:credentials --input=/tmp/credentials.json 2>/dev/null || warning "Failed to import credentials for instance $instance_num"
                fi
                
                info "Imported data for instance $instance_num"
            else
                warning "Container $container_name not found"
            fi
        fi
    done
fi

# Cleanup
log "🧹 Cleaning up..."
rm -rf "$RESTORE_DIR"

# Final status check
log "🔍 Checking service status..."
sleep 10
$DOCKER_COMPOSE ps

log "✅ Restore process completed!"
log "🌐 Please check your domains to ensure everything is working correctly"

# Send Telegram notification if configured
if [[ -f "/home/n8n/telegram_config.txt" ]]; then
    source "/home/n8n/telegram_config.txt"
    
    if [[ -n "$TELEGRAM_BOT_TOKEN" && -n "$TELEGRAM_CHAT_ID" ]]; then
        MESSAGE="🔄 *N8N Restore Completed*

📅 Date: $(date +'%Y-%m-%d %H:%M:%S')
📦 Restored from: $(basename "$BACKUP_FILE")
🌐 Instances: $INSTANCE_COUNT
🐘 Database: $DATABASE_TYPE
📊 Status: ✅ Success

🔍 Please verify all domains are working correctly."

        curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
            -d chat_id="$TELEGRAM_CHAT_ID" \
            -d text="$MESSAGE" \
            -d parse_mode="Markdown" > /dev/null || true
    fi
fi

echo ""
log "🎉 N8N Multi-Domain Restore completed successfully!"
EOF

    chmod +x "$INSTALL_DIR/management/restore.sh"
    
    success "Đã tạo Restore System"
}

create_migration_tools() {
    log "🚚 Tạo Migration Tools..."
    
    cat > "$INSTALL_DIR/management/export-migration.sh" << 'EOF'
#!/bin/bash

# =============================================================================
# N8N MIGRATION EXPORT TOOL
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

MIGRATION_DIR="/home/n8n/files/migration"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
EXPORT_NAME="n8n_migration_$TIMESTAMP"

log "🚚 N8N Migration Export Tool"
log "📦 Creating migration package..."

# Create migration directory
mkdir -p "$MIGRATION_DIR"
cd "$MIGRATION_DIR"

# Create export directory
mkdir -p "$EXPORT_NAME"
cd "$EXPORT_NAME"

# Create directories
mkdir -p {instances,config,docs,scripts}

# Export current configuration
log "🔧 Exporting configuration..."
cp /home/n8n/docker-compose.yml config/ 2>/dev/null || true
cp /home/n8n/Caddyfile config/ 2>/dev/null || true
cp /home/n8n/telegram_config.txt config/ 2>/dev/null || true

# Export N8N instances data
log "🚀 Exporting N8N instances..."
N8N_CONTAINERS=$(docker ps --filter "name=n8n-container" --format "{{.Names}}")

instance_num=1
for container in $N8N_CONTAINERS; do
    log "  📋 Exporting instance $instance_num ($container)..."
    
    instance_dir="instances/instance_$instance_num"
    mkdir -p "$instance_dir"
    
    # Get domain
    domain=$(docker inspect $container --format '{{range .Config.Env}}{{if contains "WEBHOOK_URL" .}}{{.}}{{end}}{{end}}' | cut -d'=' -f2 | sed 's|https://||' | sed 's|/||')
    
    # Export workflows
    docker exec $container n8n export:workflow --all --output=/tmp/workflows_export.json 2>/dev/null || true
    docker cp $container:/tmp/workflows_export.json "$instance_dir/workflows.json" 2>/dev/null || true
    
    # Export credentials
    docker exec $container n8n export:credentials --all --output=/tmp/credentials_export.json 2>/dev/null || true
    docker cp $container:/tmp/credentials_export.json "$instance_dir/credentials.json" 2>/dev/null || true
    
    # Create instance info
    cat > "$instance_dir/instance_info.json" << EOL
{
    "instance_number": $instance_num,
    "domain": "$domain",
    "container_name": "$container",
    "export_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "n8n_version": "$(docker exec $container n8n --version 2>/dev/null || echo 'unknown')"
}
EOL
    
    instance_num=$((instance_num + 1))
done

# Export database schema (PostgreSQL)
if docker ps --filter "name=postgres-n8n" --format "{{.Names}}" | grep -q "postgres-n8n"; then
    log "🐘 Exporting PostgreSQL schema..."
    mkdir -p database
    
    # Export schema only (no data)
    docker exec postgres-n8n pg_dump -U n8n_user -d n8n_db --schema-only > database/schema.sql 2>/dev/null || true
    
    # Export database list
    docker exec postgres-n8n psql -U n8n_user -l > database/database_list.txt 2>/dev/null || true
fi

# Create migration documentation
log "📚 Creating migration documentation..."

cat > docs/MIGRATION_GUIDE.md << 'EOL'
# N8N Migration Guide

## Overview
This package contains all necessary files to migrate your N8N multi-domain setup to a new server.

## Package Contents
- `instances/` - N8N workflows and credentials for each instance
- `config/` - Configuration files (docker-compose.yml, Caddyfile, etc.)
- `database/` - Database schema (if using PostgreSQL)
- `scripts/` - Helper scripts for migration
- `docs/` - This documentation

## Migration Steps

### 1. Prepare New Server
```bash
# Install Ubuntu 20.04+ on new server
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose -y
```

### 2. Setup DNS
Point all your domains to the new server IP:
- Update A records for all domains
- Wait for DNS propagation (5-60 minutes)

### 3. Transfer Files
```bash
# Copy this migration package to new server
scp -r n8n_migration_* user@new-server:/tmp/

# Or use the installation script with restore option
```

### 4. Install N8N
```bash
# Download and run installation script
curl -sSL https://raw.githubusercontent.com/KalvinThien/install-n8n-ffmpeg/main/auto_cai_dat_n8n.sh | bash

# Or use migration restore script
sudo ./scripts/migrate-restore.sh
```

### 5. Restore Data
```bash
# Use the restore script provided
sudo /home/n8n/management/restore.sh /path/to/backup.zip

# Or manually import workflows
docker exec n8n-container-1 n8n import:workflow --input=/tmp/workflows.json
```

### 6. Verify Migration
- Check all domains are accessible
- Verify workflows are working
- Test webhooks and integrations
- Confirm SSL certificates are issued

## Important Notes
- Backup current server before migration
- Test migration on staging environment first
- Update webhook URLs if domain changes
- Reconfigure any external integrations
- Update DNS TTL to low value before migration

## Troubleshooting
- Check Docker logs: `docker-compose logs -f`
- Verify DNS: `dig yourdomain.com`
- Test SSL: `curl -I https://yourdomain.com`
- Run diagnostics: `/home/n8n/troubleshoot.sh`

## Support
- GitHub: https://github.com/KalvinThien/install-n8n-ffmpeg
- YouTube: https://www.youtube.com/@kalvinthiensocial
- Zalo: 08.8888.4749
EOL

# Create migration restore script
cat > scripts/migrate-restore.sh << 'EOL'
#!/bin/bash

# N8N Migration Restore Script
# This script helps restore N8N from migration package

set -e

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

MIGRATION_DIR="$(dirname "$(readlink -f "$0")")/.."

echo "🚚 N8N Migration Restore"
echo "📂 Migration directory: $MIGRATION_DIR"

# Check if N8N is already installed
if [[ -d "/home/n8n" ]]; then
    echo "⚠️  N8N installation detected at /home/n8n"
    read -p "Continue and overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install N8N first if not exists
if [[ ! -d "/home/n8n" ]]; then
    echo "📦 Installing N8N first..."
    curl -sSL https://raw.githubusercontent.com/KalvinThien/install-n8n-ffmpeg/main/auto_cai_dat_n8n.sh | bash
fi

# Restore configuration
if [[ -d "$MIGRATION_DIR/config" ]]; then
    echo "🔧 Restoring configuration..."
    cp "$MIGRATION_DIR/config"/* /home/n8n/ 2>/dev/null || true
fi

# Restore instances
if [[ -d "$MIGRATION_DIR/instances" ]]; then
    echo "🚀 Restoring N8N instances..."
    
    for instance_dir in "$MIGRATION_DIR/instances"/instance_*; do
        if [[ -d "$instance_dir" ]]; then
            instance_num=$(basename "$instance_dir" | sed 's/instance_//')
            target_dir="/home/n8n/files/n8n_instance_$instance_num"
            
            mkdir -p "$target_dir"
            cp "$instance_dir"/* "$target_dir/" 2>/dev/null || true
            
            echo "  ✅ Restored instance $instance_num"
        fi
    done
fi

# Fix permissions
chown -R 1000:1000 /home/n8n/files/

# Restart services
cd /home/n8n
docker-compose restart

echo "✅ Migration restore completed!"
echo "🔍 Please verify all domains are working correctly"
EOL

chmod +x scripts/migrate-restore.sh

# Create server comparison script
cat > scripts/compare-servers.sh << 'EOL'
#!/bin/bash

# Server Comparison Tool
echo "🔍 Server Comparison Tool"
echo "========================"

echo "Current Server Info:"
echo "• OS: $(lsb_release -d | cut -f2)"
echo "• Kernel: $(uname -r)"
echo "• Docker: $(docker --version)"
echo "• Memory: $(free -h | grep Mem | awk '{print $2}')"
echo "• Disk: $(df -h / | tail -1 | awk '{print $2}')"
echo "• CPU: $(nproc) cores"

echo ""
echo "N8N Installation:"
echo "• Instances: $(docker ps --filter "name=n8n-container" --format "{{.Names}}" | wc -l)"
echo "• Database: $(docker ps --filter "name=postgres-n8n" --format "{{.Names}}" | grep -q "postgres-n8n" && echo "PostgreSQL" || echo "SQLite")"
echo "• News API: $(docker ps --filter "name=news-api" --format "{{.Names}}" | grep -q "news-api" && echo "Enabled" || echo "Disabled")"

echo ""
echo "Domains:"
grep -E "^[a-zA-Z0-9.-]+\s*{" /home/n8n/Caddyfile | awk '{print "• " $1}'

echo ""
echo "Recommended New Server Specs:"
echo "• OS: Ubuntu 20.04+ LTS"
echo "• Memory: 4GB+ RAM (for multi-domain)"
echo "• Disk: 50GB+ SSD"
echo "• CPU: 2+ cores"
echo "• Network: 1Gbps+"
EOL

chmod +x scripts/compare-servers.sh

# Create migration metadata
cat > migration_metadata.json << EOL
{
    "export_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "export_name": "$EXPORT_NAME",
    "source_server": {
        "hostname": "$(hostname)",
        "os": "$(lsb_release -d | cut -f2)",
        "kernel": "$(uname -r)",
        "docker_version": "$(docker --version)",
        "ip_address": "$(curl -s https://api.ipify.org || echo 'unknown')"
    },
    "n8n_setup": {
        "instances": $(docker ps --filter "name=n8n-container" --format "{{.Names}}" | wc -l),
        "database_type": "$(docker ps --filter "name=postgres-n8n" --format "{{.Names}}" | grep -q "postgres-n8n" && echo "postgresql" || echo "sqlite")",
        "news_api": $(docker ps --filter "name=news-api" --format "{{.Names}}" | grep -q "news-api" && echo "true" || echo "false"),
        "domains": [$(grep -E "^[a-zA-Z0-9.-]+\s*{" /home/n8n/Caddyfile | awk '{print "\"" $1 "\""}' | paste -sd,)]
    },
    "migration_package_size": "0MB",
    "instructions": "See docs/MIGRATION_GUIDE.md for detailed migration steps"
}
EOL

# Create ZIP package
cd "$MIGRATION_DIR"
log "📦 Creating migration package..."
zip -r "$EXPORT_NAME.zip" "$EXPORT_NAME/" -q

# Get package size
PACKAGE_SIZE=$(ls -lh "$EXPORT_NAME.zip" | awk '{print $5}')
sed -i "s/\"migration_package_size\": \"0MB\"/\"migration_package_size\": \"$PACKAGE_SIZE\"/" "$EXPORT_NAME/migration_metadata.json"

# Update ZIP with new metadata
zip -u "$EXPORT_NAME.zip" "$EXPORT_NAME/migration_metadata.json" -q

# Cleanup
rm -rf "$EXPORT_NAME"

log "✅ Migration package created: $MIGRATION_DIR/$EXPORT_NAME.zip"
log "📊 Package size: $PACKAGE_SIZE"
log "📚 See included documentation for migration steps"

echo ""
echo -e "${BLUE}📋 Migration Package Contents:${NC}"
echo "• Complete N8N configuration"
echo "• All workflows and credentials"
echo "• Database schema"
echo "• Migration scripts"
echo "• Detailed documentation"
echo ""
echo -e "${GREEN}📦 Package location: $MIGRATION_DIR/$EXPORT_NAME.zip${NC}"
echo -e "${YELLOW}📚 Read docs/MIGRATION_GUIDE.md for migration steps${NC}"
EOF

    chmod +x "$INSTALL_DIR/management/export-migration.sh"
    
    success "Đã tạo Migration Tools"
}

# =============================================================================
# BACKUP SYSTEM
# =============================================================================

create_backup_scripts() {
    create_advanced_backup_system
    
    # Manual backup test script
    cat > "$INSTALL_DIR/backup-manual.sh" << 'EOF'
#!/bin/bash

echo "🧪 MANUAL BACKUP TEST - Multi-Domain"
echo "===================================="
echo ""

cd /home/n8n

echo "📋 Thông tin hệ thống:"
echo "• Thời gian: $(date)"
echo "• N8N Instances: $(docker ps --filter "name=n8n-container" --format "{{.Names}}" | wc -l)"
echo "• Database: $(docker ps --filter "name=postgres-n8n" --format "{{.Names}}" | grep -q "postgres-n8n" && echo "PostgreSQL" || echo "SQLite")"
echo "• Disk usage: $(df -h /home/n8n | tail -1 | awk '{print $5}')"
echo "• Memory: $(free -h | grep Mem | awk '{print $3"/"$2}')"
echo ""

echo "🔄 Chạy advanced backup test..."
./backup-workflows.sh

echo ""
echo "📊 Kết quả backup:"
ls -lah /home/n8n/files/backup_full/n8n_backup_*.zip | tail -5

echo ""
echo "📋 Latest backup report:"
if [[ -f "/home/n8n/files/backup_full/latest_backup_report.txt" ]]; then
    cat /home/n8n/files/backup_full/latest_backup_report.txt
fi

echo ""
echo "✅ Manual backup test completed!"
EOF

    chmod +x "$INSTALL_DIR/backup-manual.sh"
    
    success "Đã tạo Backup Scripts"
}

create_update_script() {
    if [[ "$ENABLE_AUTO_UPDATE" != "true" ]]; then
        return 0
    fi
    
    log "🔄 Tạo script auto-update..."
    
    cat > "$INSTALL_DIR/update-n8n.sh" << 'EOF'
#!/bin/bash

# =============================================================================
# N8N AUTO-UPDATE SCRIPT - Multi-Domain Support
# =============================================================================

set -e

LOG_FILE="/home/n8n/logs/update.log"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$TIMESTAMP] $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[$TIMESTAMP] [ERROR] $1${NC}" | tee -a "$LOG_FILE"
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

cd /home/n8n

log "🔄 Bắt đầu auto-update N8N Multi-Domain..."

# Get N8N instances
N8N_CONTAINERS=$(docker ps --filter "name=n8n-container" --format "{{.Names}}")
INSTANCE_COUNT=$(echo "$N8N_CONTAINERS" | wc -l)

log "📊 Phát hiện $INSTANCE_COUNT N8N instances"

# Backup before update
log "💾 Backup trước khi update..."
./backup-workflows.sh

# Pull latest images
log "📦 Pull latest Docker images..."
$DOCKER_COMPOSE pull

# Update yt-dlp in all N8N containers
log "📺 Update yt-dlp trong tất cả containers..."
for container in $N8N_CONTAINERS; do
    log "  🔄 Updating yt-dlp in $container..."
    docker exec $container pip3 install --break-system-packages -U yt-dlp || true
done

# Restart services
log "🔄 Restart services..."
$DOCKER_COMPOSE up -d

# Wait for services to be ready
log "⏳ Đợi services khởi động..."
sleep 60

# Check if all services are running
log "🔍 Kiểm tra trạng thái services..."

all_healthy=true

# Check N8N instances
for container in $N8N_CONTAINERS; do
    if docker ps | grep -q "$container"; then
        log "✅ $container đang chạy"
    else
        error "❌ $container không chạy"
        all_healthy=false
    fi
done

# Check other services
if docker ps | grep -q "caddy-proxy"; then
    log "✅ Caddy proxy đang chạy"
else
    error "❌ Caddy proxy không chạy"
    all_healthy=false
fi

if docker ps | grep -q "postgres-n8n"; then
    log "✅ PostgreSQL đang chạy"
elif docker ps | grep -q "news-api"; then
    log "✅ News API đang chạy"
fi

# Send Telegram notification if configured
if [[ -f "/home/n8n/telegram_config.txt" ]]; then
    source "/home/n8n/telegram_config.txt"
    
    if [[ -n "$TELEGRAM_BOT_TOKEN" && -n "$TELEGRAM_CHAT_ID" ]]; then
        STATUS_ICON="✅"
        STATUS_TEXT="Success"
        
        if [[ "$all_healthy" != "true" ]]; then
            STATUS_ICON="⚠️"
            STATUS_TEXT="Warning - Some services may have issues"
        fi
        
        MESSAGE="🔄 *N8N Multi-Domain Auto-Update*

📅 Date: $TIMESTAMP
🌐 Instances: $INSTANCE_COUNT N8N instances
$STATUS_ICON Status: $STATUS_TEXT

📦 Components updated:
• N8N Docker images
• yt-dlp (all instances)
• System dependencies

🔍 All services status checked
💾 Backup completed before update"

        curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
            -d chat_id="$TELEGRAM_CHAT_ID" \
            -d text="$MESSAGE" \
            -d parse_mode="Markdown" > /dev/null || true
    fi
fi

if [[ "$all_healthy" == "true" ]]; then
    log "🎉 Auto-update completed successfully!"
else
    error "⚠️ Auto-update completed with warnings - check logs"
fi
EOF

    chmod +x "$INSTALL_DIR/update-n8n.sh"
    
    success "Đã tạo script auto-update với Multi-Domain support"
}

# =============================================================================
# TELEGRAM CONFIGURATION
# =============================================================================

setup_telegram_config() {
    if [[ "$ENABLE_TELEGRAM" != "true" ]]; then
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
            domain_list="$domain_list• Instance $((i+1)): ${DOMAINS[i]}\n"
        done
    else
        domain_list="• Main domain: ${DOMAINS[0]}\n"
    fi
    
    TEST_MESSAGE="🚀 *N8N Multi-Domain Installation Completed*

📅 Date: $(date +'%Y-%m-%d %H:%M:%S')
🌐 Domains configured:
$domain_list
📰 API Domain: $([[ "$ENABLE_NEWS_API" == "true" ]] && echo "$API_DOMAIN" || echo "Disabled")
🐘 Database: $([[ "$ENABLE_POSTGRESQL" == "true" ]] && echo "PostgreSQL" || echo "SQLite")
💾 Backup: Enabled with ZIP compression
🔄 Auto-update: $([[ "$ENABLE_AUTO_UPDATE" == "true" ]] && echo "Enabled" || echo "Disabled")

✅ Multi-Domain system is ready!"

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
    
    # Add backup job (daily at 2:00 AM)
    (crontab -l 2>/dev/null; echo "0 2 * * * /home/n8n/backup-workflows.sh") | crontab -
    
    # Add auto-update job if enabled
    if [[ "$ENABLE_AUTO_UPDATE" == "true" ]]; then
        (crontab -l 2>/dev/null; echo "0 */12 * * * /home/n8n/update-n8n.sh") | crontab -
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
        echo -e "  ${GREEN}1. CÀI LẠI UBUNTU (KHUYẾN NGHỊ):${NC}"
        echo -e "     • Cài lại Ubuntu Server hoàn toàn"
        echo -e "     • Sử dụng subdomain khác (vd: n8n2.domain.com)"
        echo -e "     • Chạy lại script này"
        echo ""
        echo -e "  ${GREEN}2. SỬ DỤNG STAGING SSL (TẠM THỜI):${NC}"
        echo -e "     • Website sẽ hiển thị 'Not Secure' nhưng vẫn hoạt động"
        echo -e "     • Chức năng N8N và API hoạt động đầy đủ"
        echo -e "     • Có thể chuyển về production SSL sau 29/06/2025"
        echo ""
        echo -e "  ${GREEN}3. ĐỢI ĐẾN TUẦN SAU:${NC}"
        echo -e "     • Đợi đến sau 29/06/2025 13:24 UTC"
        echo -e "     • Chạy lại script để cấp SSL mới"
        echo ""
        
        read -p "🤔 Bạn muốn tiếp tục với Staging SSL? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            setup_staging_ssl
        else
            echo ""
            echo -e "${CYAN}📋 HƯỚNG DẪN CÀI LẠI UBUNTU:${NC}"
            echo -e "  1. Backup dữ liệu quan trọng"
            echo -e "  2. Cài lại Ubuntu Server từ đầu"
            echo -e "  3. Sử dụng subdomain khác hoặc domain khác"
            echo -e "  4. Chạy lại script: curl -sSL https://raw.githubusercontent.com/KalvinThien/install-n8n-ffmpeg/main/auto_cai_dat_n8n.sh | bash"
            echo ""
            exit 1
        fi
    else
        # Test SSL for all domains
        sleep 60
        local ssl_success=true
        
        for domain in "${DOMAINS[@]}"; do
            if curl -I "https://$domain" &>/dev/null; then
                success "✅ SSL certificate cho $domain đã được cấp thành công"
            else
                warning "⚠️ SSL cho $domain có thể chưa sẵn sàng - đợi thêm vài phút"
                ssl_success=false
            fi
        done
        
        if [[ "$ENABLE_NEWS_API" == "true" ]]; then
            if curl -I "https://$API_DOMAIN" &>/dev/null; then
                success "✅ SSL certificate cho $API_DOMAIN đã được cấp thành công"
            else
                warning "⚠️ SSL cho $API_DOMAIN có thể chưa sẵn sàng - đợi thêm vài phút"
            fi
        fi
        
        if [[ "$ssl_success" == "true" ]]; then
            success "✅ Tất cả SSL certificates đã được cấp thành công"
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

    # Add all domains with staging SSL
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            local instance_num=$((i+1))
            
            cat >> "$INSTALL_DIR/Caddyfile" << EOF
${DOMAINS[i]} {
    reverse_proxy n8n_${instance_num}:5678
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
    }
    
    encode gzip
    
    log {
        output file /var/log/caddy/n8n_instance_${instance_num}.log
        format json
    }
}

EOF
        done
    else
        cat >> "$INSTALL_DIR/Caddyfile" << EOF
${DOMAINS[0]} {
    reverse_proxy n8n:5678
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
    }
    
    encode gzip
    
    log {
        output file /var/log/caddy/n8n.log
        format json
    }
}

EOF
    fi

    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        cat >> "$INSTALL_DIR/Caddyfile" << EOF
${API_DOMAIN} {
    reverse_proxy fastapi:8000
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
        Access-Control-Allow-Origin "*"
        Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
        Access-Control-Allow-Headers "Content-Type, Authorization"
    }
    
    encode gzip
    
    log {
        output file /var/log/caddy/api.log
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
# TROUBLESHOOTING SCRIPT
# =============================================================================

create_troubleshooting_script() {
    log "🔧 Tạo script chẩn đoán..."
    
    cat > "$INSTALL_DIR/troubleshoot.sh" << 'EOF'
#!/bin/bash

# =============================================================================
# N8N TROUBLESHOOTING SCRIPT - Multi-Domain Support
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
echo -e "${CYAN}║${WHITE}                🔧 N8N TROUBLESHOOTING SCRIPT - Multi-Domain                ${CYAN}║${NC}"
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
echo "• OS: $(lsb_release -d | cut -f2)"
echo "• Kernel: $(uname -r)"
echo "• Docker: $(docker --version)"
echo "• Docker Compose: $($DOCKER_COMPOSE --version)"
echo "• Disk Usage: $(df -h /home/n8n | tail -1 | awk '{print $5}')"
echo "• Memory: $(free -h | grep Mem | awk '{print $3"/"$2}')"
echo "• Swap: $(free -h | grep Swap | awk '{print $3"/"$2}')"
echo "• Uptime: $(uptime -p)"
echo ""

echo -e "${BLUE}📍 2. Container Status:${NC}"
$DOCKER_COMPOSE ps
echo ""

echo -e "${BLUE}📍 3. N8N Instances:${NC}"
N8N_CONTAINERS=$(docker ps --filter "name=n8n-container" --format "{{.Names}}")
INSTANCE_COUNT=$(echo "$N8N_CONTAINERS" | wc -l)

if [[ -z "$N8N_CONTAINERS" ]]; then
    echo -e "${RED}❌ Không tìm thấy N8N containers${NC}"
else
    echo "• Total instances: $INSTANCE_COUNT"
    
    instance_num=1
    for container in $N8N_CONTAINERS; do
        domain=$(docker inspect $container --format '{{range .Config.Env}}{{if contains "WEBHOOK_URL" .}}{{.}}{{end}}{{end}}' | cut -d'=' -f2 | sed 's|https://||' | sed 's|/||')
        status=$(docker inspect $container --format '{{.State.Status}}')
        
        echo "• Instance $instance_num: $container"
        echo "  - Domain: $domain"
        echo "  - Status: $status"
        echo "  - Health: $(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$((5677 + instance_num))" | grep -q "200\|302" && echo "✅ OK" || echo "❌ Error")"
        
        instance_num=$((instance_num + 1))
    done
fi
echo ""

echo -e "${BLUE}📍 4. Database Status:${NC}"
if docker ps --filter "name=postgres-n8n" --format "{{.Names}}" | grep -q "postgres-n8n"; then
    echo "• Type: PostgreSQL"
    echo "• Status: $(docker inspect postgres-n8n --format '{{.State.Status}}')"
    echo "• Connections: $(docker exec postgres-n8n psql -U n8n_user -d n8n_db -t -c "SELECT count(*) FROM pg_stat_activity;" 2>/dev/null | xargs || echo "Error")"
    echo "• Databases:"
    docker exec postgres-n8n psql -U n8n_user -l 2>/dev/null | grep "n8n_db" | while read line; do
        echo "  - $(echo $line | awk '{print $1}')"
    done
else
    echo "• Type: SQLite"
    echo "• Files:"
    find /home/n8n/files -name "database.sqlite" -exec ls -lh {} \; | while read line; do
        echo "  - $line"
    done
fi
echo ""

echo -e "${BLUE}📍 5. Docker Images:${NC}"
docker images | grep -E "(n8n|caddy|postgres|news-api)"
echo ""

echo -e "${BLUE}📍 6. Network Status:${NC}"
echo "• Port 80: $(netstat -tulpn 2>/dev/null | grep :80 | wc -l) connections"
echo "• Port 443: $(netstat -tulpn 2>/dev/null | grep :443 | wc -l) connections"
echo "• Docker Networks:"
docker network ls | grep n8n
echo ""

echo -e "${BLUE}📍 7. SSL Certificate Status:${NC}"
DOMAINS=$(grep -E "^[a-zA-Z0-9.-]+\s*{" Caddyfile | awk '{print $1}')
for domain in $DOMAINS; do
    echo -n "• $domain: "
    if timeout 10 curl -I https://$domain 2>/dev/null | head -1 | grep -q "200\|301\|302"; then
        echo -e "${GREEN}✅ SSL Active${NC}"
    else
        echo -e "${RED}❌ SSL Error${NC}"
    fi
done
echo ""

echo -e "${BLUE}📍 8. News API Status:${NC}"
if docker ps --filter "name=news-api" --format "{{.Names}}" | grep -q "news-api"; then
    echo "• Status: Running"
    API_DOMAIN=$(grep -E "^api\." Caddyfile | awk '{print $1}' | head -1)
    if [[ -n "$API_DOMAIN" ]]; then
        echo -n "• Health check: "
        if timeout 10 curl -s "https://$API_DOMAIN/health" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ OK${NC}"
        else
            echo -e "${RED}❌ Error${NC}"
        fi
    fi
else
    echo "• Status: Not enabled"
fi
echo ""

echo -e "${BLUE}📍 9. Backup Status:${NC}"
if [[ -d "/home/n8n/files/backup_full" ]]; then
    BACKUP_COUNT=$(ls -1 /home/n8n/files/backup_full/n8n_backup_*.zip 2>/dev/null | wc -l)
    echo "• Backup files: $BACKUP_COUNT"
    if [[ $BACKUP_COUNT -gt 0 ]]; then
        LATEST_BACKUP=$(ls -t /home/n8n/files/backup_full/n8n_backup_*.zip | head -1)
        echo "• Latest backup: $(basename "$LATEST_BACKUP")"
        echo "• Size: $(ls -lh "$LATEST_BACKUP" | awk '{print $5}')"
        echo "• Date: $(stat -c %y "$LATEST_BACKUP" | cut -d' ' -f1)"
    fi
else
    echo "• No backup directory found"
fi
echo ""

echo -e "${BLUE}📍 10. Recent Logs (last 10 lines):${NC}"
echo -e "${YELLOW}N8N Logs:${NC}"
$DOCKER_COMPOSE logs --tail=10 $(echo "$N8N_CONTAINERS" | head -1) 2>/dev/null || echo "No N8N logs"
echo ""
echo -e "${YELLOW}Caddy Logs:${NC}"
$DOCKER_COMPOSE logs --tail=10 caddy 2>/dev/null || echo "No Caddy logs"
echo ""

if docker ps | grep -q "postgres-n8n"; then
    echo -e "${YELLOW}PostgreSQL Logs:${NC}"
    $DOCKER_COMPOSE logs --tail=10 postgres 2>/dev/null || echo "No PostgreSQL logs"
    echo ""
fi

if docker ps | grep -q "news-api"; then
    echo -e "${YELLOW}News API Logs:${NC}"
    $DOCKER_COMPOSE logs --tail=10 fastapi 2>/dev/null || echo "No News API logs"
    echo ""
fi

echo -e "${BLUE}📍 11. Cron Jobs:${NC}"
crontab -l 2>/dev/null | grep -E "(n8n|backup)" || echo "• No N8N cron jobs found"
echo ""

echo -e "${GREEN}🔧 QUICK FIX COMMANDS:${NC}"
echo -e "${YELLOW}• Restart all services:${NC} cd /home/n8n && $DOCKER_COMPOSE restart"
echo -e "${YELLOW}• View live logs:${NC} cd /home/n8n && $DOCKER_COMPOSE logs -f"
echo -e "${YELLOW}• Rebuild containers:${NC} cd /home/n8n && $DOCKER_COMPOSE down && $DOCKER_COMPOSE up -d --build"
echo -e "${YELLOW}• Manual backup:${NC} /home/n8n/backup-manual.sh"
echo -e "${YELLOW}• Management menu:${NC} /home/n8n/management/menu.sh"
echo -e "${YELLOW}• Dashboard:${NC} /home/n8n/management/dashboard.sh"
echo ""

echo -e "${CYAN}✅ Multi-Domain Troubleshooting completed!${NC}"
EOF

    chmod +x "$INSTALL_DIR/troubleshoot.sh"
    
    success "Đã tạo script chẩn đoán với Multi-Domain support"
}

# =============================================================================
# FINAL SUMMARY
# =============================================================================

show_final_summary() {
    clear
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${WHITE}                🎉 N8N MULTI-DOMAIN ĐÃ ĐƯỢC CÀI ĐẶT THÀNH CÔNG!              ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}🌐 TRUY CẬP DỊCH VỤ:${NC}"
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            echo -e "  • N8N Instance $((i+1)): ${WHITE}https://${DOMAINS[i]}${NC}"
        done
    else
        echo -e "  • N8N: ${WHITE}https://${DOMAINS[0]}${NC}"
    fi
    
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        echo -e "  • News API: ${WHITE}https://${API_DOMAIN}${NC}"
        echo -e "  • API Docs: ${WHITE}https://${API_DOMAIN}/docs${NC}"
        echo -e "  • Bearer Token: ${YELLOW}Đã được đặt (không hiển thị vì bảo mật)${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}📊 THÔNG TIN HỆ THỐNG:${NC}"
    echo -e "  • Architecture: ${WHITE}Multi-Domain Support${NC}"
    echo -e "  • N8N Instances: ${WHITE}${#DOMAINS[@]} instances${NC}"
    echo -e "  • Database: ${WHITE}$([[ "$ENABLE_POSTGRESQL" == "true" ]] && echo "PostgreSQL (Shared)" || echo "SQLite (Per instance)")${NC}"
    echo -e "  • Thư mục cài đặt: ${WHITE}${INSTALL_DIR}${NC}"
    echo -e "  • Management Dashboard: ${WHITE}${INSTALL_DIR}/management/dashboard.sh${NC}"
    echo -e "  • Management Menu: ${WHITE}${INSTALL_DIR}/management/menu.sh${NC}"
    echo ""
    
    echo -e "${CYAN}💾 CẤU HÌNH BACKUP NÂNG CAO:${NC}"
    local swap_info=$(swapon --show | grep -v NAME | awk '{print $3}' | head -1)
    echo -e "  • Swap: ${WHITE}${swap_info:-"Không có"}${NC}"
    echo -e "  • Format: ${WHITE}ZIP compression (tối ưu)${NC}"
    echo -e "  • Multi-domain: ${WHITE}Backup tất cả instances cùng lúc${NC}"
    echo -e "  • Auto-update: ${WHITE}$([[ "$ENABLE_AUTO_UPDATE" == "true" ]] && echo "Enabled (mỗi 12h)" || echo "Disabled")${NC}"
    echo -e "  • Telegram backup: ${WHITE}$([[ "$ENABLE_TELEGRAM" == "true" ]] && echo "Enabled với detailed reports" || echo "Disabled")${NC}"
    echo -e "  • Backup tự động: ${WHITE}Hàng ngày lúc 2:00 AM${NC}"
    echo -e "  • Backup location: ${WHITE}${INSTALL_DIR}/files/backup_full/${NC}"
    echo ""
    
    echo -e "${CYAN}🛠️ QUẢN LÝ TẬP TRUNG:${NC}"
    echo -e "  • Dashboard: ${WHITE}${INSTALL_DIR}/management/dashboard.sh${NC}"
    echo -e "  • Management Menu: ${WHITE}${INSTALL_DIR}/management/menu.sh${NC}"
    echo -e "  • Troubleshooting: ${WHITE}${INSTALL_DIR}/troubleshoot.sh${NC}"
    echo -e "  • Manual Backup: ${WHITE}${INSTALL_DIR}/backup-manual.sh${NC}"
    echo -e "  • Migration Export: ${WHITE}${INSTALL_DIR}/management/export-migration.sh${NC}"
    echo ""
    
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        echo -e "${CYAN}🔧 ĐỔI BEARER TOKEN:${NC}"
        echo -e "  ${WHITE}cd /home/n8n && sed -i 's/NEWS_API_TOKEN=.*/NEWS_API_TOKEN=\"NEW_TOKEN\"/' docker-compose.yml && $DOCKER_COMPOSE restart fastapi${NC}"
        echo ""
    fi
    
    echo -e "${CYAN}🚚 MIGRATION & BACKUP:${NC}"
    echo -e "  • Export for migration: ${WHITE}${INSTALL_DIR}/management/export-migration.sh${NC}"
    echo -e "  • Restore from backup: ${WHITE}${INSTALL_DIR}/management/restore.sh backup_file.zip${NC}"
    echo -e "  • Backup format: ${WHITE}ZIP với metadata chi tiết${NC}"
    echo -e "  • Migration guide: ${WHITE}Included in export package${NC}"
    echo ""
    
    echo -e "${CYAN}🚀 TÁC GIẢ:${NC}"
    echo -e "  • Tên: ${WHITE}Nguyễn Ngọc Thiện${NC}"
    echo -e "  • YouTube: ${WHITE}https://www.youtube.com/@kalvinthiensocial?sub_confirmation=1${NC}"
    echo -e "  • Zalo: ${WHITE}08.8888.4749${NC}"
    echo -e "  • Version: ${WHITE}3.0 - Multi-Domain + Advanced Management${NC}"
    echo -e "  • Cập nhật: ${WHITE}28/06/2025${NC}"
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
    
    # Get user input
    get_domain_input
    get_cleanup_option
    get_postgresql_config
    get_news_api_config
    get_telegram_config
    get_auto_update_config
    
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
    create_postgresql_init_script
    create_news_api
    create_docker_compose
    create_caddyfile
    
    # Create management tools
    create_management_dashboard
    create_management_menu
    
    # Create backup and restore systems
    create_backup_scripts
    create_restore_system
    create_migration_tools
    create_update_script
    create_troubleshooting_script
    
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
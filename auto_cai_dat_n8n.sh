#!/bin/bash

# =============================================================================
# 🚀 N8N ULTIMATE AUTO-INSTALLER 2025 - VERSION 4.0
# =============================================================================
# Tác giả: Nguyễn Ngọc Thiện
# YouTube: https://www.youtube.com/@kalvinthiensocial
# Zalo: 08.8888.4749
# Cập nhật: 10/07/2025
# Features: Multi-Domain + Localhost + Cloudflare Tunnel + Full Options
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
INSTALL_MODE="" # domain, localhost, cloudflare
DOMAINS=()
DOMAIN_PORTS=()
API_DOMAIN=""
API_PORT=8000
BEARER_TOKEN=""
TELEGRAM_BOT_TOKEN=""
TELEGRAM_CHAT_ID=""
SSL_EMAIL=""
DASHBOARD_USERNAME=""
DASHBOARD_PASSWORD=""
DASHBOARD_PORT=8080
ENABLE_NEWS_API=false
ENABLE_TELEGRAM=false
ENABLE_MULTI_DOMAIN=false
ENABLE_POSTGRESQL=false
ENABLE_GOOGLE_DRIVE=false
ENABLE_TELEGRAM_BOT=false
ENABLE_DASHBOARD_AUTH=true
CLOUDFLARE_TUNNEL_TOKEN=""
CLOUDFLARE_MODE="" # new, existing
CLEAN_INSTALL=false
SKIP_DOCKER=false
WSL_ENV=false
START_PORT=5800

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

show_banner() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}           🚀 N8N ULTIMATE AUTO-INSTALLER 2025 - VERSION 4.0 🚀             ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${WHITE} ✨ Multi-Domain + Localhost + Cloudflare Tunnel Support                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 🔒 SSL Certificate Auto + Dashboard Security                             ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 📰 News API + Telegram Bot + Google Drive Backup                        ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 🛠️ Smart Port Management + Auto-Fix All Issues                          ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 🌐 Full WSL/VPS Compatibility                                            ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${YELLOW} 👨‍💻 Tác giả: Nguyễn Ngọc Thiện                                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 📺 YouTube: https://www.youtube.com/@kalvinthiensocial                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 📱 Zalo: 08.8888.4749                                                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 🎬 ĐĂNG KÝ KÊNH ĐỂ ỦNG HỘ MÌNH NHÉ! 🔔                                 ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 📅 Cập nhật: 01/07/2025 - Version 4.0 Ultimate                         ${CYAN}║${NC}"
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
        WSL_ENV=true
        
        # WSL specific optimizations
        echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
        sysctl -p >/dev/null 2>&1 || true
    else
        WSL_ENV=false
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

check_port_availability() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 1
    else
        return 0
    fi
}

get_next_available_port() {
    local start_port=$1
    local port=$start_port
    
    while ! check_port_availability $port; do
        ((port++))
    done
    
    echo $port
}

# =============================================================================
# INSTALLATION MODE SELECTION
# =============================================================================

get_installation_mode() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        🎯 CHỌN CHẾ ĐỘ CÀI ĐẶT                              ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Chọn phương thức triển khai:${NC}"
    echo -e "  ${GREEN}1.${NC} Domain Mode - Sử dụng domain thật + SSL Let's Encrypt"
    echo -e "  ${GREEN}2.${NC} Localhost Mode - Chạy local không cần domain"
    echo -e "  ${GREEN}3.${NC} Cloudflare Tunnel - Truy cập từ xa không cần mở port"
    echo ""
    
    while true; do
        read -p "🎯 Chọn chế độ (1-3): " mode
        case $mode in
            1)
                INSTALL_MODE="domain"
                info "Đã chọn: Domain Mode"
                break
                ;;
            2)
                INSTALL_MODE="localhost"
                info "Đã chọn: Localhost Mode"
                break
                ;;
            3)
                INSTALL_MODE="cloudflare"
                info "Đã chọn: Cloudflare Tunnel Mode"
                break
                ;;
            *)
                error "Lựa chọn không hợp lệ. Vui lòng chọn 1-3."
                ;;
        esac
    done
}

get_deployment_type() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        🚀 CHỌN LOẠI TRIỂN KHAI                             ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Chọn số lượng N8N instances:${NC}"
    echo -e "  ${GREEN}1.${NC} Single Instance - 1 N8N instance"
    echo -e "  ${GREEN}2.${NC} Multi Instance - Nhiều N8N instances riêng biệt"
    echo ""
    
    while true; do
        read -p "🚀 Chọn loại (1-2): " type
        case $type in
            1)
                ENABLE_MULTI_DOMAIN=false
                info "Đã chọn: Single Instance"
                break
                ;;
            2)
                ENABLE_MULTI_DOMAIN=true
                info "Đã chọn: Multi Instance"
                break
                ;;
            *)
                error "Lựa chọn không hợp lệ. Vui lòng chọn 1-2."
                ;;
        esac
    done
}

# =============================================================================
# DOMAIN INPUT FUNCTIONS
# =============================================================================

get_domain_input() {
    if [[ "$INSTALL_MODE" == "localhost" ]]; then
        DOMAINS=("localhost")
        DOMAIN_PORTS=($(get_next_available_port 5678))
        info "Localhost mode - N8N sẽ chạy ở port: ${DOMAIN_PORTS[0]}"
        return
    fi
    
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        🌐 CẤU HÌNH DOMAIN & PORTS                          ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        echo -e "${WHITE}Multi-Instance Mode:${NC}"
        echo -e "  • Mỗi domain/subdomain sẽ có N8N instance riêng"
        echo -e "  • Ports sẽ tự động assign từ ${START_PORT} trở lên"
        echo -e "  • Hoặc bạn có thể chỉ định port riêng"
        echo ""
        
        local instance_count=1
        while true; do
            read -p "🌐 Nhập domain/subdomain cho instance $instance_count (hoặc Enter để kết thúc): " domain
            
            if [[ -z "$domain" ]]; then
                if [[ ${#DOMAINS[@]} -eq 0 ]]; then
                    error "Cần ít nhất 1 domain!"
                    continue
                else
                    break
                fi
            fi
            
            if [[ "$domain" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$ ]] || [[ "$INSTALL_MODE" == "cloudflare" ]]; then
                # Ask for custom port
                local default_port=$(get_next_available_port $START_PORT)
                read -p "🔌 Port cho $domain (Enter = $default_port): " custom_port
                
                if [[ -z "$custom_port" ]]; then
                    custom_port=$default_port
                else
                    if ! check_port_availability $custom_port; then
                        error "Port $custom_port đã được sử dụng!"
                        continue
                    fi
                fi
                
                DOMAINS+=("$domain")
                DOMAIN_PORTS+=("$custom_port")
                START_PORT=$((custom_port + 1))
                
                success "✅ Instance $instance_count: $domain:$custom_port"
                ((instance_count++))
            else
                error "Domain không hợp lệ. Vui lòng nhập lại."
            fi
        done
    else
        # Single instance mode
        while true; do
            read -p "🌐 Nhập domain chính cho N8N: " domain
            
            if [[ "$domain" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$ ]] || [[ "$INSTALL_MODE" == "cloudflare" ]]; then
                local default_port=$(get_next_available_port 5678)
                read -p "🔌 Port cho N8N (Enter = $default_port): " custom_port
                
                if [[ -z "$custom_port" ]]; then
                    custom_port=$default_port
                else
                    if ! check_port_availability $custom_port; then
                        error "Port $custom_port đã được sử dụng!"
                        continue
                    fi
                fi
                
                DOMAINS=("$domain")
                DOMAIN_PORTS=("$custom_port")
                success "✅ Domain: $domain:$custom_port"
                break
            else
                error "Domain không hợp lệ. Vui lòng nhập lại."
            fi
        done
    fi
    
    # Summary
    echo ""
    info "📋 Tổng kết cấu hình:"
    for i in "${!DOMAINS[@]}"; do
        info "  Instance $((i+1)): ${DOMAINS[$i]} → Port ${DOMAIN_PORTS[$i]}"
    done
}

# =============================================================================
# FEATURES SELECTION
# =============================================================================

get_features_selection() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        ⚙️  CHỌN TÍNH NĂNG BỔ SUNG                           ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # PostgreSQL
    echo -e "${WHITE}1. Database:${NC}"
    echo -e "  ${GREEN}a.${NC} SQLite (Mặc định, nhẹ)"
    echo -e "  ${GREEN}b.${NC} PostgreSQL (Khuyến nghị cho production)"
    read -p "Chọn database (a/b) [a]: " db_choice
    if [[ "$db_choice" == "b" ]]; then
        ENABLE_POSTGRESQL=true
        success "✅ Đã chọn PostgreSQL"
    else
        ENABLE_POSTGRESQL=false
        success "✅ Đã chọn SQLite"
    fi
    
    # News API
    echo ""
    echo -e "${WHITE}2. News Content API:${NC}"
    echo -e "  • Cào nội dung từ websites"
    echo -e "  • Parse RSS feeds"
    echo -e "  • Extract articles với AI"
    read -p "Cài đặt News API? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ENABLE_NEWS_API=true
        
        # Get API port
        local default_api_port=$(get_next_available_port $API_PORT)
        read -p "🔌 Port cho News API (Enter = $default_api_port): " custom_api_port
        if [[ -n "$custom_api_port" ]]; then
            API_PORT=$custom_api_port
        else
            API_PORT=$default_api_port
        fi
        
        # API Domain
        if [[ "$INSTALL_MODE" == "domain" ]]; then
            read -p "🌐 Domain cho API (Enter = api.${DOMAINS[0]}): " api_domain
            API_DOMAIN="${api_domain:-api.${DOMAINS[0]}}"
        else
            API_DOMAIN="localhost"
        fi
        
        success "✅ News API enabled - Port: $API_PORT"
    fi
    
    # Telegram Backup
    echo ""
    echo -e "${WHITE}3. Telegram Backup:${NC}"
    echo -e "  • Tự động backup hàng ngày"
    echo -e "  • Gửi file backup qua Telegram"
    read -p "Cài đặt Telegram Backup? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ENABLE_TELEGRAM=true
        success "✅ Telegram Backup enabled"
    fi
    
    # Google Drive Backup
    echo ""
    echo -e "${WHITE}4. Google Drive Backup:${NC}"
    echo -e "  • Upload backup lên Google Drive"
    echo -e "  • Tổ chức theo thư mục"
    read -p "Cài đặt Google Drive Backup? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ENABLE_GOOGLE_DRIVE=true
        success "✅ Google Drive Backup enabled"
    fi
    
    # Telegram Bot Management
    echo ""
    echo -e "${WHITE}5. Telegram Bot Management:${NC}"
    echo -e "  • Quản lý N8N qua Telegram"
    echo -e "  • Monitor & control từ xa"
    read -p "Cài đặt Telegram Bot? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ENABLE_TELEGRAM_BOT=true
        success "✅ Telegram Bot enabled"
    fi
}

# =============================================================================
# CLOUDFLARE TUNNEL CONFIGURATION
# =============================================================================

get_cloudflare_config() {
    if [[ "$INSTALL_MODE" != "cloudflare" ]]; then
        return
    fi
    
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        ☁️  CLOUDFLARE TUNNEL CONFIG                         ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${WHITE}Chọn phương thức setup Cloudflare Tunnel:${NC}"
    echo -e "  ${GREEN}1.${NC} Tạo tunnel mới (cần Cloudflare account)"
    echo -e "  ${GREEN}2.${NC} Sử dụng tunnel token có sẵn"
    echo ""
    
    while true; do
        read -p "Chọn phương thức (1-2): " cf_mode
        case $cf_mode in
            1)
                CLOUDFLARE_MODE="new"
                info "Sẽ hướng dẫn tạo tunnel mới"
                break
                ;;
            2)
                CLOUDFLARE_MODE="existing"
                read -p "🔑 Nhập Cloudflare Tunnel Token: " CLOUDFLARE_TUNNEL_TOKEN
                success "✅ Đã nhận tunnel token"
                break
                ;;
            *)
                error "Lựa chọn không hợp lệ"
                ;;
        esac
    done
}

# =============================================================================
# SECURITY CONFIGURATION
# =============================================================================

get_security_config() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        🔒 CẤU HÌNH BẢO MẬT                                 ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Dashboard authentication
    if [[ "$INSTALL_MODE" == "localhost" ]]; then
        read -p "🔐 Bật Basic Auth cho Dashboard? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            ENABLE_DASHBOARD_AUTH=false
            info "Dashboard sẽ không có authentication"
            return
        fi
    fi
    
    ENABLE_DASHBOARD_AUTH=true
    echo -e "${YELLOW}Dashboard Basic Authentication:${NC}"
    
    while true; do
        read -p "👤 Username cho Dashboard: " DASHBOARD_USERNAME
        if [[ -n "$DASHBOARD_USERNAME" ]]; then
            break
        else
            error "Username không được để trống!"
        fi
    done
    
    while true; do
        read -s -p "🔑 Password cho Dashboard: " DASHBOARD_PASSWORD
        echo
        if [[ ${#DASHBOARD_PASSWORD} -ge 8 ]]; then
            read -s -p "🔑 Xác nhận password: " password_confirm
            echo
            if [[ "$DASHBOARD_PASSWORD" == "$password_confirm" ]]; then
                break
            else
                error "Password không khớp!"
            fi
        else
            error "Password phải có ít nhất 8 ký tự!"
        fi
    done
    
    # Dashboard port
    local default_dash_port=$(get_next_available_port $DASHBOARD_PORT)
    read -p "🔌 Port cho Dashboard (Enter = $default_dash_port): " custom_dash_port
    if [[ -n "$custom_dash_port" ]]; then
        DASHBOARD_PORT=$custom_dash_port
    else
        DASHBOARD_PORT=$default_dash_port
    fi
    
    success "✅ Dashboard security configured"
    
    # SSL Email for domain mode
    if [[ "$INSTALL_MODE" == "domain" ]]; then
        echo ""
        echo -e "${YELLOW}SSL Certificate Email:${NC}"
        while true; do
            read -p "📧 Email cho SSL certificates: " SSL_EMAIL
            if [[ -n "$SSL_EMAIL" && "$SSL_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                if [[ "$SSL_EMAIL" != *"@example.com" ]]; then
                    break
                else
                    error "Vui lòng sử dụng email thật!"
                fi
            else
                error "Email không hợp lệ!"
            fi
        done
        success "✅ SSL email configured"
    fi
}

# =============================================================================
# API CONFIGURATION
# =============================================================================

get_api_config() {
    if [[ "$ENABLE_NEWS_API" != "true" ]]; then
        return
    fi
    
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        📰 NEWS API CONFIGURATION                           ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${YELLOW}🔐 Thiết lập Bearer Token cho News API:${NC}"
    echo -e "  • Token phải có ít nhất 20 ký tự"
    echo -e "  • Chỉ chứa chữ cái và số"
    echo ""
    
    while true; do
        read -p "🔑 Nhập Bearer Token: " BEARER_TOKEN
        if [[ ${#BEARER_TOKEN} -ge 20 && "$BEARER_TOKEN" =~ ^[a-zA-Z0-9]+$ ]]; then
            success "✅ Bearer Token đã được thiết lập"
            break
        else
            error "Token phải có ít nhất 20 ký tự và chỉ chứa chữ cái, số."
        fi
    done
}

# =============================================================================
# TELEGRAM CONFIGURATION
# =============================================================================

get_telegram_config() {
    if [[ "$ENABLE_TELEGRAM" != "true" && "$ENABLE_TELEGRAM_BOT" != "true" ]]; then
        return
    fi
    
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        📱 TELEGRAM CONFIGURATION                           ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
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
            error "Bot Token không hợp lệ!"
        fi
    done
    
    echo ""
    echo -e "${YELLOW}🆔 Hướng dẫn lấy Chat ID:${NC}"
    echo -e "  • Cá nhân: Tìm @userinfobot, gửi /start"
    echo -e "  • Nhóm: Thêm bot vào nhóm, Chat ID bắt đầu bằng -"
    echo ""
    
    while true; do
        read -p "🆔 Nhập Telegram Chat ID: " TELEGRAM_CHAT_ID
        if [[ -n "$TELEGRAM_CHAT_ID" && "$TELEGRAM_CHAT_ID" =~ ^-?[0-9]+$ ]]; then
            break
        else
            error "Chat ID không hợp lệ!"
        fi
    done
    
    success "✅ Telegram configuration completed"
}

# =============================================================================
# DOCKER & SYSTEM SETUP
# =============================================================================

setup_swap() {
    log "🔄 Thiết lập swap memory..."
    
    local ram_gb=$(free -g | awk '/^Mem:/{print $2}')
    local swap_size
    
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        swap_size=$((ram_gb < 4 ? 4 : 8))G
    else
        swap_size=$((ram_gb < 4 ? 2 : 4))G
    fi
    
    if ! swapon --show | grep -q "/swapfile"; then
        log "Tạo swap file ${swap_size}..."
        fallocate -l $swap_size /swapfile 2>/dev/null || dd if=/dev/zero of=/swapfile bs=1024 count=$((${swap_size%G} * 1024 * 1024))
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        
        if ! grep -q "/swapfile" /etc/fstab; then
            echo "/swapfile none swap sw 0 0" >> /etc/fstab
        fi
        
        success "Đã thiết lập swap ${swap_size}"
    else
        info "Swap file đã tồn tại"
    fi
}

install_docker() {
    if command -v docker &> /dev/null; then
        info "Docker đã được cài đặt"
        
        if ! docker info &> /dev/null; then
            log "Khởi động Docker daemon..."
            
            if [[ "$WSL_ENV" == "true" ]]; then
                # WSL specific Docker start
                service docker start || true
            else
                systemctl start docker
                systemctl enable docker
            fi
        fi
        
        if [[ -z "$DOCKER_COMPOSE" ]]; then
            log "Cài đặt docker-compose..."
            apt update
            apt install -y docker-compose
            export DOCKER_COMPOSE="docker-compose"
        fi
        
        return 0
    fi
    
    log "📦 Cài đặt Docker..."
    
    apt update
    apt install -y apt-transport-https ca-certificates curl gnupg lsb-release python3 python3-pip
    
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-compose
    
    if [[ "$WSL_ENV" == "true" ]]; then
        service docker start
    else
        systemctl start docker
        systemctl enable docker
    fi
    
    usermod -aG docker $SUDO_USER 2>/dev/null || true
    
    export DOCKER_COMPOSE="docker-compose"
    success "Đã cài đặt Docker thành công"
}

# =============================================================================
# PROJECT STRUCTURE
# =============================================================================

create_project_structure() {
    log "📁 Tạo cấu trúc thư mục..."
    
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Base directories
    mkdir -p files/backup_full
    mkdir -p files/temp
    mkdir -p logs
    mkdir -p caddy_data
    mkdir -p caddy_config
    
    # Multi-instance directories
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            mkdir -p "files/n8n_instance_$((i+1))"
            mkdir -p "files/n8n_instance_$((i+1))/.n8n"
            chown -R 1000:1000 "files/n8n_instance_$((i+1))"
        done
    else
        mkdir -p "files/.n8n"
        chown -R 1000:1000 "files"
    fi
    
    # PostgreSQL
    if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
        mkdir -p postgres_data
        chown -R 999:999 postgres_data
    fi
    
    # Additional features directories
    [[ "$ENABLE_NEWS_API" == "true" ]] && mkdir -p news_api
    [[ "$ENABLE_GOOGLE_DRIVE" == "true" ]] && mkdir -p google_drive
    [[ "$ENABLE_TELEGRAM_BOT" == "true" ]] && mkdir -p telegram_bot
    mkdir -p dashboard
    mkdir -p management
    
    # Cloudflare
    if [[ "$INSTALL_MODE" == "cloudflare" ]]; then
        mkdir -p cloudflare
    fi
    
    success "Đã tạo cấu trúc thư mục"
}

# =============================================================================
# DOCKER FILES CREATION
# =============================================================================

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
RUN mkdir -p /home/node/.n8n/nodes && \
    mkdir -p /data && \
    chown -R node:node /home/node/.n8n && \
    chown -R node:node /data

USER node

# Install additional N8N nodes
RUN cd /home/node && npm install n8n-nodes-puppeteer

WORKDIR /data
EOF
    
    success "Đã tạo Dockerfile"
}

create_docker_compose() {
    log "🐳 Tạo docker-compose.yml..."
    
    cat > "$INSTALL_DIR/docker-compose.yml" << 'EOF'
version: '3.8'

services:
EOF

    # Add N8N services
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            local instance_num=$((i+1))
            local port="${DOMAIN_PORTS[$i]}"
            
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
      - WEBHOOK_URL=$([[ "$INSTALL_MODE" == "domain" ]] && echo "https://${DOMAINS[$i]}/" || echo "http://localhost:${port}/")
      - GENERIC_TIMEZONE=Asia/Ho_Chi_Minh
      - N8N_METRICS=true
      - N8N_LOG_LEVEL=info
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
EOF
            else
                cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
      - DB_TYPE=sqlite
      - DB_SQLITE_DATABASE=/home/node/.n8n/database.sqlite
EOF
            fi

            cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
      - N8N_BASIC_AUTH_ACTIVE=false
      - EXECUTIONS_TIMEOUT=3600
      - EXECUTIONS_TIMEOUT_MAX=7200
    volumes:
      - ./files/n8n_instance_${instance_num}:/home/node/.n8n
      - ./files/n8n_instance_${instance_num}:/data
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
        # Single instance
        cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
  n8n:
    build: .
    container_name: n8n-container
    restart: unless-stopped
    ports:
      - "127.0.0.1:${DOMAIN_PORTS[0]}:5678"
    environment:
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=production
      - WEBHOOK_URL=$([[ "$INSTALL_MODE" == "domain" ]] && echo "https://${DOMAINS[0]}/" || echo "http://localhost:${DOMAIN_PORTS[0]}/")
      - GENERIC_TIMEZONE=Asia/Ho_Chi_Minh
      - N8N_METRICS=true
      - N8N_LOG_LEVEL=info
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
      - EXECUTIONS_TIMEOUT=3600
      - EXECUTIONS_TIMEOUT_MAX=7200
    volumes:
      - ./files:/home/node/.n8n
      - ./files:/data
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

    # Add PostgreSQL if enabled
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
      - ./init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    networks:
      - n8n_network
    ports:
      - "127.0.0.1:5432:5432"

EOF
    fi

    # Add Caddy for domain/localhost mode
    if [[ "$INSTALL_MODE" != "cloudflare" ]]; then
        cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
  caddy:
    image: caddy:latest
    container_name: caddy-proxy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "${DASHBOARD_PORT}:${DASHBOARD_PORT}"
EOF

        if [[ "$ENABLE_NEWS_API" == "true" ]]; then
            echo "      - \"${API_PORT}:${API_PORT}\"" >> "$INSTALL_DIR/docker-compose.yml"
        fi

        cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - ./caddy_data:/data
      - ./caddy_config:/config
      - ./dashboard:/srv/dashboard
    networks:
      - n8n_network
    environment:
      - DASHBOARD_USERNAME=${DASHBOARD_USERNAME}
      - DASHBOARD_PASSWORD=${DASHBOARD_PASSWORD}
    depends_on:
EOF

        if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
            for i in "${!DOMAINS[@]}"; do
                echo "      - n8n_$((i+1))" >> "$INSTALL_DIR/docker-compose.yml"
            done
        else
            echo "      - n8n" >> "$INSTALL_DIR/docker-compose.yml"
        fi

        if [[ "$ENABLE_NEWS_API" == "true" ]]; then
            echo "      - fastapi" >> "$INSTALL_DIR/docker-compose.yml"
        fi
        echo "" >> "$INSTALL_DIR/docker-compose.yml"
    fi

    # Add News API if enabled
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
  fastapi:
    build: ./news_api
    container_name: news-api-container
    restart: unless-stopped
    ports:
      - "127.0.0.1:${API_PORT}:8000"
    environment:
      - NEWS_API_TOKEN=${BEARER_TOKEN}
      - PYTHONUNBUFFERED=1
    networks:
      - n8n_network

EOF
    fi

    # Add Cloudflare Tunnel if needed
    if [[ "$INSTALL_MODE" == "cloudflare" ]]; then
        cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflare-tunnel
    restart: unless-stopped
    command: tunnel --no-autoupdate run
    environment:
      - TUNNEL_TOKEN=${CLOUDFLARE_TUNNEL_TOKEN}
    networks:
      - n8n_network
    depends_on:
EOF
        if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
            for i in "${!DOMAINS[@]}"; do
                echo "      - n8n_$((i+1))" >> "$INSTALL_DIR/docker-compose.yml"
            done
        else
            echo "      - n8n" >> "$INSTALL_DIR/docker-compose.yml"
        fi
        echo "" >> "$INSTALL_DIR/docker-compose.yml"
    fi

    # Networks
    cat >> "$INSTALL_DIR/docker-compose.yml" << 'EOF'
networks:
  n8n_network:
    driver: bridge
EOF

    success "Đã tạo docker-compose.yml"
}

# =============================================================================
# CADDYFILE CREATION
# =============================================================================

create_caddyfile() {
    if [[ "$INSTALL_MODE" == "cloudflare" ]]; then
        return
    fi
    
    log "🌐 Tạo Caddyfile..."
    
    # Generate hashed password for dashboard
    local hashed_pass=""
    if [[ "$ENABLE_DASHBOARD_AUTH" == "true" ]]; then
        # Use caddy hash-password when container is running
        hashed_pass="JDJhJDE0JEVCNXhWS2pQSzJneFZlN05YUkxoL09mS0pPY2ZGcUZBc1dJZ3o1YUNlNGpGV1AwRWxma0Jl" # temp placeholder
    fi
    
    if [[ "$INSTALL_MODE" == "localhost" ]]; then
        # Localhost mode Caddyfile
        cat > "$INSTALL_DIR/Caddyfile" << EOF
{
    auto_https off
    admin off
}

EOF

        # N8N instances
        if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
            for i in "${!DOMAINS[@]}"; do
                local instance_num=$((i+1))
                local port="${DOMAIN_PORTS[$i]}"
                
                cat >> "$INSTALL_DIR/Caddyfile" << EOF
:${port} {
    reverse_proxy n8n-container-${instance_num}:5678
    header {
        Access-Control-Allow-Origin *
        Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
        Access-Control-Allow-Headers "Content-Type, Authorization"
    }
}

EOF
            done
        else
            cat >> "$INSTALL_DIR/Caddyfile" << EOF
:${DOMAIN_PORTS[0]} {
    reverse_proxy n8n-container:5678
    header {
        Access-Control-Allow-Origin *
        Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
        Access-Control-Allow-Headers "Content-Type, Authorization"
    }
}

EOF
        fi

        # News API
        if [[ "$ENABLE_NEWS_API" == "true" ]]; then
            cat >> "$INSTALL_DIR/Caddyfile" << EOF
:${API_PORT} {
    reverse_proxy news-api-container:8000
    header {
        Access-Control-Allow-Origin *
        Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
        Access-Control-Allow-Headers "Content-Type, Authorization"
    }
}

EOF
        fi

        # Dashboard
        cat >> "$INSTALL_DIR/Caddyfile" << EOF
:${DASHBOARD_PORT} {
EOF
        if [[ "$ENABLE_DASHBOARD_AUTH" == "true" ]]; then
            cat >> "$INSTALL_DIR/Caddyfile" << EOF
    basicauth {
        ${DASHBOARD_USERNAME} ${hashed_pass}
    }
EOF
        fi
        cat >> "$INSTALL_DIR/Caddyfile" << EOF
    root * /srv/dashboard
    file_server
}
EOF

    else
        # Domain mode Caddyfile
        cat > "$INSTALL_DIR/Caddyfile" << EOF
{
    email ${SSL_EMAIL}
    acme_ca https://acme-v02.api.letsencrypt.org/directory
}

EOF

        # N8N domains
        if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
            for i in "${!DOMAINS[@]}"; do
                local instance_num=$((i+1))
                local domain="${DOMAINS[$i]}"
                
                cat >> "$INSTALL_DIR/Caddyfile" << EOF
${domain} {
    reverse_proxy n8n-container-${instance_num}:5678
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
    }
    
    encode gzip
}

EOF
            done
        else
            cat >> "$INSTALL_DIR/Caddyfile" << EOF
${DOMAINS[0]} {
    reverse_proxy n8n-container:5678
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
    }
    
    encode gzip
}

EOF
        fi

        # API domain
        if [[ "$ENABLE_NEWS_API" == "true" ]]; then
            cat >> "$INSTALL_DIR/Caddyfile" << EOF
${API_DOMAIN} {
    reverse_proxy news-api-container:8000
    
    header {
        Access-Control-Allow-Origin *
        Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
        Access-Control-Allow-Headers "Content-Type, Authorization"
    }
    
    encode gzip
}

EOF
        fi

        # Dashboard subdomain
        cat >> "$INSTALL_DIR/Caddyfile" << EOF
dashboard.${DOMAINS[0]}:${DASHBOARD_PORT} {
EOF
        if [[ "$ENABLE_DASHBOARD_AUTH" == "true" ]]; then
            cat >> "$INSTALL_DIR/Caddyfile" << EOF
    basicauth {
        ${DASHBOARD_USERNAME} ${hashed_pass}
    }
EOF
        fi
        cat >> "$INSTALL_DIR/Caddyfile" << EOF
    root * /srv/dashboard
    file_server
}
EOF
    fi
    
    success "Đã tạo Caddyfile"
}

# =============================================================================
# POSTGRESQL SETUP
# =============================================================================

create_postgresql_init() {
    if [[ "$ENABLE_POSTGRESQL" != "true" ]]; then
        return
    fi
    
    log "🐘 Tạo PostgreSQL init script..."
    
    cat > "$INSTALL_DIR/init-db.sql" << 'EOF'
-- Create main user
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'n8n_user') THEN
        CREATE USER n8n_user WITH PASSWORD 'n8n_password_2025';
    END IF;
END
$$;

-- Create main database
CREATE DATABASE n8n_db OWNER n8n_user;

-- Grant privileges
ALTER USER n8n_user CREATEDB;
GRANT ALL PRIVILEGES ON DATABASE n8n_db TO n8n_user;

-- Create instance databases for multi-domain
EOF

    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            local instance_num=$((i+1))
            cat >> "$INSTALL_DIR/init-db.sql" << EOF
CREATE DATABASE n8n_db_instance_${instance_num} OWNER n8n_user;
EOF
        done
    fi
    
    success "Đã tạo PostgreSQL init script"
}

# =============================================================================
# NEWS API CREATION
# =============================================================================

create_news_api() {
    if [[ "$ENABLE_NEWS_API" != "true" ]]; then
        return
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

    # Create main.py
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
    description="Advanced News Content Extraction API",
    version="2.0.0",
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
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0"
]

def get_random_user_agent() -> str:
    return random.choice(USER_AGENTS)

def verify_token(credentials: HTTPAuthorizationCredentials = Security(security)):
    if credentials.credentials != NEWS_API_TOKEN:
        raise HTTPException(status_code=401, detail="Invalid authentication token")
    return credentials.credentials

# Models
class ArticleRequest(BaseModel):
    url: HttpUrl
    language: str = Field(default="en", description="Language code")
    extract_images: bool = True
    summarize: bool = False

class ArticleResponse(BaseModel):
    title: str
    content: str
    summary: Optional[str] = None
    authors: List[str]
    publish_date: Optional[datetime] = None
    images: List[str]
    keywords: List[str]
    url: str

# API Routes
@app.get("/", response_class=HTMLResponse)
async def root():
    return f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>News Content API</title>
        <style>
            body {{ font-family: -apple-system, sans-serif; margin: 40px; background: #f5f5f5; }}
            .container {{ max-width: 800px; margin: 0 auto; background: white; padding: 40px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }}
            h1 {{ color: #333; }}
            .endpoint {{ background: #f8f9fa; padding: 15px; margin: 10px 0; border-radius: 5px; border-left: 4px solid #007bff; }}
            code {{ background: #e9ecef; padding: 2px 6px; border-radius: 3px; }}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>📰 News Content API</h1>
            <p>Advanced content extraction API with multi-language support.</p>
            
            <h2>🔐 Authentication</h2>
            <p>All requests require Bearer token in header:</p>
            <code>Authorization: Bearer YOUR_TOKEN</code>
            
            <h2>📖 Documentation</h2>
            <p><a href="/docs">Swagger UI</a> | <a href="/redoc">ReDoc</a></p>
            
            <h2>🚀 Quick Start</h2>
            <div class="endpoint">
                <strong>POST /extract-article</strong><br>
                Extract content from article URL
            </div>
            
            <p><em>Created by Nguyễn Ngọc Thiện</em></p>
        </div>
    </body>
    </html>
    """

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.now(),
        "version": "2.0.0"
    }

@app.post("/extract-article", response_model=ArticleResponse)
async def extract_article(
    request: ArticleRequest,
    token: str = Depends(verify_token)
):
    try:
        config = newspaper.Config()
        config.language = request.language
        config.browser_user_agent = get_random_user_agent()
        
        article = Article(str(request.url), config=config)
        article.download()
        article.parse()
        
        if request.summarize:
            article.nlp()
        
        return ArticleResponse(
            title=article.title or "No title",
            content=article.text or "No content",
            summary=article.summary if request.summarize else None,
            authors=article.authors,
            publish_date=article.publish_date,
            images=list(article.images) if request.extract_images else [],
            keywords=article.keywords[:10] if hasattr(article, 'keywords') else [],
            url=str(request.url)
        )
    except Exception as e:
        logger.error(f"Error extracting article: {e}")
        raise HTTPException(status_code=400, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

    # Create Dockerfile
    cat > "$INSTALL_DIR/news_api/Dockerfile" << 'EOF'
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    gcc g++ libxml2-dev libxslt-dev libjpeg-dev zlib1g-dev libpng-dev curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
EOF

    success "Đã tạo News Content API"
}

# =============================================================================
# DASHBOARD CREATION
# =============================================================================

create_dashboard() {
    log "📊 Tạo Web Dashboard..."
    
    cat > "$INSTALL_DIR/dashboard/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>N8N Management Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #0f172a;
            color: #e2e8f0;
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .header {
            text-align: center;
            margin-bottom: 40px;
            padding: 30px;
            background: linear-gradient(135deg, #3b82f6 0%, #8b5cf6 100%);
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.3);
        }
        
        .header h1 {
            font-size: 2.5rem;
            margin-bottom: 10px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        
        .header p {
            font-size: 1.1rem;
            opacity: 0.9;
        }
        
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .card {
            background: #1e293b;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            border: 1px solid #334155;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.4);
        }
        
        .card h3 {
            color: #60a5fa;
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
            padding: 12px 0;
            border-bottom: 1px solid #334155;
        }
        
        .status-item:last-child {
            border-bottom: none;
        }
        
        .status-running {
            background: #10b981;
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: bold;
        }
        
        .status-stopped {
            background: #ef4444;
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: bold;
        }
        
        .actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 30px;
        }
        
        .btn {
            background: linear-gradient(135deg, #3b82f6, #2563eb);
            color: white;
            border: none;
            padding: 14px 24px;
            border-radius: 10px;
            cursor: pointer;
            font-size: 0.95rem;
            font-weight: 600;
            transition: all 0.3s ease;
            text-decoration: none;
            text-align: center;
            display: inline-block;
            box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(59, 130, 246, 0.4);
        }
        
        .btn-success {
            background: linear-gradient(135deg, #10b981, #059669);
        }
        
        .btn-warning {
            background: linear-gradient(135deg, #f59e0b, #d97706);
        }
        
        .btn-danger {
            background: linear-gradient(135deg, #ef4444, #dc2626);
        }
        
        .loading {
            text-align: center;
            color: #64748b;
            font-style: italic;
        }
        
        .metric-value {
            font-size: 1.5rem;
            font-weight: bold;
            color: #60a5fa;
        }
        
        .logs-container {
            background: #0f172a;
            border-radius: 15px;
            padding: 20px;
            margin-top: 30px;
            border: 1px solid #334155;
            max-height: 400px;
            overflow-y: auto;
        }
        
        .logs-container pre {
            color: #10b981;
            font-family: 'Courier New', monospace;
            font-size: 0.9rem;
            white-space: pre-wrap;
            word-wrap: break-word;
        }
        
        .toast {
            position: fixed;
            bottom: 20px;
            right: 20px;
            background: #10b981;
            color: white;
            padding: 16px 24px;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            transform: translateX(400px);
            transition: transform 0.3s;
            font-weight: 500;
        }
        
        .toast.show {
            transform: translateX(0);
        }
        
        .toast.error {
            background: #ef4444;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 N8N Management Dashboard</h1>
            <p>Real-time monitoring and control center</p>
        </div>
        
        <div class="grid">
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
                <h3>💾 Backup Status</h3>
                <div id="backup-status" class="loading">Loading...</div>
            </div>
        </div>
        
        <div class="actions">
            <button class="btn" onclick="refreshData()">🔄 Refresh</button>
            <button class="btn btn-warning" onclick="restartAll()">🔄 Restart All</button>
            <button class="btn btn-success" onclick="runBackup()">💾 Backup Now</button>
            <button class="btn btn-danger" onclick="showLogs()">📋 View Logs</button>
        </div>
        
        <div class="logs-container" id="logs-container" style="display: none;">
            <h3 style="color: #60a5fa; margin-bottom: 15px;">📋 System Logs</h3>
            <pre id="system-logs">Loading logs...</pre>
        </div>
    </div>

    <div class="toast" id="toast"></div>

    <script>
        const API_BASE = window.location.origin;
        let refreshInterval;

        function showToast(message, isError = false) {
            const toast = document.getElementById('toast');
            toast.textContent = message;
            toast.className = 'toast' + (isError ? ' error' : '');
            toast.classList.add('show');
            
            setTimeout(() => {
                toast.classList.remove('show');
            }, 3000);
        }

        async function fetchData(endpoint) {
            try {
                const response = await fetch(`${API_BASE}/api/${endpoint}`);
                if (!response.ok) throw new Error('Failed to fetch');
                return await response.json();
            } catch (error) {
                console.error(`Error fetching ${endpoint}:`, error);
                return null;
            }
        }

        async function postData(endpoint) {
            try {
                const response = await fetch(`${API_BASE}/api/${endpoint}`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' }
                });
                if (!response.ok) throw new Error('Failed to post');
                return await response.text();
            } catch (error) {
                console.error(`Error posting to ${endpoint}:`, error);
                throw error;
            }
        }

        async function refreshData() {
            // System Overview
            const systemData = await fetchData('system');
            if (systemData) {
                document.getElementById('system-overview').innerHTML = `
                    <div class="status-item">
                        <span>Memory Usage</span>
                        <span class="metric-value">${systemData.memory || 'N/A'}</span>
                    </div>
                    <div class="status-item">
                        <span>Disk Usage</span>
                        <span class="metric-value">${systemData.disk || 'N/A'}</span>
                    </div>
                    <div class="status-item">
                        <span>Uptime</span>
                        <span>${systemData.uptime || 'N/A'}</span>
                    </div>
                `;
            }

            // Container Status
            const containersData = await fetchData('containers');
            if (containersData) {
                let html = '';
                containersData.forEach(container => {
                    html += `
                        <div class="status-item">
                            <span>${container.name}</span>
                            <span class="${container.status === 'running' ? 'status-running' : 'status-stopped'}">
                                ${container.status}
                            </span>
                        </div>
                    `;
                });
                document.getElementById('container-status').innerHTML = html;
            }

            // N8N Instances
            const instancesData = await fetchData('instances');
            if (instancesData) {
                let html = '';
                instancesData.forEach((instance, index) => {
                    html += `
                        <div class="status-item">
                            <span>Instance ${index + 1}: ${instance.domain}</span>
                            <span class="${instance.healthy ? 'status-running' : 'status-stopped'}">
                                ${instance.healthy ? 'Healthy' : 'Unhealthy'}
                            </span>
                        </div>
                    `;
                });
                document.getElementById('n8n-instances').innerHTML = html;
            }

            // Backup Status
            const backupData = await fetchData('backups');
            if (backupData) {
                document.getElementById('backup-status').innerHTML = `
                    <div class="status-item">
                        <span>Total Backups</span>
                        <span class="metric-value">${backupData.count || 0}</span>
                    </div>
                    <div class="status-item">
                        <span>Last Backup</span>
                        <span>${backupData.lastBackup || 'Never'}</span>
                    </div>
                    <div class="status-item">
                        <span>Total Size</span>
                        <span>${backupData.totalSize || '0 MB'}</span>
                    </div>
                `;
            }
        }

        async function restartAll() {
            if (confirm('Are you sure you want to restart all services?')) {
                try {
                    showToast('Restarting all services...');
                    await postData('restart');
                    showToast('Services restarted successfully!');
                    setTimeout(refreshData, 5000);
                } catch (error) {
                    showToast('Failed to restart services', true);
                }
            }
        }

        async function runBackup() {
            if (confirm('Run backup now?')) {
                try {
                    showToast('Starting backup...');
                    await postData('backup');
                    showToast('Backup started successfully!');
                    setTimeout(refreshData, 2000);
                } catch (error) {
                    showToast('Failed to start backup', true);
                }
            }
        }

        async function showLogs() {
            const logsContainer = document.getElementById('logs-container');
            const logsElement = document.getElementById('system-logs');
            
            if (logsContainer.style.display === 'none') {
                logsContainer.style.display = 'block';
                const logs = await fetchData('logs');
                logsElement.textContent = logs || 'No logs available';
            } else {
                logsContainer.style.display = 'none';
            }
        }

        // Auto refresh every 30 seconds
        function startAutoRefresh() {
            refreshInterval = setInterval(refreshData, 30000);
        }

        function stopAutoRefresh() {
            if (refreshInterval) {
                clearInterval(refreshInterval);
            }
        }

        // Initialize
        refreshData();
        startAutoRefresh();

        // Stop refresh when page is hidden
        document.addEventListener('visibilitychange', function() {
            if (document.hidden) {
                stopAutoRefresh();
            } else {
                startAutoRefresh();
                refreshData();
            }
        });
    </script>
</body>
</html>
EOF

    # Create API handler script
    cat > "$INSTALL_DIR/dashboard/api.js" << 'EOF'
const http = require('http');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

const PORT = process.env.DASHBOARD_API_PORT || 8081;

function executeCommand(cmd) {
    return new Promise((resolve, reject) => {
        exec(cmd, { cwd: '/home/n8n' }, (error, stdout, stderr) => {
            if (error) {
                console.error(`Error: ${error}`);
                reject(error);
            } else {
                resolve(stdout + stderr);
            }
        });
    });
}

async function getSystemInfo() {
    try {
        const memory = await executeCommand("free -h | grep Mem | awk '{print $3\"/\"$2}'");
        const disk = await executeCommand("df -h /home/n8n | tail -1 | awk '{print $5}'");
        const uptime = await executeCommand("uptime -p");
        
        return {
            memory: memory.trim(),
            disk: disk.trim(),
            uptime: uptime.trim()
        };
    } catch (error) {
        return { memory: 'Error', disk: 'Error', uptime: 'Error' };
    }
}

async function getContainers() {
    try {
        const output = await executeCommand("docker ps --format '{{.Names}}|{{.Status}}'");
        const containers = output.trim().split('\n').map(line => {
            const [name, status] = line.split('|');
            return {
                name: name,
                status: status.includes('Up') ? 'running' : 'stopped'
            };
        });
        return containers;
    } catch (error) {
        return [];
    }
}

async function getInstances() {
    try {
        const instances = [];
        const caddyfile = fs.readFileSync('/home/n8n/Caddyfile', 'utf8');
        const domains = caddyfile.match(/^[a-zA-Z0-9.-]+(?=\s*{)/gm) || [];
        
        for (const domain of domains) {
            if (!domain.includes(':') && domain !== '{') {
                instances.push({
                    domain: domain,
                    healthy: true // Simplified - you can add real health checks
                });
            }
        }
        
        return instances;
    } catch (error) {
        return [];
    }
}

async function getBackups() {
    try {
        const files = await executeCommand("ls -1 /home/n8n/files/backup_full/n8n_backup_*.zip 2>/dev/null | wc -l");
        const lastBackup = await executeCommand("ls -t /home/n8n/files/backup_full/n8n_backup_*.zip 2>/dev/null | head -1 | xargs basename 2>/dev/null");
        const totalSize = await executeCommand("du -sh /home/n8n/files/backup_full 2>/dev/null | awk '{print $1}'");
        
        return {
            count: parseInt(files.trim()) || 0,
            lastBackup: lastBackup.trim() || 'Never',
            totalSize: totalSize.trim() || '0'
        };
    } catch (error) {
        return { count: 0, lastBackup: 'Never', totalSize: '0' };
    }
}

async function getLogs() {
    try {
        const logs = await executeCommand("docker-compose logs --tail=50 2>&1");
        return logs;
    } catch (error) {
        return 'Error fetching logs';
    }
}

const server = http.createServer(async (req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }

    if (req.url === '/api/system' && req.method === 'GET') {
        const data = await getSystemInfo();
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(data));
    } else if (req.url === '/api/containers' && req.method === 'GET') {
        const data = await getContainers();
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(data));
    } else if (req.url === '/api/instances' && req.method === 'GET') {
        const data = await getInstances();
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(data));
    } else if (req.url === '/api/backups' && req.method === 'GET') {
        const data = await getBackups();
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(data));
    } else if (req.url === '/api/logs' && req.method === 'GET') {
        const data = await getLogs();
        res.writeHead(200, { 'Content-Type': 'text/plain' });
        res.end(data);
    } else if (req.url === '/api/restart' && req.method === 'POST') {
        executeCommand('docker-compose restart').then(() => {
            res.writeHead(200, { 'Content-Type': 'text/plain' });
            res.end('Restart initiated');
        }).catch(error => {
            res.writeHead(500, { 'Content-Type': 'text/plain' });
            res.end('Restart failed');
        });
    } else if (req.url === '/api/backup' && req.method === 'POST') {
        executeCommand('/home/n8n/backup-workflows.sh').then(() => {
            res.writeHead(200, { 'Content-Type': 'text/plain' });
            res.end('Backup started');
        }).catch(error => {
            res.writeHead(500, { 'Content-Type': 'text/plain' });
            res.end('Backup failed');
        });
    } else {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('Not Found');
    }
});

server.listen(PORT, () => {
    console.log(`Dashboard API running on port ${PORT}`);
});
EOF

    success "Đã tạo Dashboard"
}

# =============================================================================
# BACKUP SCRIPTS
# =============================================================================

create_backup_scripts() {
    log "💾 Tạo backup scripts..."
    
    cat > "$INSTALL_DIR/backup-workflows.sh" << 'EOF'
#!/bin/bash

set -e

BACKUP_DIR="/home/n8n/files/backup_full"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="n8n_backup_$TIMESTAMP"
TEMP_DIR="/tmp/$BACKUP_NAME"

# Check Docker Compose
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    DOCKER_COMPOSE="docker compose"
fi

echo "🔄 Starting N8N Backup..."

mkdir -p "$BACKUP_DIR"
mkdir -p "$TEMP_DIR"

cd /home/n8n

# Detect setup type
MULTI_DOMAIN=false
if docker ps --filter "name=n8n-container-" --format "{{.Names}}" | grep -q "n8n-container-"; then
    MULTI_DOMAIN=true
    INSTANCE_COUNT=$(docker ps --filter "name=n8n-container-" --format "{{.Names}}" | wc -l)
else
    INSTANCE_COUNT=1
fi

# Create backup structure
mkdir -p "$TEMP_DIR/config"
mkdir -p "$TEMP_DIR/data"

# Copy configuration files
cp docker-compose.yml "$TEMP_DIR/config/" 2>/dev/null || true
cp Caddyfile "$TEMP_DIR/config/" 2>/dev/null || true
cp telegram_config.txt "$TEMP_DIR/config/" 2>/dev/null || true

# Backup N8N data
if [[ "$MULTI_DOMAIN" == "true" ]]; then
    for i in $(seq 1 $INSTANCE_COUNT); do
        echo "Backing up instance $i..."
        
        # Export workflows and credentials
        docker exec n8n-container-$i n8n export:workflow --all --output=/tmp/workflows_$i.json 2>/dev/null || true
        docker cp n8n-container-$i:/tmp/workflows_$i.json "$TEMP_DIR/data/" 2>/dev/null || true
        
        docker exec n8n-container-$i n8n export:credentials --all --output=/tmp/credentials_$i.json 2>/dev/null || true
        docker cp n8n-container-$i:/tmp/credentials_$i.json "$TEMP_DIR/data/" 2>/dev/null || true
        
        # Copy instance data
        cp -r "files/n8n_instance_$i" "$TEMP_DIR/data/" 2>/dev/null || true
    done
else
    echo "Backing up single instance..."
    
    docker exec n8n-container n8n export:workflow --all --output=/tmp/workflows.json 2>/dev/null || true
    docker cp n8n-container:/tmp/workflows.json "$TEMP_DIR/data/" 2>/dev/null || true
    
    docker exec n8n-container n8n export:credentials --all --output=/tmp/credentials.json 2>/dev/null || true
    docker cp n8n-container:/tmp/credentials.json "$TEMP_DIR/data/" 2>/dev/null || true
    
    cp -r files "$TEMP_DIR/data/" 2>/dev/null || true
fi

# Create zip
cd /tmp
zip -r "$BACKUP_DIR/$BACKUP_NAME.zip" "$BACKUP_NAME/" > /dev/null 2>&1

# Cleanup
rm -rf "$TEMP_DIR"

# Keep only last 30 backups
cd "$BACKUP_DIR"
ls -t n8n_backup_*.zip | tail -n +31 | xargs -r rm -f

echo "✅ Backup completed: $BACKUP_NAME.zip"

# Send Telegram notification if configured
if [[ -f "/home/n8n/telegram_config.txt" ]]; then
    source "/home/n8n/telegram_config.txt"
    
    if [[ -n "$TELEGRAM_BOT_TOKEN" && -n "$TELEGRAM_CHAT_ID" ]]; then
        MESSAGE="🔄 *N8N Backup Completed*%0A%0A📅 Date: $(date +'%Y-%m-%d %H:%M:%S')%0A📦 File: $BACKUP_NAME.zip%0A💾 Size: $(ls -lh $BACKUP_DIR/$BACKUP_NAME.zip | awk '{print $5}')%0A✅ Status: Success"
        
        curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
            -d chat_id="$TELEGRAM_CHAT_ID" \
            -d text="$MESSAGE" \
            -d parse_mode="Markdown" > /dev/null || true
    fi
fi
EOF

    chmod +x "$INSTALL_DIR/backup-workflows.sh"
    
    success "Đã tạo backup scripts"
}

# =============================================================================
# CLOUDFLARE TUNNEL SETUP
# =============================================================================

setup_cloudflare_tunnel() {
    if [[ "$INSTALL_MODE" != "cloudflare" ]]; then
        return
    fi
    
    log "☁️ Thiết lập Cloudflare Tunnel..."
    
    if [[ "$CLOUDFLARE_MODE" == "new" ]]; then
        # Instructions for new tunnel
        echo ""
        echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║${WHITE}                    📋 HƯỚNG DẪN TẠO CLOUDFLARE TUNNEL                      ${CYAN}║${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}Bước 1: Đăng nhập Cloudflare Dashboard${NC}"
        echo -e "  1. Truy cập: https://one.dash.cloudflare.com/"
        echo -e "  2. Chọn domain của bạn"
        echo ""
        echo -e "${YELLOW}Bước 2: Tạo Tunnel${NC}"
        echo -e "  1. Vào Zero Trust → Access → Tunnels"
        echo -e "  2. Click 'Create a tunnel'"
        echo -e "  3. Đặt tên tunnel (ví dụ: n8n-tunnel)"
        echo -e "  4. Copy tunnel token"
        echo ""
        echo -e "${YELLOW}Bước 3: Cấu hình Routes${NC}"
        
        if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
            for i in "${!DOMAINS[@]}"; do
                echo -e "  • ${DOMAINS[$i]} → http://n8n-container-$((i+1)):5678"
            done
        else
            echo -e "  • ${DOMAINS[0]} → http://n8n-container:5678"
        fi
        
        if [[ "$ENABLE_NEWS_API" == "true" ]]; then
            echo -e "  • ${API_DOMAIN} → http://news-api-container:8000"
        fi
        
        echo -e "  • dashboard.${DOMAINS[0]} → http://caddy-proxy:${DASHBOARD_PORT}"
        echo ""
        
        read -p "🔑 Nhập Cloudflare Tunnel Token sau khi tạo: " CLOUDFLARE_TUNNEL_TOKEN
        
        # Update docker-compose with token
        sed -i "s/TUNNEL_TOKEN=.*/TUNNEL_TOKEN=${CLOUDFLARE_TUNNEL_TOKEN}/" "$INSTALL_DIR/docker-compose.yml"
    fi
    
    # Create tunnel config
    cat > "$INSTALL_DIR/cloudflare/config.yml" << EOF
tunnel: ${CLOUDFLARE_TUNNEL_TOKEN}
credentials-file: /etc/cloudflared/creds.json

ingress:
EOF

    # Add routes
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            cat >> "$INSTALL_DIR/cloudflare/config.yml" << EOF
  - hostname: ${DOMAINS[$i]}
    service: http://n8n-container-$((i+1)):5678
EOF
        done
    else
        cat >> "$INSTALL_DIR/cloudflare/config.yml" << EOF
  - hostname: ${DOMAINS[0]}
    service: http://n8n-container:5678
EOF
    fi

    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        cat >> "$INSTALL_DIR/cloudflare/config.yml" << EOF
  - hostname: ${API_DOMAIN}
    service: http://news-api-container:8000
EOF
    fi

    cat >> "$INSTALL_DIR/cloudflare/config.yml" << EOF
  - hostname: dashboard.${DOMAINS[0]}
    service: http://localhost:${DASHBOARD_PORT}
  - service: http_status:404
EOF

    success "Đã thiết lập Cloudflare Tunnel"
}

# =============================================================================
# SYSTEMD SERVICES
# =============================================================================

create_systemd_services() {
    log "⚙️ Tạo systemd services..."
    
    # Dashboard API service
    cat > /etc/systemd/system/n8n-dashboard-api.service << EOF
[Unit]
Description=N8N Dashboard API
After=docker.service
Requires=docker.service

[Service]
Type=simple
User=root
WorkingDirectory=/home/n8n
ExecStart=/usr/bin/node /home/n8n/dashboard/api.js
Restart=always
RestartSec=10
Environment="DASHBOARD_API_PORT=8081"

[Install]
WantedBy=multi-user.target
EOF

    # Telegram Bot service (if enabled)
    if [[ "$ENABLE_TELEGRAM_BOT" == "true" ]]; then
        create_telegram_bot_script
        
        cat > /etc/systemd/system/n8n-telegram-bot.service << EOF
[Unit]
Description=N8N Telegram Bot
After=docker.service
Requires=docker.service

[Service]
Type=simple
User=root
WorkingDirectory=/home/n8n
ExecStart=/usr/bin/python3 /home/n8n/telegram_bot/bot.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    fi

    systemctl daemon-reload
    
    # Enable and start services
    systemctl enable n8n-dashboard-api
    systemctl start n8n-dashboard-api
    
    if [[ "$ENABLE_TELEGRAM_BOT" == "true" ]]; then
        systemctl enable n8n-telegram-bot
        systemctl start n8n-telegram-bot
    fi
    
    success "Đã tạo systemd services"
}

# =============================================================================
# TELEGRAM BOT SCRIPT
# =============================================================================

create_telegram_bot_script() {
    log "🤖 Tạo Telegram Bot script..."
    
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
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests"])
    import requests

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class N8NTelegramBot:
    def __init__(self, token, chat_id):
        self.token = token
        self.chat_id = chat_id
        self.base_url = f"https://api.telegram.org/bot{token}"
        self.last_update_id = 0
        
    def send_message(self, text, parse_mode="Markdown"):
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
        try:
            url = f"{self.base_url}/getUpdates"
            params = {'offset': self.last_update_id + 1, 'timeout': 10}
            response = requests.get(url, params=params, timeout=15)
            return response.json()
        except Exception as e:
            logger.error(f"Failed to get updates: {e}")
            return None
    
    def run_command(self, command):
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
            return "❌ Command timeout"
        except Exception as e:
            return f"❌ Command failed: {e}"
    
    def process_command(self, text):
        text = text.strip().lower()
        
        if text == "/start" or text == "/help":
            return """🤖 *N8N Telegram Bot*

📋 *Commands:*
- `/status` - System status
- `/restart` - Restart all services
- `/backup` - Run backup
- `/logs` - View recent logs
- `/help` - Show this help"""
        
        elif text == "/status":
            containers = self.run_command("docker ps --format 'table {{.Names}}\t{{.Status}}'")
            return f"📊 *System Status*\n```\n{containers}\n```"
        
        elif text == "/restart":
            self.run_command("cd /home/n8n && docker-compose restart")
            return "🔄 All services restarted"
        
        elif text == "/backup":
            self.run_command("/home/n8n/backup-workflows.sh")
            return "💾 Backup started"
        
        elif text == "/logs":
            logs = self.run_command("cd /home/n8n && docker-compose logs --tail=20")
            if len(logs) > 3000:
                logs = logs[-3000:]
            return f"📋 *Recent Logs*\n```\n{logs}\n```"
        
        else:
            return "❌ Unknown command. Use /help"
    
    def run(self):
        logger.info("Bot started")
        self.send_message("🤖 *N8N Bot Started*\nUse /help for commands")
        
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
                    
                    if str(chat_id) != str(self.chat_id):
                        continue
                    
                    if 'text' not in message:
                        continue
                    
                    text = message['text']
                    response = self.process_command(text)
                    self.send_message(response)
                
                time.sleep(1)
                
            except KeyboardInterrupt:
                break
            except Exception as e:
                logger.error(f"Bot error: {e}")
                time.sleep(10)

if __name__ == '__main__':
    config_file = '/home/n8n/telegram_config.txt'
    if os.path.exists(config_file):
        config = {}
        with open(config_file) as f:
            for line in f:
                if '=' in line:
                    key, value = line.strip().split('=', 1)
                    config[key] = value.strip('"')
        
        token = config.get('TELEGRAM_BOT_TOKEN')
        chat_id = config.get('TELEGRAM_CHAT_ID')
        
        if token and chat_id:
            bot = N8NTelegramBot(token, chat_id)
            bot.run()
EOF

    chmod +x "$INSTALL_DIR/telegram_bot/bot.py"
    success "Đã tạo Telegram Bot"
}

# =============================================================================
# CRON JOBS
# =============================================================================

setup_cron_jobs() {
    log "⏰ Thiết lập cron jobs..."
    
    # Remove existing N8N cron jobs
    crontab -l 2>/dev/null | grep -v "/home/n8n" | crontab - 2>/dev/null || true
    
    # Add backup job
    (crontab -l 2>/dev/null; echo "0 2 * * * /home/n8n/backup-workflows.sh") | crontab -
    
    # Add Google Drive cleanup if enabled
    if [[ "$ENABLE_GOOGLE_DRIVE" == "true" ]]; then
        (crontab -l 2>/dev/null; echo "0 3 * * 0 /usr/bin/python3 /home/n8n/google_drive/cleanup.py") | crontab -
    fi
    
    success "Đã thiết lập cron jobs"
}

# =============================================================================
# FINAL CONFIGURATIONS
# =============================================================================

save_config() {
    log "💾 Lưu cấu hình..."
    
    # Save Telegram config
    if [[ "$ENABLE_TELEGRAM" == "true" || "$ENABLE_TELEGRAM_BOT" == "true" ]]; then
        cat > "$INSTALL_DIR/telegram_config.txt" << EOF
TELEGRAM_BOT_TOKEN="$TELEGRAM_BOT_TOKEN"
TELEGRAM_CHAT_ID="$TELEGRAM_CHAT_ID"
EOF
        chmod 600 "$INSTALL_DIR/telegram_config.txt"
    fi
    
    # Save installation config
    cat > "$INSTALL_DIR/.install_config" << EOF
INSTALL_MODE="$INSTALL_MODE"
ENABLE_MULTI_DOMAIN="$ENABLE_MULTI_DOMAIN"
ENABLE_POSTGRESQL="$ENABLE_POSTGRESQL"
ENABLE_NEWS_API="$ENABLE_NEWS_API"
ENABLE_TELEGRAM="$ENABLE_TELEGRAM"
ENABLE_GOOGLE_DRIVE="$ENABLE_GOOGLE_DRIVE"
ENABLE_TELEGRAM_BOT="$ENABLE_TELEGRAM_BOT"
DASHBOARD_PORT="$DASHBOARD_PORT"
API_PORT="$API_PORT"
DOMAINS=(${DOMAINS[@]})
DOMAIN_PORTS=(${DOMAIN_PORTS[@]})
EOF
    
    success "Đã lưu cấu hình"
}

# =============================================================================
# BUILD AND DEPLOY
# =============================================================================

build_and_deploy() {
    log "🏗️ Build và deploy..."
    
    cd "$INSTALL_DIR"
    
    # Update Caddy password hash
    if [[ "$ENABLE_DASHBOARD_AUTH" == "true" && "$INSTALL_MODE" != "cloudflare" ]]; then
        log "Generating password hash..."
        
        # Start Caddy temporarily to hash password
        docker run --rm caddy:latest caddy hash-password --plaintext "$DASHBOARD_PASSWORD" > /tmp/caddy_hash.txt 2>&1
        HASHED_PASS=$(cat /tmp/caddy_hash.txt | tail -1)
        rm -f /tmp/caddy_hash.txt
        
        # Update Caddyfile with actual hash
        sed -i "s|${DASHBOARD_USERNAME} .*|${DASHBOARD_USERNAME} ${HASHED_PASS}|g" Caddyfile
    fi
    
    # Build images
    log "Building Docker images..."
    $DOCKER_COMPOSE build --no-cache
    
    # Start PostgreSQL first if enabled
    if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
        log "Starting PostgreSQL..."
        $DOCKER_COMPOSE up -d postgres
        sleep 20
    fi
    
    # Start all services
    log "Starting all services..."
    $DOCKER_COMPOSE up -d
    
    # Wait for services
    log "Waiting for services to start..."
    sleep 30
    
    # Verify
    log "Verifying deployment..."
    $DOCKER_COMPOSE ps
    
    success "Deployment completed!"
}

# =============================================================================
# FINAL SUMMARY
# =============================================================================

show_final_summary() {
    clear
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${WHITE}             🎉 N8N SYSTEM INSTALLED SUCCESSFULLY! 🎉                       ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}🌐 ACCESS INFORMATION:${NC}"
    
    if [[ "$INSTALL_MODE" == "localhost" ]]; then
        echo -e "${WHITE}N8N Instances:${NC}"
        for i in "${!DOMAINS[@]}"; do
            echo -e "  • Instance $((i+1)): http://localhost:${DOMAIN_PORTS[$i]}"
        done
        
        if [[ "$ENABLE_NEWS_API" == "true" ]]; then
            echo -e "  • News API: http://localhost:${API_PORT}"
            echo -e "  • API Docs: http://localhost:${API_PORT}/docs"
        fi
        
        echo -e "  • Dashboard: http://localhost:${DASHBOARD_PORT}"
        
    elif [[ "$INSTALL_MODE" == "domain" ]]; then
        echo -e "${WHITE}N8N Instances:${NC}"
        for i in "${!DOMAINS[@]}"; do
            echo -e "  • Instance $((i+1)): https://${DOMAINS[$i]}"
        done
        
        if [[ "$ENABLE_NEWS_API" == "true" ]]; then
            echo -e "  • News API: https://${API_DOMAIN}"
            echo -e "  • API Docs: https://${API_DOMAIN}/docs"
        fi
        
        echo -e "  • Dashboard: https://dashboard.${DOMAINS[0]}:${DASHBOARD_PORT}"
        
    elif [[ "$INSTALL_MODE" == "cloudflare" ]]; then
        echo -e "${WHITE}Cloudflare Tunnel Domains:${NC}"
        for i in "${!DOMAINS[@]}"; do
            echo -e "  • Instance $((i+1)): https://${DOMAINS[$i]}"
        done
        
        if [[ "$ENABLE_NEWS_API" == "true" ]]; then
            echo -e "  • News API: https://${API_DOMAIN}"
        fi
        
        echo -e "  • Dashboard: https://dashboard.${DOMAINS[0]}"
    fi
    
    echo ""
    echo -e "${CYAN}🔐 CREDENTIALS:${NC}"
    
    if [[ "$ENABLE_DASHBOARD_AUTH" == "true" ]]; then
        echo -e "  • Dashboard Username: ${WHITE}${DASHBOARD_USERNAME}${NC}"
        echo -e "  • Dashboard Password: ${WHITE}[Hidden - you set it]${NC}"
    fi
    
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        echo -e "  • API Bearer Token: ${WHITE}[Hidden - check docker-compose.yml]${NC}"
    fi
    
    if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
        echo -e "  • PostgreSQL User: ${WHITE}n8n_user${NC}"
        echo -e "  • PostgreSQL Pass: ${WHITE}n8n_password_2025${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}📁 SYSTEM INFO:${NC}"
    echo -e "  • Installation Dir: ${WHITE}${INSTALL_DIR}${NC}"
    echo -e "  • Backup Location: ${WHITE}${INSTALL_DIR}/files/backup_full${NC}"
    echo -e "  • Logs: ${WHITE}${INSTALL_DIR}/logs${NC}"
    
    echo ""
    echo -e "${CYAN}🔧 USEFUL COMMANDS:${NC}"
    echo -e "  • View logs: ${WHITE}cd $INSTALL_DIR && $DOCKER_COMPOSE logs -f${NC}"
    echo -e "  • Restart: ${WHITE}cd $INSTALL_DIR && $DOCKER_COMPOSE restart${NC}"
    echo -e "  • Backup: ${WHITE}$INSTALL_DIR/backup-workflows.sh${NC}"
    echo -e "  • Status: ${WHITE}cd $INSTALL_DIR && $DOCKER_COMPOSE ps${NC}"
    
    if [[ "$ENABLE_TELEGRAM_BOT" == "true" ]]; then
        echo ""
        echo -e "${CYAN}🤖 TELEGRAM BOT COMMANDS:${NC}"
        echo -e "  • /status - View system status"
        echo -e "  • /restart - Restart services"
        echo -e "  • /backup - Run backup"
        echo -e "  • /logs - View logs"
    fi
    
    echo ""
    echo -e "${CYAN}🚀 AUTHOR:${NC}"
    echo -e "  • Name: ${WHITE}Nguyễn Ngọc Thiện${NC}"
    echo -e "  • YouTube: ${WHITE}https://www.youtube.com/@kalvinthiensocial${NC}"
    echo -e "  • Zalo: ${WHITE}08.8888.4749${NC}"
    echo ""
    echo -e "${YELLOW}🎬 SUBSCRIBE TO SUPPORT! 🔔${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    show_banner
    
    # System checks
    check_root
    check_os
    detect_environment
    check_docker_compose
    
    # Installation flow
    get_installation_mode
    get_deployment_type
    get_domain_input
    get_features_selection
    get_cloudflare_config
    get_security_config
    get_api_config
    get_telegram_config
    
    # Setup
    setup_swap
    install_docker
    create_project_structure
    
    # Create configurations
    create_dockerfile
    create_docker_compose
    create_caddyfile
    create_postgresql_init
    create_news_api
    create_dashboard
    create_backup_scripts
    setup_cloudflare_tunnel
    
    # Services and configs
    create_systemd_services
    setup_cron_jobs
    save_config
    
    # Deploy
    build_and_deploy
    
    # Final
    show_final_summary
}

# Run main
main "$@"

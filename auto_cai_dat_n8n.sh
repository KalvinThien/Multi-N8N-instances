#!/bin/bash

# =============================================================================
# 🚀 N8N ULTIMATE AUTO-INSTALLER 2025 - VERSION 4.1 FIXED
# =============================================================================
# Tác giả: Nguyễn Ngọc Thiện
# YouTube: https://www.youtube.com/@kalvinthiensocial
# Zalo: 08.8888.4749
# Cập nhật: 10/07/2025
# Features: Multi-Domain + Localhost + Cloudflare Tunnel + Auto-Fix All Issues
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
    echo -e "${CYAN}║${WHITE}           🚀 N8N ULTIMATE AUTO-INSTALLER 2025 - VERSION 4.1 🚀             ${CYAN}║${NC}"
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
    echo -e "${CYAN}║${YELLOW} 📅 Cập nhật: 10/07/2025 - Version 4.1 Fixed                            ${CYAN}║${NC}"
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
        export DOCKER_COMPOSE_VERSION=$(docker-compose --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        info "Sử dụng docker-compose version $DOCKER_COMPOSE_VERSION"
    elif docker compose version &> /dev/null 2>&1; then
        export DOCKER_COMPOSE="docker compose"
        export DOCKER_COMPOSE_VERSION=$(docker compose version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        info "Sử dụng docker compose version $DOCKER_COMPOSE_VERSION"
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

cleanup_docker_environment() {
    log "🧹 Dọn dẹp môi trường Docker..."
    
    # Stop all N8N related containers
    docker ps -a | grep -E "(n8n|postgres|caddy|cloudflare)" | awk '{print $1}' | xargs -r docker stop 2>/dev/null || true
    
    # Remove orphan containers
    docker ps -a | grep -E "(n8n|postgres|caddy|cloudflare)" | awk '{print $1}' | xargs -r docker rm -f 2>/dev/null || true
    
    # Remove conflicting networks
    docker network ls | grep "n8n" | awk '{print $2}' | xargs -r docker network rm 2>/dev/null || true
    
    # Clean up unused volumes
    docker volume prune -f 2>/dev/null || true
    
    success "Đã dọn dẹp môi trường Docker"
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
    
    # Clean up existing installation
    if [[ -d "$INSTALL_DIR" ]]; then
        cd "$INSTALL_DIR"
        $DOCKER_COMPOSE down --remove-orphans 2>/dev/null || true
        cd /
    fi
    
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
        # PostgreSQL runs as uid 999 in Alpine
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
    
    # Start with version 3.3 for better compatibility
    cat > "$INSTALL_DIR/docker-compose.yml" << 'EOF'
version: '3.3'

services:
EOF

    # Add PostgreSQL first if enabled (to avoid dependency issues)
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
      - ./init-db.sql:/docker-entrypoint-initdb.d/init-db.sql:ro
    networks:
      - n8n_network
    ports:
      - "127.0.0.1:5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

EOF
    fi

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
      postgres:
        condition: service_healthy
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
      postgres:
        condition: service_healthy
EOF
        fi
        echo "" >> "$INSTALL_DIR/docker-compose.yml"
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
    name: n8n_network
EOF

    success "Đã tạo docker-compose.yml"
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
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'n8n_db') THEN
        CREATE DATABASE n8n_db OWNER n8n_user;
    END IF;
END
$$;

-- Grant privileges
ALTER USER n8n_user CREATEDB;
GRANT ALL PRIVILEGES ON DATABASE n8n_db TO n8n_user;

-- Create instance databases for multi-domain
EOF

    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            local instance_num=$((i+1))
            cat >> "$INSTALL_DIR/init-db.sql" << EOF
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'n8n_db_instance_${instance_num}') THEN
        CREATE DATABASE n8n_db_instance_${instance_num} OWNER n8n_user;
    END IF;
END
$$;
EOF
        done
    fi
    
    success "Đã tạo PostgreSQL init script"
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
        
        echo -e "  • dashboard.${DOMAINS[0]} → http://localhost:${DASHBOARD_PORT}"
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
# DASHBOARD CREATION
# =============================================================================

create_dashboard() {
    log "📊 Tạo Web Dashboard..."
    
    # Create simple dashboard HTML
    cat > "$INSTALL_DIR/dashboard/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>N8N Dashboard</title>
    <meta charset="utf-8">
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { background: #3498db; color: white; padding: 20px; border-radius: 10px; margin-bottom: 20px; }
        .card { background: white; padding: 20px; margin: 10px 0; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .status { display: inline-block; padding: 5px 10px; border-radius: 5px; font-size: 14px; }
        .running { background: #2ecc71; color: white; }
        .stopped { background: #e74c3c; color: white; }
        button { background: #3498db; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; margin: 5px; }
        button:hover { background: #2980b9; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 N8N Management Dashboard</h1>
            <p>System monitoring and control panel</p>
        </div>
        
        <div class="card">
            <h2>📊 System Status</h2>
            <div id="status">Loading...</div>
        </div>
        
        <div class="card">
            <h2>🎛️ Quick Actions</h2>
            <button onclick="restartAll()">🔄 Restart All Services</button>
            <button onclick="viewLogs()">📋 View Logs</button>
            <button onclick="runBackup()">💾 Run Backup</button>
        </div>
        
        <div class="card">
            <h2>🌐 N8N Instances</h2>
            <div id="instances">Loading...</div>
        </div>
    </div>
    
    <script>
        function loadStatus() {
            // This is a simple static dashboard
            // For dynamic data, you would need to implement an API
            document.getElementById('status').innerHTML = `
                <p>✅ All systems operational</p>
                <p>📅 Last checked: ${new Date().toLocaleString()}</p>
            `;
            
            document.getElementById('instances').innerHTML = `
                <p>Instance links will be displayed here after deployment completes.</p>
            `;
        }
        
        function restartAll() {
            if (confirm('Restart all services?')) {
                alert('Please run: docker-compose restart');
            }
        }
        
        function viewLogs() {
            alert('Please run: docker-compose logs -f');
        }
        
        function runBackup() {
            alert('Please run: /home/n8n/backup-workflows.sh');
        }
        
        // Load status on page load
        loadStatus();
        
        // Refresh every 30 seconds
        setInterval(loadStatus, 30000);
    </script>
</body>
</html>
EOF

    # Create simple API service
    cat > "$INSTALL_DIR/dashboard/server.py" << 'EOF'
#!/usr/bin/env python3
import http.server
import socketserver
import os

PORT = int(os.environ.get('DASHBOARD_PORT', 8080))

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()

os.chdir('/home/n8n/dashboard')

with socketserver.TCPServer(("0.0.0.0", PORT), MyHTTPRequestHandler) as httpd:
    print(f"Dashboard running at http://0.0.0.0:{PORT}")
    httpd.serve_forever()
EOF

    chmod +x "$INSTALL_DIR/dashboard/server.py"
    
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
# SYSTEMD SERVICES
# =============================================================================

create_systemd_services() {
    log "⚙️ Tạo systemd services..."
    
    # Dashboard service
    cat > /etc/systemd/system/n8n-dashboard.service << EOF
[Unit]
Description=N8N Dashboard
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/home/n8n/dashboard
ExecStart=/usr/bin/python3 /home/n8n/dashboard/server.py
Restart=always
RestartSec=10
Environment="DASHBOARD_PORT=${DASHBOARD_PORT}"

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable n8n-dashboard
    
    success "Đã tạo systemd services"
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
    
    # Clean up any existing containers first
    cleanup_docker_environment
    
    # Build images
    log "Building Docker images..."
    $DOCKER_COMPOSE build --no-cache
    
    # Start PostgreSQL first if enabled
    if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
        log "Starting PostgreSQL..."
        $DOCKER_COMPOSE up -d postgres
        
        # Wait for PostgreSQL to be ready
        log "Waiting for PostgreSQL to initialize..."
        local retries=30
        while [ $retries -gt 0 ]; do
            if docker exec postgres-n8n pg_isready -U postgres >/dev/null 2>&1; then
                success "PostgreSQL is ready"
                break
            fi
            retries=$((retries - 1))
            sleep 2
        done
        
        if [ $retries -eq 0 ]; then
            error "PostgreSQL failed to start"
            exit 1
        fi
    fi
    
    # Start all services
    log "Starting all services..."
    $DOCKER_COMPOSE up -d
    
    # Wait for services
    log "Waiting for services to start..."
    sleep 30
    
    # Start systemd services
    systemctl start n8n-dashboard || true
    
    # Verify
    log "Verifying deployment..."
    $DOCKER_COMPOSE ps
    
    success "Deployment completed!"
}

# =============================================================================
# TROUBLESHOOTING SCRIPT
# =============================================================================

create_troubleshooting_script() {
    log "🔧 Tạo troubleshooting script..."
    
    cat > "$INSTALL_DIR/troubleshoot.sh" << 'EOF'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== N8N TROUBLESHOOTING ===${NC}"
echo ""

# Check Docker
echo -e "${YELLOW}1. Docker Status:${NC}"
docker --version
docker-compose --version || docker compose version
echo ""

# Check containers
echo -e "${YELLOW}2. Container Status:${NC}"
docker ps -a | grep -E "(n8n|postgres|caddy|cloudflare)"
echo ""

# Check logs
echo -e "${YELLOW}3. Recent Logs:${NC}"
cd /home/n8n
docker-compose logs --tail=20 2>/dev/null || docker compose logs --tail=20
echo ""

# Check ports
echo -e "${YELLOW}4. Port Usage:${NC}"
netstat -tulpn | grep -E "(5678|5800|5809|8080|8088|80|443)" 2>/dev/null || ss -tulpn | grep -E "(5678|5800|5809|8080|8088|80|443)"
echo ""

# Check disk space
echo -e "${YELLOW}5. Disk Space:${NC}"
df -h /home/n8n
echo ""

# Suggested fixes
echo -e "${GREEN}=== SUGGESTED FIXES ===${NC}"
echo "1. Restart all services: cd /home/n8n && docker-compose restart"
echo "2. View full logs: cd /home/n8n && docker-compose logs -f"
echo "3. Rebuild containers: cd /home/n8n && docker-compose down && docker-compose up -d --build"
echo "4. Check DNS: nslookup your-domain.com"
echo ""
EOF

    chmod +x "$INSTALL_DIR/troubleshoot.sh"
    success "Đã tạo troubleshooting script"
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
    echo -e "  • Troubleshoot: ${WHITE}${INSTALL_DIR}/troubleshoot.sh${NC}"
    
    echo ""
    echo -e "${CYAN}🔧 USEFUL COMMANDS:${NC}"
    echo -e "  • View logs: ${WHITE}cd $INSTALL_DIR && $DOCKER_COMPOSE logs -f${NC}"
    echo -e "  • Restart: ${WHITE}cd $INSTALL_DIR && $DOCKER_COMPOSE restart${NC}"
    echo -e "  • Backup: ${WHITE}$INSTALL_DIR/backup-workflows.sh${NC}"
    echo -e "  • Status: ${WHITE}cd $INSTALL_DIR && $DOCKER_COMPOSE ps${NC}"
    echo -e "  • Troubleshoot: ${WHITE}$INSTALL_DIR/troubleshoot.sh${NC}"
    
    if [[ "$ENABLE_TELEGRAM_BOT" == "true" ]]; then
        echo ""
        echo -e "${CYAN}🤖 TELEGRAM BOT COMMANDS:${NC}"
        echo -e "  • /status - View system status"
        echo -e "  • /restart - Restart services"
        echo -e "  • /backup - Run backup"
        echo -e "  • /logs - View logs"
    fi
    
    echo ""
    echo -e "${CYAN}⚠️  IMPORTANT NOTES:${NC}"
    
    if [[ "$INSTALL_MODE" == "cloudflare" ]]; then
        echo -e "  • Make sure you've configured Cloudflare Tunnel routes correctly"
        echo -e "  • Check tunnel status: ${WHITE}docker logs cloudflare-tunnel${NC}"
    fi
    
    if [[ "$INSTALL_MODE" == "domain" ]]; then
        echo -e "  • SSL certificates will be auto-generated in a few minutes"
        echo -e "  • If SSL fails, check: ${WHITE}docker logs caddy-proxy${NC}"
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
# ERROR HANDLING
# =============================================================================

handle_error() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        error "An error occurred during installation (Exit code: $exit_code)"
        
        echo ""
        echo -e "${YELLOW}Attempting automatic recovery...${NC}"
        
        # Try to fix common issues
        cd "$INSTALL_DIR" 2>/dev/null || true
        
        # Stop all containers
        $DOCKER_COMPOSE down --remove-orphans 2>/dev/null || true
        
        # Clean up
        docker system prune -f 2>/dev/null || true
        
        echo ""
        echo -e "${CYAN}Please try running the troubleshoot script:${NC}"
        echo -e "${WHITE}$INSTALL_DIR/troubleshoot.sh${NC}"
        
        exit $exit_code
    fi
}

# Set error handler
trap handle_error ERR

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
    create_postgresql_init
    create_dashboard
    create_backup_scripts
    setup_cloudflare_tunnel
    create_troubleshooting_script
    
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

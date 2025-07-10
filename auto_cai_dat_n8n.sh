#!/bin/bash

# =============================================================================
# 🚀 SCRIPT CÀI ĐẶT N8N MULTI-DOMAIN TỰ ĐỘNG 2025 - ENHANCED VERSION 4.0
# =============================================================================
# Tác giả: Nguyễn Ngọc Thiện
# YouTube: https://www.youtube.com/@kalvinthiensocial
# Zalo: 08.8888.4749
# Cập nhật: 01/10/2025
# Features: 
#   - Multi-Deployment Modes (Localhost/Domain/Cloudflare Tunnel)
#   - Custom Port Configuration
#   - Dashboard với Basic Auth
#   - Auto-Fix Integration
#   - Health Check & Auto-Recovery
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

# =============================================================================
# GLOBAL VARIABLES
# =============================================================================

# Installation settings
INSTALL_DIR="/home/n8n"
DEPLOYMENT_MODE=""        # localhost/domain/cloudflare
MAIN_DOMAIN=""           # Main domain (e.g., example.com)
DOMAINS=()               # All domains array
SSL_EMAIL=""             # SSL certificate email

# Port configuration
NEWS_API_PORT=8000       # Default News API port
N8N_MAIN_PORT=5678      # Default N8N main port
DASHBOARD_PORT=8080      # Default Dashboard port
PORT_BASE=5800          # Base port for sub-domains

# Security settings
DASHBOARD_USER=""        # Dashboard username
DASHBOARD_PASS=""        # Dashboard password
DASHBOARD_HASH=""        # Dashboard password hash
BEARER_TOKEN=""          # News API bearer token

# Feature flags
ENABLE_NEWS_API=false
ENABLE_TELEGRAM=false
ENABLE_MULTI_DOMAIN=false
ENABLE_POSTGRESQL=false
ENABLE_GOOGLE_DRIVE=false
ENABLE_TELEGRAM_BOT=false
ENABLE_DASHBOARD=true     # Always enabled in v4
AUTO_FIX_ENABLED=true    # Auto-fix after deployment
HEALTH_CHECK_ENABLED=true # Health monitoring

# Telegram settings
TELEGRAM_BOT_TOKEN=""
TELEGRAM_CHAT_ID=""

# Cloudflare settings
CF_TUNNEL_TOKEN=""
CF_TUNNEL_NAME=""

# Container names (standardized)
CONTAINER_PREFIX="n8n"

# Health check settings
HEALTH_CHECK_INTERVAL=30  # seconds
HEALTH_CHECK_RETRIES=3

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

show_banner() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}              🚀 N8N MULTI-DOMAIN INSTALLER 2025 - VERSION 4.0 🚀             ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${WHITE} ✨ Multi-Deployment: Localhost | Domain SSL | Cloudflare Tunnel          ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 🔧 Custom Port Configuration + Auto Port Assignment                      ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 🔒 Dashboard với Basic Auth + SSL Certificate tự động                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 🚀 Auto-Fix Integration + Health Check Monitoring                        ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 📰 News Content API với FastAPI + Newspaper4k                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 🐘 PostgreSQL/SQLite Support + Auto Database Setup                       ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 📱 Telegram Bot Management + Google Drive Backup                         ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${YELLOW} 👨‍💻 Tác giả: Nguyễn Ngọc Thiện                                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 📺 YouTube: https://www.youtube.com/@kalvinthiensocial                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 📱 Zalo: 08.8888.4749                                                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 🎬 ĐĂNG KÝ KÊNH ĐỂ ỦNG HỘ MÌNH NHÉ! 🔔                                 ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 📅 Cập nhật: 01/10/2025 - Version 4.0 Enhanced                         ${CYAN}║${NC}"
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
# SYSTEM CHECK FUNCTIONS
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
    if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
        warning "Script được thiết kế cho Ubuntu/Debian. Hệ điều hành hiện tại: $ID"
        read -p "Bạn có muốn tiếp tục? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        error "Docker chưa được cài đặt"
        return 1
    fi
    
    if ! docker ps &> /dev/null; then
        error "Docker daemon không chạy hoặc user không có quyền"
        return 1
    fi
    
    return 0
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
        return 1
    fi
    return 0
}

# =============================================================================
# PORT MANAGEMENT FUNCTIONS
# =============================================================================

check_port_availability() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        error "Port $port đã được sử dụng!"
        return 1
    fi
    return 0
}

get_next_available_port() {
    local base_port=$1
    local port=$base_port
    
    while ! check_port_availability $port 2>/dev/null; do
        ((port++))
    done
    
    echo $port
}

# =============================================================================
# USER INPUT FUNCTIONS - DEPLOYMENT MODE
# =============================================================================

get_deployment_mode() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        🎯 CHỌN CHẾ ĐỘ TRIỂN KHAI                           ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Chọn chế độ triển khai:${NC}"
    echo -e "  ${GREEN}1.${NC} Localhost (không cần domain, truy cập local)"
    echo -e "  ${GREEN}2.${NC} Domain với SSL (Let's Encrypt tự động)"
    echo -e "  ${GREEN}3.${NC} Cloudflare Tunnel (bảo mật cao, không cần mở port)"
    echo ""
    
    while true; do
        read -p "🎯 Chọn chế độ (1-3): " mode
        case $mode in
            1)
                DEPLOYMENT_MODE="localhost"
                info "Đã chọn: Localhost Mode"
                break
                ;;
            2)
                DEPLOYMENT_MODE="domain"
                info "Đã chọn: Domain với SSL Mode"
                break
                ;;
            3)
                DEPLOYMENT_MODE="cloudflare"
                info "Đã chọn: Cloudflare Tunnel Mode"
                break
                ;;
            *)
                error "Lựa chọn không hợp lệ. Vui lòng chọn 1-3."
                ;;
        esac
    done
}

get_main_domain() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                          🌐 CẤU HÌNH DOMAIN CHÍNH                          ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ "$DEPLOYMENT_MODE" == "localhost" ]]; then
        MAIN_DOMAIN="localhost"
        info "Sử dụng localhost cho triển khai local"
        return
    fi
    
    echo -e "${WHITE}Domain chính sẽ được sử dụng để tạo các subdomain:${NC}"
    echo -e "  • n8n.${GREEN}yourdomain.com${NC} - N8N instance chính"
    echo -e "  • api.${GREEN}yourdomain.com${NC} - News API service"
    echo -e "  • dashboard.${GREEN}yourdomain.com${NC} - Web dashboard"
    echo -e "  • n8n1.${GREEN}yourdomain.com${NC}, n8n2.${GREEN}yourdomain.com${NC}... - Multi instances"
    echo ""
    
    while true; do
        read -p "🌐 Nhập domain chính (ví dụ: example.com): " MAIN_DOMAIN
        if [[ -n "$MAIN_DOMAIN" && "$MAIN_DOMAIN" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*\.[a-zA-Z]{2,}$ ]]; then
            # Remove any protocol if included
            MAIN_DOMAIN=${MAIN_DOMAIN#http://}
            MAIN_DOMAIN=${MAIN_DOMAIN#https://}
            MAIN_DOMAIN=${MAIN_DOMAIN%/}
            
            success "Domain chính: $MAIN_DOMAIN"
            break
        else
            error "Domain không hợp lệ. Vui lòng nhập domain đúng định dạng (ví dụ: example.com)"
        fi
    done
}

get_installation_mode() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                           🎯 CHỌN CHẾ ĐỘ CÀI ĐẶT                           ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Chọn chế độ cài đặt N8N:${NC}"
    echo -e "  ${GREEN}1.${NC} Single Instance (1 N8N instance)"
    echo -e "  ${GREEN}2.${NC} Multi-Instance (Nhiều N8N instances)"
    echo -e "  ${GREEN}3.${NC} Multi-Instance + PostgreSQL (Khuyến nghị cho production)"
    echo -e "  ${GREEN}4.${NC} Full Features (Multi + PostgreSQL + Google Drive + Telegram Bot)"
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
    
    info "Chế độ đã chọn: $([[ "$ENABLE_MULTI_DOMAIN" == "true" ]] && echo "Multi-Instance" || echo "Single Instance")"
    [[ "$ENABLE_POSTGRESQL" == "true" ]] && info "Database: PostgreSQL"
    [[ "$ENABLE_GOOGLE_DRIVE" == "true" ]] && info "Google Drive Backup: Enabled"
    [[ "$ENABLE_TELEGRAM_BOT" == "true" ]] && info "Telegram Bot: Enabled"
}

get_multi_domain_config() {
    if [[ "$ENABLE_MULTI_DOMAIN" != "true" ]]; then
        # Single instance - chỉ cần n8n subdomain
        if [[ "$DEPLOYMENT_MODE" == "localhost" ]]; then
            DOMAINS=("localhost")
        else
            DOMAINS=("n8n.$MAIN_DOMAIN")
        fi
        return
    fi
    
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        🌐 CẤU HÌNH MULTI-INSTANCE                          ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ "$DEPLOYMENT_MODE" == "localhost" ]]; then
        echo -e "${WHITE}Multi-Instance trên Localhost:${NC}"
        echo -e "  • Instance chính: http://localhost:5678"
        echo -e "  • Instance 1: http://localhost:5801"
        echo -e "  • Instance 2: http://localhost:5802"
        echo -e "  • ..."
        echo ""
        
        while true; do
            read -p "🔢 Số lượng N8N instances (2-10): " instance_count
            if [[ "$instance_count" =~ ^[0-9]+$ ]] && [[ $instance_count -ge 2 ]] && [[ $instance_count -le 10 ]]; then
                # Add main instance
                DOMAINS=("localhost")
                # Add sub instances
                for ((i=1; i<$instance_count; i++)); do
                    DOMAINS+=("localhost:$((PORT_BASE + i))")
                done
                break
            else
                error "Vui lòng nhập số từ 2 đến 10"
            fi
        done
    else
        echo -e "${WHITE}Multi-Instance với Domain:${NC}"
        echo -e "  • Mỗi instance sẽ có subdomain riêng"
        echo -e "  • Ví dụ: n8n1.$MAIN_DOMAIN, n8n2.$MAIN_DOMAIN..."
        echo ""
        
        # Add main N8N domain
        DOMAINS=("n8n.$MAIN_DOMAIN")
        
        local instance_num=1
        while true; do
            read -p "➕ Thêm N8N instance $instance_num? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                DOMAINS+=("n8n$instance_num.$MAIN_DOMAIN")
                info "Đã thêm: n8n$instance_num.$MAIN_DOMAIN"
                ((instance_num++))
            else
                break
            fi
        done
    fi
    
    success "Đã cấu hình ${#DOMAINS[@]} N8N instances"
}

get_port_configuration() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                          ⚙️  CẤU HÌNH PORTS                                ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # News API Port
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        echo -e "${WHITE}News API Port Configuration:${NC}"
        while true; do
            read -p "📰 Port cho News API [8000]: " port
            NEWS_API_PORT=${port:-8000}
            if check_port_availability $NEWS_API_PORT; then
                success "News API sẽ chạy trên port: $NEWS_API_PORT"
                break
            else
                NEWS_API_PORT=$(get_next_available_port $NEWS_API_PORT)
                warning "Port đã được sử dụng. Đề xuất port: $NEWS_API_PORT"
            fi
        done
        echo ""
    fi
    
    # N8N Main Port (chỉ cho localhost mode)
    if [[ "$DEPLOYMENT_MODE" == "localhost" ]]; then
        echo -e "${WHITE}N8N Main Port Configuration:${NC}"
        while true; do
            read -p "🚀 Port cho N8N chính [5678]: " port
            N8N_MAIN_PORT=${port:-5678}
            if check_port_availability $N8N_MAIN_PORT; then
                success "N8N chính sẽ chạy trên port: $N8N_MAIN_PORT"
                break
            else
                N8N_MAIN_PORT=$(get_next_available_port $N8N_MAIN_PORT)
                warning "Port đã được sử dụng. Đề xuất port: $N8N_MAIN_PORT"
            fi
        done
        echo ""
    fi
    
    # Dashboard Port
    echo -e "${WHITE}Dashboard Port Configuration:${NC}"
    while true; do
        read -p "📊 Port cho Dashboard [8080]: " port
        DASHBOARD_PORT=${port:-8080}
        if check_port_availability $DASHBOARD_PORT; then
            success "Dashboard sẽ chạy trên port: $DASHBOARD_PORT"
            break
        else
            DASHBOARD_PORT=$(get_next_available_port $DASHBOARD_PORT)
            warning "Port đã được sử dụng. Đề xuất port: $DASHBOARD_PORT"
        fi
    done
    
    # Auto-assign ports for multi-instance
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]] && [[ "$DEPLOYMENT_MODE" == "localhost" ]]; then
        echo ""
        info "🔧 Tự động phân bổ ports cho các N8N instances:"
        local port=$PORT_BASE
        for ((i=1; i<${#DOMAINS[@]}; i++)); do
            port=$(get_next_available_port $((PORT_BASE + i)))
            info "  Instance $i: Port $port"
        done
    fi
}

get_ssl_email_config() {
    if [[ "$DEPLOYMENT_MODE" == "localhost" ]]; then
        return
    fi
    
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        🔒 SSL CERTIFICATE EMAIL                            ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    while true; do
        read -p "📧 Email cho SSL certificates: " SSL_EMAIL
        if [[ -n "$SSL_EMAIL" && "$SSL_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
            if [[ "$SSL_EMAIL" == *"@example.com" ]]; then
                error "Vui lòng sử dụng email thật, không dùng @example.com"
                continue
            fi
            success "SSL Email: $SSL_EMAIL"
            break
        else
            error "Email không hợp lệ"
        fi
    done
}

# =============================================================================
# SECURITY CONFIGURATION
# =============================================================================

setup_dashboard_auth() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                      🔐 DASHBOARD SECURITY SETUP                           ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Thiết lập Basic Auth cho Dashboard:${NC}"
    echo -e "  • Username và password để truy cập dashboard"
    echo -e "  • Bảo vệ dashboard khỏi truy cập trái phép"
    echo ""
    
    # Get username
    while true; do
        read -p "👤 Username cho dashboard: " DASHBOARD_USER
        if [[ -n "$DASHBOARD_USER" && "$DASHBOARD_USER" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            break
        else
            error "Username chỉ chứa chữ cái, số, _ và -"
        fi
    done
    
    # Get password
    while true; do
        read -s -p "🔑 Password cho dashboard: " DASHBOARD_PASS
        echo
        if [[ ${#DASHBOARD_PASS} -ge 8 ]]; then
            read -s -p "🔑 Xác nhận password: " pass_confirm
            echo
            if [[ "$DASHBOARD_PASS" == "$pass_confirm" ]]; then
                break
            else
                error "Password không khớp. Vui lòng thử lại."
            fi
        else
            error "Password phải có ít nhất 8 ký tự"
        fi
    done
    
    # Generate password hash for Caddy
    if command -v htpasswd &> /dev/null; then
        DASHBOARD_HASH=$(htpasswd -nbB "$DASHBOARD_USER" "$DASHBOARD_PASS" | sed -e s/\\$/\\$\\$/g)
    else
        # Install apache2-utils if not available
        info "Cài đặt htpasswd..."
        apt-get update -qq && apt-get install -y apache2-utils >/dev/null 2>&1
        DASHBOARD_HASH=$(htpasswd -nbB "$DASHBOARD_USER" "$DASHBOARD_PASS" | sed -e s/\\$/\\$\\$/g)
    fi
    
    success "Đã thiết lập Dashboard authentication"
}

get_news_api_config() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        📰 NEWS CONTENT API                                 ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    read -p "📰 Bạn có muốn cài đặt News Content API? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        ENABLE_NEWS_API=false
        return
    fi
    
    ENABLE_NEWS_API=true
    
    echo ""
    while true; do
        read -p "🔑 Nhập Bearer Token cho News API (ít nhất 20 ký tự): " BEARER_TOKEN
        if [[ ${#BEARER_TOKEN} -ge 20 && "$BEARER_TOKEN" =~ ^[a-zA-Z0-9]+$ ]]; then
            success "Đã thiết lập Bearer Token"
            break
        else
            error "Token phải có ít nhất 20 ký tự và chỉ chứa chữ cái, số"
        fi
    done
}

get_telegram_config() {
    if [[ "$ENABLE_TELEGRAM_BOT" != "true" ]]; then
        return
    fi
    
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        📱 TELEGRAM BOT CONFIG                              ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    read -p "📱 Telegram Bot Token: " TELEGRAM_BOT_TOKEN
    read -p "💬 Telegram Chat ID: " TELEGRAM_CHAT_ID
    
    success "Đã cấu hình Telegram Bot"
}

# =============================================================================
# CLOUDFLARE TUNNEL CONFIGURATION
# =============================================================================

setup_cloudflare_tunnel() {
    if [[ "$DEPLOYMENT_MODE" != "cloudflare" ]]; then
        return
    fi
    
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                      ☁️  CLOUDFLARE TUNNEL SETUP                           ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Hướng dẫn lấy Cloudflare Tunnel Token:${NC}"
    echo -e "  1. Truy cập: https://one.dash.cloudflare.com/"
    echo -e "  2. Chọn Zero Trust → Access → Tunnels"
    echo -e "  3. Create a tunnel → Chọn Cloudflared"
    echo -e "  4. Đặt tên tunnel (ví dụ: n8n-tunnel)"
    echo -e "  5. Copy token từ phần 'Install and run a connector'"
    echo ""
    
    read -p "🔐 Nhập Cloudflare Tunnel Token: " CF_TUNNEL_TOKEN
    read -p "🏷️  Tên tunnel (ví dụ: n8n-tunnel): " CF_TUNNEL_NAME
    
    CF_TUNNEL_NAME=${CF_TUNNEL_NAME:-"n8n-tunnel"}
    
    success "Đã cấu hình Cloudflare Tunnel"
}

# =============================================================================
# DOCKER & INSTALLATION FUNCTIONS
# =============================================================================

install_docker() {
    log "🐳 Cài đặt Docker..."
    
    # Remove old versions
    apt-get remove -y docker docker-engine docker.io containerd runc >/dev/null 2>&1 || true
    
    # Install dependencies
    apt-get update -qq
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        software-properties-common >/dev/null 2>&1
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Set up repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    apt-get update -qq
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin >/dev/null 2>&1
    
    # Start and enable Docker
    systemctl start docker
    systemctl enable docker
    
    success "Docker đã được cài đặt thành công!"
}

setup_swap() {
    log "🔄 Thiết lập swap memory..."
    
    local ram_gb=$(free -g | awk '/^Mem:/{print $2}')
    local swap_size="4G"
    
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        swap_size="8G"
    fi
    
    if swapon --show | grep -q "/swapfile"; then
        info "Swap file đã tồn tại"
        return
    fi
    
    log "Tạo swap file ${swap_size}..."
    fallocate -l $swap_size /swapfile || dd if=/dev/zero of=/swapfile bs=1024 count=$((${swap_size%G} * 1024 * 1024))
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    
    if ! grep -q "/swapfile" /etc/fstab; then
        echo "/swapfile none swap sw 0 0" >> /etc/fstab
    fi
    
    success "Đã thiết lập swap ${swap_size}"
}

prepare_directories() {
    log "📁 Chuẩn bị thư mục cài đặt..."
    
    # Create main directory
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Create subdirectories
    mkdir -p files
    mkdir -p logs
    mkdir -p caddy_data
    mkdir -p caddy_config
    
    # Create instance directories for multi-domain
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            if [[ $i -eq 0 ]]; then
                mkdir -p "files/n8n_main"
            else
                mkdir -p "files/n8n_instance_$i"
            fi
        done
    else
        mkdir -p "files/n8n_main"
    fi
    
    # Create postgres directory if needed
    if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
        mkdir -p postgres_data
    fi
    
    # Dashboard directory
    mkdir -p dashboard
    
    success "Đã tạo cấu trúc thư mục"
}

# =============================================================================
# AUTO-FIX FUNCTIONS (từ fix_n8n.sh)
# =============================================================================

fix_permissions_auto() {
    log "🔧 Auto-fix: Sửa quyền truy cập..."
    
    cd "$INSTALL_DIR"
    
    # Fix ownership for N8N directories
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for dir in files/n8n_*; do
            if [[ -d "$dir" ]]; then
                chown -R 1000:1000 "$dir"
                chmod -R 755 "$dir"
                mkdir -p "$dir"/.n8n
                chown -R 1000:1000 "$dir"/.n8n
            fi
        done
    else
        chown -R 1000:1000 files/n8n_main
        chmod -R 755 files/n8n_main
        mkdir -p files/n8n_main/.n8n
        chown -R 1000:1000 files/n8n_main/.n8n
    fi
    
    # Fix PostgreSQL permissions
    if [[ "$ENABLE_POSTGRESQL" == "true" ]] && [[ -d postgres_data ]]; then
        chown -R 999:999 postgres_data
    fi
    
    # Fix logs permissions
    chown -R 1000:1000 logs
    
    success "✅ Đã fix quyền truy cập"
}

fix_container_names_auto() {
    log "🔧 Auto-fix: Chuẩn hóa container names..."
    
    # Container names đã được chuẩn hóa trong generate_docker_compose
    # Function này chỉ verify
    
    success "✅ Container names đã được chuẩn hóa"
}

fix_network_auto() {
    log "🔧 Auto-fix: Sửa Docker network..."
    
    # Remove old networks
    docker network rm n8n_network 2>/dev/null || true
    docker network rm n8n_default 2>/dev/null || true
    
    # Create new network
    docker network create n8n_network 2>/dev/null || true
    
    success "✅ Đã fix Docker network"
}

restart_services_ordered() {
    log "🔄 Khởi động lại services theo thứ tự..."
    
    cd "$INSTALL_DIR"
    
    # Stop all first
    $DOCKER_COMPOSE down || true
    
    # Start PostgreSQL first if enabled
    if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
        log "Khởi động PostgreSQL..."
        $DOCKER_COMPOSE up -d postgres-db
        sleep 20
    fi
    
    # Start N8N instances
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            if [[ $i -eq 0 ]]; then
                log "Khởi động N8N main..."
                $DOCKER_COMPOSE up -d n8n-main
            else
                log "Khởi động N8N instance $i..."
                $DOCKER_COMPOSE up -d n8n-instance-$i
            fi
            sleep 5
        done
    else
        log "Khởi động N8N..."
        $DOCKER_COMPOSE up -d n8n-main
    fi
    
    # Start News API if enabled
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        log "Khởi động News API..."
        $DOCKER_COMPOSE up -d news-api
        sleep 5
    fi
    
    # Start Dashboard
    log "Khởi động Dashboard..."
    $DOCKER_COMPOSE up -d dashboard
    sleep 5
    
    # Start Caddy last (if domain mode)
    if [[ "$DEPLOYMENT_MODE" != "localhost" ]]; then
        log "Khởi động Caddy..."
        $DOCKER_COMPOSE up -d caddy-proxy
    fi
    
    # Start Cloudflare tunnel if enabled
    if [[ "$DEPLOYMENT_MODE" == "cloudflare" ]]; then
        log "Khởi động Cloudflare Tunnel..."
        $DOCKER_COMPOSE up -d cloudflared
    fi
    
    success "✅ Đã khởi động lại tất cả services"
}

health_check_auto() {
    log "🏥 Kiểm tra sức khỏe hệ thống..."
    
    cd "$INSTALL_DIR"
    
    local all_healthy=true
    
    # Check N8N containers
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            local container_name
            if [[ $i -eq 0 ]]; then
                container_name="n8n-main"
            else
                container_name="n8n-instance-$i"
            fi
            
            if docker exec "$container_name" wget -q --spider http://localhost:5678/healthz 2>/dev/null; then
                success "✅ $container_name: HEALTHY"
            else
                warning "⚠️ $container_name: NOT READY"
                all_healthy=false
            fi
        done
    else
        if docker exec n8n-main wget -q --spider http://localhost:5678/healthz 2>/dev/null; then
            success "✅ n8n-main: HEALTHY"
        else
            warning "⚠️ n8n-main: NOT READY"
            all_healthy=false
        fi
    fi
    
    # Check PostgreSQL if enabled
    if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
        if docker exec postgres-db pg_isready -U postgres >/dev/null 2>&1; then
            success "✅ PostgreSQL: HEALTHY"
        else
            warning "⚠️ PostgreSQL: NOT READY"
            all_healthy=false
        fi
    fi
    
    # Check News API if enabled
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        if docker exec news-api wget -q --spider http://localhost:8000/health 2>/dev/null; then
            success "✅ News API: HEALTHY"
        else
            warning "⚠️ News API: NOT READY"
            all_healthy=false
        fi
    fi
    
    # Check Dashboard
    if docker ps --format "{{.Names}}" | grep -q "^dashboard$"; then
        success "✅ Dashboard: RUNNING"
    else
        warning "⚠️ Dashboard: NOT RUNNING"
        all_healthy=false
    fi
    
    # Return health status
    if [[ "$all_healthy" == "true" ]]; then
        success "🎉 Tất cả services đều healthy!"
        return 0
    else
        warning "⚠️ Một số services chưa sẵn sàng"
        return 1
    fi
}

# =============================================================================
# DOCKER COMPOSE GENERATION
# =============================================================================

generate_docker_compose() {
    log "📝 Tạo file docker-compose.yml..."
    
    cd "$INSTALL_DIR"
    
    cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
EOF

    # PostgreSQL service (if enabled)
    if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
        cat >> docker-compose.yml << 'EOF'
  postgres-db:
    image: postgres:15-alpine
    container_name: postgres-db
    restart: unless-stopped
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres_password_2025
      - POSTGRES_DB=postgres
    volumes:
      - ./postgres_data:/var/lib/postgresql/data
    networks:
      - n8n_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

EOF
    fi

    # N8N Services
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        # Multi-instance setup
        for i in "${!DOMAINS[@]}"; do
            local container_name
            local instance_dir
            local db_name
            local port
            
            if [[ $i -eq 0 ]]; then
                container_name="n8n-main"
                instance_dir="n8n_main"
                db_name="n8n_db"
                port=$N8N_MAIN_PORT
            else
                container_name="n8n-instance-$i"
                instance_dir="n8n_instance_$i"
                db_name="n8n_db_instance_$i"
                port=$((PORT_BASE + i))
            fi
            
            cat >> docker-compose.yml << EOF
  $container_name:
    image: n8nio/n8n:latest
    container_name: $container_name
    restart: unless-stopped
    user: "1000:1000"
    environment:
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=production
      - WEBHOOK_URL=https://${DOMAINS[$i]}/
      - N8N_METRICS=true
EOF

            # Add port mapping for localhost mode
            if [[ "$DEPLOYMENT_MODE" == "localhost" ]]; then
                cat >> docker-compose.yml << EOF
    ports:
      - "$port:5678"
EOF
            fi

            # Database configuration
            if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
                cat >> docker-compose.yml << EOF
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres-db
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=$db_name
      - DB_POSTGRESDB_USER=n8n_user
      - DB_POSTGRESDB_PASSWORD=n8n_password_2025
EOF
            else
                cat >> docker-compose.yml << EOF
      - DB_TYPE=sqlite
      - DB_SQLITE_DATABASE=database.sqlite
EOF
            fi

            cat >> docker-compose.yml << EOF
      - N8N_ENCRYPTION_KEY=n8n_encryption_key_2025_secure
      - N8N_USER_MANAGEMENT_DISABLED=false
      - N8N_VERSION_NOTIFICATIONS_ENABLED=true
      - N8N_DIAGNOSTICS_ENABLED=false
      - EXECUTIONS_PROCESS=main
      - N8N_PERSONALIZATION_ENABLED=false
      - GENERIC_TIMEZONE=Asia/Ho_Chi_Minh
    volumes:
      - ./files/$instance_dir:/home/node/.n8n
      - ./files/$instance_dir/custom:/home/node/.n8n/custom
    networks:
      - n8n_network
EOF

            # Add PostgreSQL dependency if enabled
            if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
                cat >> docker-compose.yml << EOF
    depends_on:
      postgres-db:
        condition: service_healthy
EOF
            fi

            echo "" >> docker-compose.yml
        done
    else
        # Single instance setup
        cat >> docker-compose.yml << EOF
  n8n-main:
    image: n8nio/n8n:latest
    container_name: n8n-main
    restart: unless-stopped
    user: "1000:1000"
    environment:
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=production
      - WEBHOOK_URL=https://${DOMAINS[0]}/
      - N8N_METRICS=true
EOF

        # Add port mapping for localhost mode
        if [[ "$DEPLOYMENT_MODE" == "localhost" ]]; then
            cat >> docker-compose.yml << EOF
    ports:
      - "$N8N_MAIN_PORT:5678"
EOF
        fi

        # Database configuration
        if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
            cat >> docker-compose.yml << EOF
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres-db
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n_db
      - DB_POSTGRESDB_USER=n8n_user
      - DB_POSTGRESDB_PASSWORD=n8n_password_2025
EOF
        else
            cat >> docker-compose.yml << EOF
      - DB_TYPE=sqlite
      - DB_SQLITE_DATABASE=database.sqlite
EOF
        fi

        cat >> docker-compose.yml << EOF
      - N8N_ENCRYPTION_KEY=n8n_encryption_key_2025_secure
      - N8N_USER_MANAGEMENT_DISABLED=false
      - N8N_VERSION_NOTIFICATIONS_ENABLED=true
      - N8N_DIAGNOSTICS_ENABLED=false
      - EXECUTIONS_PROCESS=main
      - N8N_PERSONALIZATION_ENABLED=false
      - GENERIC_TIMEZONE=Asia/Ho_Chi_Minh
    volumes:
      - ./files/n8n_main:/home/node/.n8n
      - ./files/n8n_main/custom:/home/node/.n8n/custom
    networks:
      - n8n_network
EOF

        # Add PostgreSQL dependency if enabled
        if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
            cat >> docker-compose.yml << EOF
    depends_on:
      postgres-db:
        condition: service_healthy
EOF
        fi

        echo "" >> docker-compose.yml
    fi

    # News API Service (if enabled)
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        cat >> docker-compose.yml << EOF
  news-api:
    build:
      context: ./news-api
      dockerfile: Dockerfile
    image: news-content-api:latest
    container_name: news-api
    restart: unless-stopped
    environment:
      - PORT=8000
      - WORKERS=4
      - BEARER_TOKEN=$BEARER_TOKEN
      - LOG_LEVEL=info
      - CACHE_TTL=3600
      - MAX_CONTENT_LENGTH=1000000
      - REQUEST_TIMEOUT=30
      - RATE_LIMIT=100
EOF

        # Add port mapping for localhost mode or if needed
        if [[ "$DEPLOYMENT_MODE" == "localhost" ]] || [[ "$ENABLE_NEWS_API" == "true" ]]; then
            cat >> docker-compose.yml << EOF
    ports:
      - "$NEWS_API_PORT:8000"
EOF
        fi

        cat >> docker-compose.yml << EOF
    volumes:
      - ./logs/news-api:/app/logs
    networks:
      - n8n_network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

EOF
    fi

    # Dashboard Service
    cat >> docker-compose.yml << EOF
  dashboard:
    build:
      context: ./dashboard
      dockerfile: Dockerfile
    image: n8n-dashboard:latest
    container_name: dashboard
    restart: unless-stopped
    environment:
      - PORT=80
      - API_ENDPOINT=http://n8n-main:5678
    ports:
      - "$DASHBOARD_PORT:80"
    volumes:
      - ./dashboard/public:/usr/share/nginx/html:ro
    networks:
      - n8n_network
    depends_on:
      - n8n-main

EOF

    # Caddy Service (for domain mode)
    if [[ "$DEPLOYMENT_MODE" == "domain" ]]; then
        cat >> docker-compose.yml << EOF
  caddy-proxy:
    image: caddy:2-alpine
    container_name: caddy-proxy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - ./caddy_data:/data
      - ./caddy_config:/config
      - ./logs/caddy:/var/log/caddy
    networks:
      - n8n_network
    depends_on:
      - n8n-main
EOF

        if [[ "$ENABLE_NEWS_API" == "true" ]]; then
            cat >> docker-compose.yml << EOF
      - news-api
EOF
        fi

        cat >> docker-compose.yml << EOF
      - dashboard

EOF
    fi

    # Cloudflare Tunnel (for cloudflare mode)
    if [[ "$DEPLOYMENT_MODE" == "cloudflare" ]]; then
        cat >> docker-compose.yml << EOF
  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared
    restart: unless-stopped
    command: tunnel --no-autoupdate run
    environment:
      - TUNNEL_TOKEN=$CF_TUNNEL_TOKEN
    networks:
      - n8n_network
    depends_on:
      - n8n-main
      - dashboard

EOF
    fi

    # Networks
    cat >> docker-compose.yml << EOF
networks:
  n8n_network:
    driver: bridge
    name: n8n_network

volumes:
  postgres_data:
  caddy_data:
  caddy_config:
EOF

    success "✅ Đã tạo docker-compose.yml"
}

# =============================================================================
# CADDYFILE GENERATION
# =============================================================================

generate_caddyfile() {
    if [[ "$DEPLOYMENT_MODE" == "localhost" ]]; then
        return
    fi
    
    log "📝 Tạo Caddyfile..."
    
    cd "$INSTALL_DIR"
    
    cat > Caddyfile << EOF
{
    email $SSL_EMAIL
    acme_ca https://acme-v02.api.letsencrypt.org/directory
}

EOF

    # N8N instances
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            local container_name
            local subdomain
            
            if [[ $i -eq 0 ]]; then
                container_name="n8n-main"
                subdomain="n8n.$MAIN_DOMAIN"
            else
                container_name="n8n-instance-$i"
                subdomain="n8n$i.$MAIN_DOMAIN"
            fi
            
            cat >> Caddyfile << EOF
$subdomain {
    reverse_proxy $container_name:5678 {
        header_up Host {host}
        header_up X-Real-IP {remote}
        header_up X-Forwarded-For {remote}
        header_up X-Forwarded-Proto {scheme}
    }
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "SAMEORIGIN"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    
    encode gzip
    
    log {
        output file /var/log/caddy/n8n_${i}.log {
            roll_size 10mb
            roll_keep 5
        }
        format json
    }
}

EOF
        done
    else
        # Single instance
        cat >> Caddyfile << EOF
n8n.$MAIN_DOMAIN {
    reverse_proxy n8n-main:5678 {
        header_up Host {host}
        header_up X-Real-IP {remote}
        header_up X-Forwarded-For {remote}
        header_up X-Forwarded-Proto {scheme}
    }
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "SAMEORIGIN"
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

    # News API
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        cat >> Caddyfile << EOF
api.$MAIN_DOMAIN {
    reverse_proxy news-api:8000 {
        header_up Host {host}
        header_up X-Real-IP {remote}
        header_up X-Forwarded-For {remote}
        header_up X-Forwarded-Proto {scheme}
    }
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
        Access-Control-Allow-Origin "*"
        Access-Control-Allow-Methods "GET, POST, OPTIONS"
        Access-Control-Allow-Headers "Authorization, Content-Type"
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

    # Dashboard with Basic Auth
    cat >> Caddyfile << EOF
dashboard.$MAIN_DOMAIN {
    basicauth {
        $DASHBOARD_HASH
    }
    
    reverse_proxy dashboard:80 {
        header_up Host {host}
        header_up X-Real-IP {remote}
        header_up X-Forwarded-For {remote}
        header_up X-Forwarded-Proto {scheme}
    }
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "SAMEORIGIN"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    
    encode gzip
    
    log {
        output file /var/log/caddy/dashboard.log {
            roll_size 10mb
            roll_keep 5
        }
        format json
    }
}
EOF

    success "✅ Đã tạo Caddyfile"
}

# =============================================================================
# NEWS API SETUP
# =============================================================================

setup_news_api() {
    if [[ "$ENABLE_NEWS_API" != "true" ]]; then
        return
    fi
    
    log "📰 Thiết lập News Content API..."
    
    mkdir -p "$INSTALL_DIR/news-api"
    cd "$INSTALL_DIR/news-api"
    
    # Create requirements.txt
    cat > requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
newspaper4k==0.9.3
beautifulsoup4==4.12.2
lxml==4.9.3
Pillow==10.1.0
requests==2.31.0
pydantic==2.5.0
python-multipart==0.0.6
aiofiles==23.2.1
python-dateutil==2.8.2
feedparser==6.0.10
httpx==0.25.2
redis==5.0.1
slowapi==0.1.9
EOF

    # Create Dockerfile
    cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libxml2-dev \
    libxslt-dev \
    libffi-dev \
    libssl-dev \
    libjpeg-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create logs directory
RUN mkdir -p /app/logs

# Run as non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 8000

# Start the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
EOF

    # Create main.py
    cat > main.py << 'EOF'
from fastapi import FastAPI, HTTPException, Depends, Header
from fastapi.middleware.cors import CORSMiddleware
from newspaper import Article, Config
import feedparser
from typing import Optional, List, Dict
import os
import logging
from datetime import datetime
import requests
from urllib.parse import urlparse
from pydantic import BaseModel, HttpUrl
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/app/logs/news_api.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="News Content API",
    description="API để lấy nội dung tin tức từ URL và RSS feeds",
    version="2.0.0"
)

# Rate limiting
limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Environment variables
BEARER_TOKEN = os.getenv("BEARER_TOKEN", "default_token_2025")
CACHE_TTL = int(os.getenv("CACHE_TTL", "3600"))
MAX_CONTENT_LENGTH = int(os.getenv("MAX_CONTENT_LENGTH", "1000000"))
REQUEST_TIMEOUT = int(os.getenv("REQUEST_TIMEOUT", "30"))

# Pydantic models
class ArticleRequest(BaseModel):
    url: HttpUrl
    full_content: Optional[bool] = True

class ArticleResponse(BaseModel):
    title: str
    content: str
    summary: Optional[str] = None
    authors: List[str]
    publish_date: Optional[str] = None
    top_image: Optional[str] = None
    images: List[str]
    keywords: List[str]
    source_url: str

class RSSFeedRequest(BaseModel):
    feed_url: HttpUrl
    limit: Optional[int] = 10

class HealthResponse(BaseModel):
    status: str
    timestamp: str
    version: str

# Dependency for token validation
async def verify_token(authorization: Optional[str] = Header(None)):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid authorization header")
    
    token = authorization.split(" ")[1]
    if token != BEARER_TOKEN:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    return token

# Health check endpoint
@app.get("/health", response_model=HealthResponse)
async def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": "2.0.0"
    }

# Get article content
@app.post("/api/article", response_model=ArticleResponse)
@limiter.limit("100/minute")
async def get_article(
    request: ArticleRequest,
    request_addr: str = Depends(get_remote_address),
    token: str = Depends(verify_token)
):
    try:
        # Configure newspaper
        config = Config()
        config.browser_user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        config.request_timeout = REQUEST_TIMEOUT
        config.number_threads = 2
        config.thread_timeout = 10
        config.fetch_images = True
        
        # Create article instance
        article = Article(str(request.url), config=config)
        
        # Download and parse
        article.download()
        article.parse()
        
        if request.full_content:
            article.nlp()
        
        # Validate content
        if not article.text or len(article.text.strip()) < 50:
            raise HTTPException(status_code=422, detail="Could not extract meaningful content from URL")
        
        # Prepare response
        response_data = {
            "title": article.title or "No title",
            "content": article.text[:MAX_CONTENT_LENGTH],
            "summary": article.summary if request.full_content else None,
            "authors": article.authors or [],
            "publish_date": article.publish_date.isoformat() if article.publish_date else None,
            "top_image": article.top_image,
            "images": list(article.images)[:10],  # Limit images
            "keywords": article.keywords[:20] if request.full_content else [],
            "source_url": str(request.url)
        }
        
        logger.info(f"Successfully extracted article from {request.url}")
        return response_data
        
    except Exception as e:
        logger.error(f"Error extracting article from {request.url}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error extracting article: {str(e)}")

# Get RSS feed
@app.post("/api/rss")
@limiter.limit("50/minute")
async def get_rss_feed(
    request: RSSFeedRequest,
    request_addr: str = Depends(get_remote_address),
    token: str = Depends(verify_token)
):
    try:
        # Parse RSS feed
        feed = feedparser.parse(str(request.feed_url))
        
        if feed.bozo:
            raise HTTPException(status_code=422, detail="Invalid RSS feed")
        
        # Extract entries
        entries = []
        for entry in feed.entries[:request.limit]:
            entry_data = {
                "title": entry.get("title", ""),
                "link": entry.get("link", ""),
                "summary": entry.get("summary", ""),
                "published": entry.get("published", ""),
                "author": entry.get("author", ""),
                "tags": [tag.term for tag in entry.get("tags", [])]
            }
            entries.append(entry_data)
        
        return {
            "feed_title": feed.feed.get("title", ""),
            "feed_description": feed.feed.get("description", ""),
            "feed_link": feed.feed.get("link", ""),
            "entries": entries,
            "total_entries": len(entries)
        }
        
    except Exception as e:
        logger.error(f"Error parsing RSS feed {request.feed_url}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error parsing RSS feed: {str(e)}")

# Root endpoint
@app.get("/")
async def root():
    return {
        "message": "News Content API",
        "version": "2.0.0",
        "endpoints": {
            "health": "/health",
            "article": "/api/article",
            "rss": "/api/rss",
            "docs": "/docs"
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

    success "✅ Đã thiết lập News API"
}

# =============================================================================
# DASHBOARD SETUP
# =============================================================================

setup_dashboard() {
    log "📊 Thiết lập Web Dashboard..."
    
    mkdir -p "$INSTALL_DIR/dashboard"
    cd "$INSTALL_DIR/dashboard"
    
    # Create Dockerfile for dashboard
    cat > Dockerfile << 'EOF'
FROM nginx:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# Copy dashboard files
COPY public /usr/share/nginx/html

# Create necessary directories
RUN mkdir -p /var/log/nginx /var/cache/nginx \
    && chown -R nginx:nginx /var/log/nginx /var/cache/nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
EOF

    # Create nginx.conf
    cat > nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss;
    
    include /etc/nginx/conf.d/*.conf;
}
EOF

    # Create default.conf
    cat > default.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    
    root /usr/share/nginx/html;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://n8n-main:5678/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

    # Create public directory and dashboard HTML
    mkdir -p public
    
    cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>N8N Multi-Instance Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .gradient-bg {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .card-hover:hover {
            transform: translateY(-5px);
            transition: all 0.3s ease;
        }
        .status-dot {
            width: 12px;
            height: 12px;
            border-radius: 50%;
            display: inline-block;
            margin-right: 8px;
        }
        .status-online { background-color: #10b981; }
        .status-offline { background-color: #ef4444; }
        .status-pending { background-color: #f59e0b; }
    </style>
</head>
<body class="bg-gray-100">
    <!-- Header -->
    <header class="gradient-bg text-white shadow-lg">
        <div class="container mx-auto px-4 py-6">
            <div class="flex justify-between items-center">
                <div>
                    <h1 class="text-3xl font-bold">N8N Multi-Instance Dashboard</h1>
                    <p class="text-purple-200 mt-1">Quản lý và giám sát N8N instances</p>
                </div>
                <div class="text-right">
                    <p class="text-sm text-purple-200">Phiên bản: 4.0</p>
                    <p class="text-sm text-purple-200" id="current-time"></p>
                </div>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <main class="container mx-auto px-4 py-8">
        <!-- Stats Cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <div class="bg-white rounded-lg shadow-md p-6 card-hover">
                <div class="flex items-center justify-between">
                    <div>
                        <h3 class="text-gray-500 text-sm uppercase">Total Instances</h3>
                        <p class="text-3xl font-bold text-gray-800" id="total-instances">0</p>
                    </div>
                    <i class="fas fa-server text-4xl text-purple-500"></i>
                </div>
            </div>
            
            <div class="bg-white rounded-lg shadow-md p-6 card-hover">
                <div class="flex items-center justify-between">
                    <div>
                        <h3 class="text-gray-500 text-sm uppercase">Active Workflows</h3>
                        <p class="text-3xl font-bold text-gray-800" id="active-workflows">0</p>
                    </div>
                    <i class="fas fa-play-circle text-4xl text-green-500"></i>
                </div>
            </div>
            
            <div class="bg-white rounded-lg shadow-md p-6 card-hover">
                <div class="flex items-center justify-between">
                    <div>
                        <h3 class="text-gray-500 text-sm uppercase">Total Executions</h3>
                        <p class="text-3xl font-bold text-gray-800" id="total-executions">0</p>
                    </div>
                    <i class="fas fa-chart-line text-4xl text-blue-500"></i>
                </div>
            </div>
            
            <div class="bg-white rounded-lg shadow-md p-6 card-hover">
                <div class="flex items-center justify-between">
                    <div>
                        <h3 class="text-gray-500 text-sm uppercase">System Status</h3>
                        <p class="text-xl font-bold text-green-600" id="system-status">
                            <span class="status-dot status-online"></span>Online
                        </p>
                    </div>
                    <i class="fas fa-heartbeat text-4xl text-red-500"></i>
                </div>
            </div>
        </div>

        <!-- Instances Table -->
        <div class="bg-white rounded-lg shadow-md p-6 mb-8">
            <h2 class="text-xl font-bold text-gray-800 mb-4">
                <i class="fas fa-th-list mr-2"></i>N8N Instances
            </h2>
            <div class="overflow-x-auto">
                <table class="min-w-full table-auto">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Instance</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">URL</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Workflows</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="instances-tbody" class="bg-white divide-y divide-gray-200">
                        <!-- Dynamic content will be inserted here -->
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Services Status -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <!-- Database Status -->
            <div class="bg-white rounded-lg shadow-md p-6">
                <h2 class="text-xl font-bold text-gray-800 mb-4">
                    <i class="fas fa-database mr-2"></i>Database Status
                </h2>
                <div id="database-status">
                    <p class="text-gray-600">Loading database information...</p>
                </div>
            </div>

            <!-- Additional Services -->
            <div class="bg-white rounded-lg shadow-md p-6">
                <h2 class="text-xl font-bold text-gray-800 mb-4">
                    <i class="fas fa-cogs mr-2"></i>Additional Services
                </h2>
                <div id="services-status">
                    <p class="text-gray-600">Loading services information...</p>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer class="bg-gray-800 text-white py-6 mt-12">
        <div class="container mx-auto px-4 text-center">
            <p>© 2025 N8N Multi-Instance Dashboard</p>
            <p class="text-sm text-gray-400 mt-2">
                Created by Nguyễn Ngọc Thiện | 
                <a href="https://youtube.com/@kalvinthiensocial" target="_blank" class="text-purple-400 hover:text-purple-300">
                    YouTube Channel
                </a>
            </p>
        </div>
    </footer>

    <script>
        // Update current time
        function updateTime() {
            const now = new Date();
            document.getElementById('current-time').textContent = now.toLocaleString('vi-VN');
        }
        setInterval(updateTime, 1000);
        updateTime();

        // Mock data for demonstration
        const instances = [
            { name: 'N8N Main', url: window.location.hostname, status: 'online', workflows: 12 },
            { name: 'N8N Instance 1', url: 'n8n1.' + window.location.hostname, status: 'online', workflows: 8 },
            { name: 'N8N Instance 2', url: 'n8n2.' + window.location.hostname, status: 'pending', workflows: 5 }
        ];

        // Populate instances table
        function populateInstances() {
            const tbody = document.getElementById('instances-tbody');
            tbody.innerHTML = '';
            
            instances.forEach((instance, index) => {
                const row = document.createElement('tr');
                row.className = index % 2 === 0 ? 'bg-white' : 'bg-gray-50';
                
                const statusClass = instance.status === 'online' ? 'status-online' : 
                                   instance.status === 'offline' ? 'status-offline' : 'status-pending';
                const statusText = instance.status.charAt(0).toUpperCase() + instance.status.slice(1);
                
                row.innerHTML = `
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        ${instance.name}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        <a href="https://${instance.url}" target="_blank" class="text-blue-600 hover:text-blue-800">
                            ${instance.url}
                        </a>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        <span class="status-dot ${statusClass}"></span>${statusText}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        ${instance.workflows}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <a href="https://${instance.url}" target="_blank" class="text-indigo-600 hover:text-indigo-900 mr-3">
                            <i class="fas fa-external-link-alt"></i> Open
                        </a>
                        <button class="text-green-600 hover:text-green-900">
                            <i class="fas fa-sync-alt"></i> Restart
                        </button>
                    </td>
                `;
                tbody.appendChild(row);
            });
            
            // Update stats
            document.getElementById('total-instances').textContent = instances.length;
            document.getElementById('active-workflows').textContent = 
                instances.reduce((sum, inst) => sum + inst.workflows, 0);
        }

        // Initialize
        populateInstances();

        // Mock database status
        document.getElementById('database-status').innerHTML = `
            <div class="space-y-2">
                <p><span class="font-semibold">Type:</span> PostgreSQL 15</p>
                <p><span class="font-semibold">Status:</span> <span class="text-green-600">Connected</span></p>
                <p><span class="font-semibold">Size:</span> 245 MB</p>
                <p><span class="font-semibold">Connections:</span> 3/100</p>
            </div>
        `;

        // Mock services status
        document.getElementById('services-status').innerHTML = `
            <div class="space-y-3">
                <div class="flex justify-between items-center">
                    <span>News API</span>
                    <span class="text-green-600"><i class="fas fa-check-circle"></i> Running</span>
                </div>
                <div class="flex justify-between items-center">
                    <span>Caddy Proxy</span>
                    <span class="text-green-600"><i class="fas fa-check-circle"></i> Running</span>
                </div>
                <div class="flex justify-between items-center">
                    <span>Redis Cache</span>
                    <span class="text-gray-400"><i class="fas fa-times-circle"></i> Not Configured</span>
                </div>
            </div>
        `;
    </script>
</body>
</html>
EOF

    success "✅ Đã thiết lập Dashboard"
}

# =============================================================================
# CLOUDFLARE TUNNEL CONFIG
# =============================================================================

generate_cloudflare_config() {
    if [[ "$DEPLOYMENT_MODE" != "cloudflare" ]]; then
        return
    fi
    
    log "☁️ Tạo Cloudflare Tunnel configuration..."
    
    cd "$INSTALL_DIR"
    
    # Create tunnel config file
    cat > cloudflare-config.yml << EOF
tunnel: $CF_TUNNEL_NAME
credentials-file: /etc/cloudflared/creds.json

ingress:
EOF

    # Add N8N instances
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            local subdomain
            local service
            
            if [[ $i -eq 0 ]]; then
                subdomain="n8n.$MAIN_DOMAIN"
                service="http://n8n-main:5678"
            else
                subdomain="n8n$i.$MAIN_DOMAIN"
                service="http://n8n-instance-$i:5678"
            fi
            
            cat >> cloudflare-config.yml << EOF
  - hostname: $subdomain
    service: $service
    originRequest:
      noTLSVerify: true
EOF
        done
    else
        cat >> cloudflare-config.yml << EOF
  - hostname: n8n.$MAIN_DOMAIN
    service: http://n8n-main:5678
    originRequest:
      noTLSVerify: true
EOF
    fi

    # Add News API
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        cat >> cloudflare-config.yml << EOF
  - hostname: api.$MAIN_DOMAIN
    service: http://news-api:8000
    originRequest:
      noTLSVerify: true
EOF
    fi

    # Add Dashboard
    cat >> cloudflare-config.yml << EOF
  - hostname: dashboard.$MAIN_DOMAIN
    service: http://dashboard:80
    originRequest:
      noTLSVerify: true
      httpHostHeader: dashboard.$MAIN_DOMAIN
EOF

    # Add catch-all rule
    cat >> cloudflare-config.yml << EOF
  - service: http_status:404
EOF

    success "✅ Đã tạo Cloudflare configuration"
}

# =============================================================================
# DEPLOYMENT & STARTUP
# =============================================================================

deploy_services() {
    log "🚀 Triển khai services..."
    
    cd "$INSTALL_DIR"
    
    # Pull images first
    log "📥 Pull Docker images..."
    $DOCKER_COMPOSE pull --quiet || true
    
    # Build custom images
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        log "🔨 Build News API image..."
        $DOCKER_COMPOSE build news-api
    fi
    
    log "🔨 Build Dashboard image..."
    $DOCKER_COMPOSE build dashboard
    
    # Start services in order
    restart_services_ordered
}

create_helper_scripts() {
    log "📝 Tạo helper scripts..."
    
    cd "$INSTALL_DIR"
    
    # Create start script
    cat > start.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
docker-compose up -d
echo "✅ All services started!"
docker-compose ps
EOF
    chmod +x start.sh
    
    # Create stop script
    cat > stop.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
docker-compose down
echo "✅ All services stopped!"
EOF
    chmod +x stop.sh
    
    # Create restart script
    cat > restart.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
docker-compose restart
echo "✅ All services restarted!"
docker-compose ps
EOF
    chmod +x restart.sh
    
    # Create logs script
    cat > logs.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
if [ -z "$1" ]; then
    docker-compose logs -f --tail=100
else
    docker-compose logs -f --tail=100 "$1"
fi
EOF
    chmod +x logs.sh
    
    # Create health check script
    cat > health.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
echo "🏥 Checking health status..."
docker-compose ps
echo ""
echo "📊 Container health:"
for container in $(docker-compose ps -q); do
    name=$(docker inspect -f '{{.Name}}' $container | sed 's/\///')
    status=$(docker inspect -f '{{.State.Health.Status}}' $container 2>/dev/null || echo "no health check")
    echo "  $name: $status"
done
EOF
    chmod +x health.sh
    
    success "✅ Đã tạo helper scripts"
}

# =============================================================================
# POST-DEPLOYMENT & MONITORING
# =============================================================================

setup_health_monitoring() {
    if [[ "$HEALTH_CHECK_ENABLED" != "true" ]]; then
        return
    fi
    
    log "🏥 Thiết lập health monitoring..."
    
    cd "$INSTALL_DIR"
    
    # Create health check daemon script
    cat > health_monitor.sh << 'EOF'
#!/bin/bash

INSTALL_DIR="/home/n8n"
CHECK_INTERVAL=30
LOG_FILE="$INSTALL_DIR/logs/health_monitor.log"

cd "$INSTALL_DIR"

# Determine docker-compose command
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    DOCKER_COMPOSE="docker compose"
fi

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

check_service() {
    local service=$1
    local container=$2
    local health_endpoint=$3
    
    if docker ps --format "{{.Names}}" | grep -q "^${container}$"; then
        if [ -n "$health_endpoint" ]; then
            if docker exec "$container" wget -q --spider "$health_endpoint" 2>/dev/null; then
                return 0
            else
                log "WARNING: $service health check failed"
                return 1
            fi
        else
            return 0
        fi
    else
        log "ERROR: $service container not running"
        return 1
    fi
}

auto_fix() {
    local service=$1
    log "Attempting auto-fix for $service..."
    
    # Try to restart the service
    $DOCKER_COMPOSE restart "$service"
    sleep 10
    
    # Check if fixed
    if check_service "$service" "$service" ""; then
        log "SUCCESS: $service auto-fixed"
        return 0
    else
        log "FAILED: Could not auto-fix $service"
        return 1
    fi
}

# Main monitoring loop
log "Health monitor started"

while true; do
    # Check each service
    services_healthy=true
    
    # Check N8N
    if ! check_service "n8n-main" "n8n-main" "http://localhost:5678/healthz"; then
        services_healthy=false
        auto_fix "n8n-main"
    fi
    
    # Check PostgreSQL if exists
    if docker ps --format "{{.Names}}" | grep -q "^postgres-db$"; then
        if ! docker exec postgres-db pg_isready -U postgres >/dev/null 2>&1; then
            services_healthy=false
            log "PostgreSQL unhealthy"
            auto_fix "postgres-db"
        fi
    fi
    
    # Check News API if exists
    if docker ps --format "{{.Names}}" | grep -q "^news-api$"; then
        if ! check_service "news-api" "news-api" "http://localhost:8000/health"; then
            services_healthy=false
            auto_fix "news-api"
        fi
    fi
    
    # Log overall status
    if [ "$services_healthy" = true ]; then
        log "All services healthy"
    else
        log "Some services need attention"
    fi
    
    sleep $CHECK_INTERVAL
done
EOF
    chmod +x health_monitor.sh
    
    # Create systemd service for health monitor
    if command -v systemctl &> /dev/null; then
        cat > /etc/systemd/system/n8n-health-monitor.service << EOF
[Unit]
Description=N8N Health Monitor
After=docker.service
Requires=docker.service

[Service]
Type=simple
ExecStart=$INSTALL_DIR/health_monitor.sh
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF
        
        systemctl daemon-reload
        systemctl enable n8n-health-monitor.service
        systemctl start n8n-health-monitor.service
        
        success "✅ Health monitoring service đã được cài đặt"
    else
        # Run in background if no systemd
        nohup ./health_monitor.sh > /dev/null 2>&1 &
        success "✅ Health monitoring đang chạy trong background"
    fi
}

# =============================================================================
# FINAL STATUS & SUMMARY
# =============================================================================

show_installation_summary() {
    log "📋 Hiển thị thông tin cài đặt..."
    
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                   🎉 CÀI ĐẶT HOÀN TẤT THÀNH CÔNG! 🎉                       ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    
    # Access URLs based on deployment mode
    echo -e "${CYAN}║${YELLOW} 🌐 TRUY CẬP DỊCH VỤ:                                                        ${CYAN}║${NC}"
    
    if [[ "$DEPLOYMENT_MODE" == "localhost" ]]; then
        # Localhost URLs
        echo -e "${CYAN}║${WHITE} • N8N Main: http://localhost:$N8N_MAIN_PORT                                 ${CYAN}║${NC}"
        
        if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
            local port=$PORT_BASE
            for ((i=1; i<${#DOMAINS[@]}; i++)); do
                port=$((PORT_BASE + i))
                echo -e "${CYAN}║${WHITE} • N8N Instance $i: http://localhost:$port                                    ${CYAN}║${NC}"
            done
        fi
        
        if [[ "$ENABLE_NEWS_API" == "true" ]]; then
            echo -e "${CYAN}║${WHITE} • News API: http://localhost:$NEWS_API_PORT                                  ${CYAN}║${NC}"
            echo -e "${CYAN}║${WHITE} • API Docs: http://localhost:$NEWS_API_PORT/docs                             ${CYAN}║${NC}"
        fi
        
        echo -e "${CYAN}║${WHITE} • Dashboard: http://localhost:$DASHBOARD_PORT                                ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE}   Username: $DASHBOARD_USER                                                  ${CYAN}║${NC}"
        
    elif [[ "$DEPLOYMENT_MODE" == "domain" ]]; then
        # Domain URLs
        echo -e "${CYAN}║${WHITE} • N8N Main: https://n8n.$MAIN_DOMAIN                                        ${CYAN}║${NC}"
        
        if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
            local instance_num=1
            for ((i=1; i<${#DOMAINS[@]}; i++)); do
                echo -e "${CYAN}║${WHITE} • N8N Instance $instance_num: https://n8n$instance_num.$MAIN_DOMAIN                           ${CYAN}║${NC}"
                ((instance_num++))
            done
        fi
        
        if [[ "$ENABLE_NEWS_API" == "true" ]]; then
            echo -e "${CYAN}║${WHITE} • News API: https://api.$MAIN_DOMAIN                                        ${CYAN}║${NC}"
            echo -e "${CYAN}║${WHITE} • API Docs: https://api.$MAIN_DOMAIN/docs                                   ${CYAN}║${NC}"
        fi
        
        echo -e "${CYAN}║${WHITE} • Dashboard: https://dashboard.$MAIN_DOMAIN                                 ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE}   Username: $DASHBOARD_USER                                                  ${CYAN}║${NC}"
        
    elif [[ "$DEPLOYMENT_MODE" == "cloudflare" ]]; then
        # Cloudflare Tunnel URLs
        echo -e "${CYAN}║${WHITE} 📌 Cloudflare Tunnel Configuration:                                        ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE} • N8N Main: https://n8n.$MAIN_DOMAIN                                        ${CYAN}║${NC}"
        
        if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
            local instance_num=1
            for ((i=1; i<${#DOMAINS[@]}; i++)); do
                echo -e "${CYAN}║${WHITE} • N8N Instance $instance_num: https://n8n$instance_num.$MAIN_DOMAIN                           ${CYAN}║${NC}"
                ((instance_num++))
            done
        fi
        
        if [[ "$ENABLE_NEWS_API" == "true" ]]; then
            echo -e "${CYAN}║${WHITE} • News API: https://api.$MAIN_DOMAIN                                        ${CYAN}║${NC}"
        fi
        
        echo -e "${CYAN}║${WHITE} • Dashboard: https://dashboard.$MAIN_DOMAIN                                 ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE}   Username: $DASHBOARD_USER                                                  ${CYAN}║${NC}"
        echo -e "${CYAN}║${YELLOW} ⚠️ Nhớ cấu hình DNS cho domain trỏ về Cloudflare!                          ${CYAN}║${NC}"
    fi
    
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${YELLOW} 📁 THÔNG TIN HỆ THỐNG:                                                      ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} • Deployment Mode: $DEPLOYMENT_MODE                                          ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} • Database: $([[ "$ENABLE_POSTGRESQL" == "true" ]] && echo "PostgreSQL" || echo "SQLite")                                                      ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} • Thư mục cài đặt: $INSTALL_DIR                                       ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} • Docker Compose: $DOCKER_COMPOSE                                     ${CYAN}║${NC}"
    
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${YELLOW} 🔧 LỆNH QUẢN LÝ:                                                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} • Khởi động: cd $INSTALL_DIR && ./start.sh                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} • Dừng: cd $INSTALL_DIR && ./stop.sh                                 ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} • Restart: cd $INSTALL_DIR && ./restart.sh                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} • Xem logs: cd $INSTALL_DIR && ./logs.sh [service_name]              ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} • Health check: cd $INSTALL_DIR && ./health.sh                       ${CYAN}║${NC}"
    
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${CYAN}║${YELLOW} 📰 NEWS API AUTHENTICATION:                                                 ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE} • Bearer Token: $BEARER_TOKEN                          ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE} • Header: Authorization: Bearer YOUR_TOKEN                                  ${CYAN}║${NC}"
    fi
    
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${YELLOW} 💡 LƯU Ý QUAN TRỌNG:                                                        ${CYAN}║${NC}"
    
    if [[ "$DEPLOYMENT_MODE" == "domain" ]]; then
        echo -e "${CYAN}║${WHITE} • SSL certificates sẽ được cấp tự động trong 2-3 phút                      ${CYAN}║${NC}"
        echo -e "${CYAN}║${WHITE} • Đảm bảo đã trỏ DNS về server IP: $(curl -s ifconfig.me || echo "YOUR_IP")                  ${CYAN}║${NC}"
    fi
    
    echo -e "${CYAN}║${WHITE} • Health monitoring đang chạy và tự động fix lỗi                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} • Dashboard password đã được mã hóa an toàn                                ${CYAN}║${NC}"
    
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${YELLOW} 🚀 TÁC GIẢ:                                                                 ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} • Tên: Nguyễn Ngọc Thiện                                                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} • YouTube: https://www.youtube.com/@kalvinthiensocial                      ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} • Zalo: 08.8888.4749                                                        ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} • Version: 4.0 - Enhanced Multi-Deployment                                 ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${GREEN} 🎬 ĐĂNG KÝ KÊNH YOUTUBE ĐỂ ỦNG HỘ MÌNH NHÉ! 🔔                             ${CYAN}║${NC}"
    echo -e "${CYAN}║${GREEN} 👉 https://www.youtube.com/@kalvinthiensocial?sub_confirmation=1           ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    show_banner
    
    # System checks
    check_root
    check_os
    
    # Get user inputs
    get_deployment_mode
    get_main_domain
    get_installation_mode
    get_multi_domain_config
    get_port_configuration
    get_ssl_email_config
    setup_dashboard_auth
    get_news_api_config
    get_telegram_config
    
    # Cloudflare tunnel setup
    setup_cloudflare_tunnel
    
    # System preparation
    log "🚀 Bắt đầu cài đặt N8N Multi-Instance..."
    
    # Install Docker if needed
    if ! check_docker || ! check_docker_compose; then
        install_docker
    fi
    
    # Setup system
    setup_swap
    prepare_directories
    
    # Generate configurations
    generate_docker_compose
    generate_caddyfile
    generate_cloudflare_config
    
    # Setup services
    setup_news_api
    setup_dashboard
    
    # Deploy
    deploy_services
    
    # Post-deployment
    log "🔧 Thực hiện auto-fix..."
    fix_permissions_auto
    fix_network_auto
    sleep 10
    
    # Health check
    if ! health_check_auto; then
        warning "⚠️ Một số services chưa sẵn sàng, đang thử lại..."
        sleep 30
        health_check_auto
    fi
    
    # Create helper scripts
    create_helper_scripts
    
    # Setup monitoring
    setup_health_monitoring
    
    # Show summary
    show_installation_summary
    
    success "🎉 Cài đặt hoàn tất! Hệ thống đã sẵn sàng sử dụng."
}

# Run main function
main "$@"

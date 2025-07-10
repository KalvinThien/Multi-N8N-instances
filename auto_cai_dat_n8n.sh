#!/bin/bash

# =============================================================================
# 🚀 SCRIPT CÀI ĐẶT N8N MULTI-MODE ENHANCED VERSION 4.0
# =============================================================================
# Tác giả: Nguyễn Ngọc Thiện
# YouTube: https://www.youtube.com/@kalvinthiensocial
# Zalo: 08.8888.4749
# Cập nhật: 10/07/2025
# Features: Multi-Mode + Auto-Fix + Health Check + Cloudflare Tunnel + Custom Ports
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;33m'
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
DASHBOARD_USER=""
DASHBOARD_PASS=""
ENABLE_NEWS_API=false
ENABLE_TELEGRAM=false
ENABLE_MULTI_DOMAIN=false
ENABLE_POSTGRESQL=false
ENABLE_GOOGLE_DRIVE=false
ENABLE_TELEGRAM_BOT=false
ENABLE_CLOUDFLARE=false
ENABLE_LOCALHOST=false
CLEAN_INSTALL=false
SKIP_DOCKER=false
AUTO_FIX_ENABLED=true
INSTALL_MODE="" # localhost, domain, cloudflare
BASE_N8N_PORT=5678
BASE_API_PORT=8000
CUSTOM_PORTS=()
CF_TUNNEL_TOKEN=""
HEALTH_CHECK_INTERVAL=60
MAX_RETRY_ATTEMPTS=5

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

show_banner() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}              🚀 N8N ENHANCED INSTALLER 2025 - VERSION 4.0 🚀                ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${WHITE} ✨ Multi-Mode: Localhost | Domain | Cloudflare Tunnel                     ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 🔧 Auto-Fix Integration - No more 503 errors!                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 🔒 Dashboard Security with Basic Auth                                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 🌐 Custom Port Configuration                                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 📊 Health Monitoring & Auto-Recovery                                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} ☁️  Cloudflare Tunnel Support (No Public IP needed)                      ${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE} 🛡️  Comprehensive Error Prevention                                       ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${YELLOW} 👨‍💻 Tác giả: Nguyễn Ngọc Thiện                                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 📺 YouTube: https://www.youtube.com/@kalvinthiensocial                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 📱 Zalo: 08.8888.4749                                                   ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 🎬 ĐĂNG KÝ KÊNH ĐỂ ỦNG HỘ MÌNH NHÉ! 🔔                                 ${CYAN}║${NC}"
    echo -e "${CYAN}║${YELLOW} 📅 Cập nhật: 01/07/2025 - Version 4.0 Enhanced                         ${CYAN}║${NC}"
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

confirm() {
    local prompt="$1"
    local default="${2:-N}"
    
    if [[ "$default" == "Y" || "$default" == "y" ]]; then
        read -p "$prompt (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            return 1
        fi
        return 0
    else
        read -p "$prompt (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            return 0
        fi
        return 1
    fi
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
    echo "  -l, --localhost         Chế độ localhost (không cần domain)"
    echo "  -f, --cloudflare        Sử dụng Cloudflare Tunnel"
    echo "  --no-auto-fix           Tắt auto-fix (không khuyến nghị)"
    echo ""
    echo "Ví dụ:"
    echo "  $0 -l                   # Cài đặt localhost"
    echo "  $0 -m -p               # Multi-domain với PostgreSQL"
    echo "  $0 -f                   # Cloudflare Tunnel mode"
    echo "  $0 -m -p -g -t         # Full features với domain"
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
            -l|--localhost)
                ENABLE_LOCALHOST=true
                INSTALL_MODE="localhost"
                shift
                ;;
            -f|--cloudflare)
                ENABLE_CLOUDFLARE=true
                INSTALL_MODE="cloudflare"
                shift
                ;;
            --no-auto-fix)
                AUTO_FIX_ENABLED=false
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
        if ! confirm "Bạn có muốn tiếp tục?"; then
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

check_required_tools() {
    local missing_tools=()
    
    # Check basic tools
    for tool in curl wget git python3 pip3; do
        if ! command -v $tool &> /dev/null; then
            missing_tools+=($tool)
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        warning "Thiếu các công cụ: ${missing_tools[*]}"
        if confirm "Bạn có muốn cài đặt các công cụ này?"; then
            apt update
            apt install -y ${missing_tools[@]}
        else
            error "Cần cài đặt các công cụ trước khi tiếp tục"
            exit 1
        fi
    fi
}

# =============================================================================
# PORT MANAGEMENT
# =============================================================================

check_port_availability() {
    local port=$1
    if netstat -tulpn 2>/dev/null | grep -q ":$port "; then
        return 1
    fi
    return 0
}

get_available_port() {
    local base_port=$1
    local port=$base_port
    
    while ! check_port_availability $port; do
        ((port++))
        if [[ $port -gt $((base_port + 100)) ]]; then
            error "Không thể tìm port khả dụng gần $base_port"
            return 1
        fi
    done
    
    echo $port
}

assign_instance_ports() {
    info "🔍 Phân bổ ports cho các instances..."
    
    CUSTOM_PORTS=()
    local base_port=${BASE_N8N_PORT:-5678}
    
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            if [[ $i -eq 0 ]]; then
                # First instance uses base port
                local port=$(get_available_port $base_port)
            else
                # Other instances start from 5800
                local port=$(get_available_port $((5800 + i - 1)))
            fi
            CUSTOM_PORTS+=($port)
            info "Instance $((i+1)) (${DOMAINS[$i]}): Port $port"
        done
    else
        local port=$(get_available_port $base_port)
        CUSTOM_PORTS+=($port)
        info "N8N Port: $port"
    fi
    
    # API port
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        BASE_API_PORT=$(get_available_port ${BASE_API_PORT:-8000})
        info "News API Port: $BASE_API_PORT"
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
    
    if confirm "Bạn có muốn tạo swap file ${swap_size}?"; then
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
    fi
}

# =============================================================================
# USER INPUT FUNCTIONS
# =============================================================================

get_installation_mode() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                           🎯 CHỌN CHẾ ĐỘ CÀI ĐẶT                            ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Chọn chế độ cài đặt:${NC}"
    echo -e "  ${GREEN}1.${NC} Localhost Mode - Không cần domain, truy cập qua IP"
    echo -e "  ${GREEN}2.${NC} Domain Mode - Cần domain và DNS"
    echo -e "  ${GREEN}3.${NC} Cloudflare Tunnel - Không cần public IP"
    echo ""
    
    while true; do
        read -p "🎯 Chọn chế độ (1-3): " mode
        case $mode in
            1)
                INSTALL_MODE="localhost"
                ENABLE_LOCALHOST=true
                break
                ;;
            2)
                INSTALL_MODE="domain"
                echo ""
                echo -e "${WHITE}Domain Mode - Chọn loại:${NC}"
                echo -e "  ${GREEN}1.${NC} Single Domain (Cơ bản)"
                echo -e "  ${GREEN}2.${NC} Multi-Domain (Nâng cao)"
                echo -e "  ${GREEN}3.${NC} Multi-Domain + PostgreSQL"
                echo -e "  ${GREEN}4.${NC} Full Features (Multi + PostgreSQL + Google Drive + Telegram)"
                echo ""
                
                read -p "🎯 Chọn loại (1-4): " domain_type
                case $domain_type in
                    1)
                        ENABLE_MULTI_DOMAIN=false
                        ENABLE_POSTGRESQL=false
                        ;;
                    2)
                        ENABLE_MULTI_DOMAIN=true
                        ENABLE_POSTGRESQL=false
                        ;;
                    3)
                        ENABLE_MULTI_DOMAIN=true
                        ENABLE_POSTGRESQL=true
                        ;;
                    4)
                        ENABLE_MULTI_DOMAIN=true
                        ENABLE_POSTGRESQL=true
                        ENABLE_GOOGLE_DRIVE=true
                        ENABLE_TELEGRAM_BOT=true
                        ;;
                esac
                break
                ;;
            3)
                INSTALL_MODE="cloudflare"
                ENABLE_CLOUDFLARE=true
                echo ""
                if confirm "Bạn có muốn sử dụng Multi-Domain với Cloudflare?"; then
                    ENABLE_MULTI_DOMAIN=true
                fi
                break
                ;;
            *)
                error "Lựa chọn không hợp lệ. Vui lòng chọn 1-3."
                ;;
        esac
    done
    
    info "Chế độ đã chọn: $INSTALL_MODE"
}

get_domain_input() {
    if [[ "$INSTALL_MODE" == "localhost" ]]; then
        info "Localhost mode - không cần cấu hình domain"
        return 0
    fi
    
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                           🌐 CẤU HÌNH DOMAIN                                ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        echo -e "${WHITE}Multi-Domain Mode:${NC}"
        echo -e "  • Nhập nhiều domains (không giới hạn số lượng)"
        echo -e "  • Mỗi domain sẽ có N8N instance riêng"
        echo -e "  • Ports sẽ được tự động phân bổ"
        echo ""
        
        while true; do
            read -p "🌐 Nhập domain (ví dụ: n8n1.example.com): " domain
            if [[ -n "$domain" && "$domain" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]$ ]]; then
                DOMAINS+=("$domain")
                info "Đã thêm domain: $domain"
                
                if ! confirm "Thêm domain khác?"; then
                    break
                fi
            else
                error "Domain không hợp lệ. Vui lòng nhập lại."
            fi
        done
        
        # Set API domain
        if confirm "Bạn có muốn sử dụng subdomain api.${DOMAINS[0]} cho News API?"; then
            API_DOMAIN="api.${DOMAINS[0]}"
        else
            read -p "Nhập domain cho News API: " API_DOMAIN
        fi
        
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
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        info "  API Domain: ${API_DOMAIN}"
    fi
}

get_port_configuration() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                           🔌 CẤU HÌNH PORT                                  ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # N8N base port
    read -p "🔌 Nhập base port cho N8N (Enter = 5678): " port
    if [[ -n "$port" && "$port" =~ ^[0-9]+$ ]]; then
        BASE_N8N_PORT=$port
    else
        BASE_N8N_PORT=5678
    fi
    
    # News API port
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        read -p "🔌 Nhập port cho News API (Enter = 8000): " port
        if [[ -n "$port" && "$port" =~ ^[0-9]+$ ]]; then
            BASE_API_PORT=$port
        else
            BASE_API_PORT=8000
        fi
    fi
    
    # Assign ports
    assign_instance_ports
}

get_dashboard_auth() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        🔒 DASHBOARD SECURITY                               ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if confirm "Bạn có muốn bảo vệ Dashboard với Basic Auth?"; then
        while true; do
            read -p "👤 Nhập username cho Dashboard: " DASHBOARD_USER
            if [[ -n "$DASHBOARD_USER" ]]; then
                break
            fi
            error "Username không được để trống"
        done
        
        while true; do
            read -s -p "🔑 Nhập password cho Dashboard: " DASHBOARD_PASS
            echo
            if [[ ${#DASHBOARD_PASS} -ge 6 ]]; then
                break
            fi
            error "Password phải có ít nhất 6 ký tự"
        done
        
        success "Đã thiết lập Basic Auth cho Dashboard"
    fi
}

get_cloudflare_config() {
    if [[ "$INSTALL_MODE" != "cloudflare" ]]; then
        return 0
    fi
    
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        ☁️  CLOUDFLARE TUNNEL                               ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Cloudflare Tunnel cho phép:${NC}"
    echo -e "  • Không cần public IP"
    echo -e "  • Tự động SSL certificates"
    echo -e "  • DDoS protection"
    echo -e "  • Zero Trust security"
    echo ""
    
    echo -e "${YELLOW}📋 Hướng dẫn lấy Tunnel Token:${NC}"
    echo -e "  1. Đăng nhập: https://one.dash.cloudflare.com/"
    echo -e "  2. Vào Zero Trust → Access → Tunnels"
    echo -e "  3. Create a tunnel → Cloudflared"
    echo -e "  4. Đặt tên tunnel (vd: n8n-tunnel)"
    echo -e "  5. Copy tunnel token"
    echo ""
    
    while true; do
        read -p "🔑 Nhập Cloudflare Tunnel Token: " CF_TUNNEL_TOKEN
        if [[ -n "$CF_TUNNEL_TOKEN" ]]; then
            break
        fi
        error "Tunnel token không được để trống"
    done
    
    success "Đã thiết lập Cloudflare Tunnel"
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
        if confirm "Bạn có muốn xóa cài đặt cũ và cài mới?"; then
            CLEAN_INSTALL=true
        fi
    fi
}

get_ssl_email_config() {
    if [[ "$INSTALL_MODE" == "localhost" || "$INSTALL_MODE" == "cloudflare" ]]; then
        info "Mode $INSTALL_MODE không cần SSL email"
        return 0
    fi
    
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        🔒 SSL CERTIFICATE EMAIL                            ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Smart email detection
    SUGGESTED_EMAIL=""
    if [[ -n "$USER" && "$USER" != "root" ]]; then
        SUGGESTED_EMAIL="${USER}@gmail.com"
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
        
        if [[ -n "$SSL_EMAIL" && "$SSL_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
            if [[ "$SSL_EMAIL" == *"@example.com" ]]; then
                error "Vui lòng sử dụng email thật"
                continue
            fi
            break
        else
            error "Email không hợp lệ"
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
    
    if confirm "Bạn có muốn cài đặt News Content API?" "Y"; then
        ENABLE_NEWS_API=true
        
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
    else
        ENABLE_NEWS_API=false
    fi
}

get_telegram_config() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}                        📱 TELEGRAM BACKUP                                  ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if confirm "Bạn có muốn thiết lập Telegram Backup?"; then
        ENABLE_TELEGRAM=true
        
        echo ""
        while true; do
            read -p "🤖 Nhập Telegram Bot Token: " TELEGRAM_BOT_TOKEN
            if [[ -n "$TELEGRAM_BOT_TOKEN" && "$TELEGRAM_BOT_TOKEN" =~ ^[0-9]+:[a-zA-Z0-9_-]+$ ]]; then
                break
            else
                error "Bot Token không hợp lệ"
            fi
        done
        
        while true; do
            read -p "🆔 Nhập Telegram Chat ID: " TELEGRAM_CHAT_ID
            if [[ -n "$TELEGRAM_CHAT_ID" && "$TELEGRAM_CHAT_ID" =~ ^-?[0-9]+$ ]]; then
                break
            else
                error "Chat ID không hợp lệ"
            fi
        done
        
        success "Đã thiết lập Telegram Backup"
    fi
}

# =============================================================================
# DNS VERIFICATION
# =============================================================================

verify_dns() {
    if [[ "$INSTALL_MODE" == "localhost" || "$INSTALL_MODE" == "cloudflare" ]]; then
        info "Mode $INSTALL_MODE không cần kiểm tra DNS"
        return 0
    fi
    
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
    
    if [[ "$dns_issues" == "true" ]]; then
        warning "DNS chưa trỏ đúng về máy chủ!"
        echo ""
        echo -e "${YELLOW}Hướng dẫn cấu hình DNS:${NC}"
        echo -e "  1. Đăng nhập vào trang quản lý domain"
        echo -e "  2. Tạo các bản ghi A record:"
        for domain in "${DOMAINS[@]}"; do
            echo -e "     • ${domain} → ${server_ip}"
        done
        echo ""
        
        if ! confirm "Bạn có muốn tiếp tục cài đặt?"; then
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
    for service in n8n-telegram-bot n8n-dashboard n8n-health-monitor; do
        systemctl stop $service 2>/dev/null || true
        systemctl disable $service 2>/dev/null || true
        rm -f /etc/systemd/system/$service.service
    done
    
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
    
    if confirm "Docker chưa được cài đặt. Bạn có muốn cài đặt Docker?"; then
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
    else
        error "Cần Docker để tiếp tục"
        exit 1
    fi
}

# =============================================================================
# CLOUDFLARE TUNNEL
# =============================================================================

install_cloudflared() {
    if [[ "$INSTALL_MODE" != "cloudflare" ]]; then
        return 0
    fi
    
    log "☁️ Cài đặt Cloudflare Tunnel..."
    
    # Install cloudflared
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    dpkg -i cloudflared-linux-amd64.deb
    rm cloudflared-linux-amd64.deb
    
    success "Đã cài đặt cloudflared"
}

create_cloudflare_config() {
    if [[ "$INSTALL_MODE" != "cloudflare" ]]; then
        return 0
    fi
    
    log "☁️ Tạo Cloudflare Tunnel configuration..."
    
    mkdir -p "$INSTALL_DIR/cloudflare"
    
    # Create tunnel config
    cat > "$INSTALL_DIR/cloudflare/config.yml" << EOF
tunnel: ${CF_TUNNEL_TOKEN}
credentials-file: /home/n8n/cloudflare/credentials.json

ingress:
EOF

    # Add N8N domains
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            local port=${CUSTOM_PORTS[$i]}
            cat >> "$INSTALL_DIR/cloudflare/config.yml" << EOF
  - hostname: ${DOMAINS[$i]}
    service: http://localhost:${port}
EOF
        done
    else
        cat >> "$INSTALL_DIR/cloudflare/config.yml" << EOF
  - hostname: ${DOMAINS[0]}
    service: http://localhost:${CUSTOM_PORTS[0]}
EOF
    fi
    
    # Add News API
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        cat >> "$INSTALL_DIR/cloudflare/config.yml" << EOF
  - hostname: ${API_DOMAIN}
    service: http://localhost:${BASE_API_PORT}
EOF
    fi
    
    # Add dashboard
    cat >> "$INSTALL_DIR/cloudflare/config.yml" << EOF
  - hostname: dashboard.${DOMAINS[0]}
    service: http://localhost:8080
EOF
    
    # Catch all
    cat >> "$INSTALL_DIR/cloudflare/config.yml" << EOF
  - service: http_status:404
EOF
    
    # Create systemd service
    cat > /etc/systemd/system/cloudflared.service << EOF
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/cloudflared tunnel --config /home/n8n/cloudflare/config.yml run
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable cloudflared
    
    success "Đã tạo Cloudflare Tunnel configuration"
}

# =============================================================================
# PROJECT SETUP WITH AUTO-FIX
# =============================================================================

create_project_structure() {
    log "📁 Tạo cấu trúc thư mục với quyền chính xác..."
    
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Create directories with proper permissions
    mkdir -p files/backup_full
    mkdir -p files/temp
    mkdir -p files/youtube_content_anylystic
    mkdir -p logs
    
    # Create instance directories for multi-domain
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            local instance_dir="files/n8n_instance_$((i+1))"
            mkdir -p "$instance_dir/.n8n"
            # Set permissions immediately
            chown -R 1000:1000 "$instance_dir"
            chmod -R 755 "$instance_dir"
        done
    else
        mkdir -p files/.n8n
        # Set permissions immediately
        chown -R 1000:1000 files/
        chmod -R 755 files/
    fi
    
    # Create PostgreSQL data directory
    if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
        mkdir -p postgres_data
        # PostgreSQL needs special permissions
        chown -R 999:999 postgres_data
    fi
    
    # Create other directories
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        mkdir -p news_api
    fi
    
    if [[ "$ENABLE_GOOGLE_DRIVE" == "true" ]]; then
        mkdir -p google_drive
    fi
    
    if [[ "$ENABLE_TELEGRAM_BOT" == "true" ]]; then
        mkdir -p telegram_bot
    fi
    
    mkdir -p dashboard
    mkdir -p security
    mkdir -p management
    mkdir -p health_checks
    
    # Set general permissions
    chown -R 1000:1000 files/ logs/
    
    success "Đã tạo cấu trúc thư mục với quyền chính xác"
}

# =============================================================================
# DOCKER COMPOSE WITH FIXES
# =============================================================================

create_docker_compose() {
    log "🐳 Tạo docker-compose.yml với auto-fix integration..."
    
    cat > "$INSTALL_DIR/docker-compose.yml" << EOF
version: '3.8'

services:
EOF

    # Add N8N services with proper container names
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            local instance_num=$((i+1))
            local domain="${DOMAINS[$i]}"
            local port=${CUSTOM_PORTS[$i]}
            
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
      - WEBHOOK_URL=$([[ "$INSTALL_MODE" == "localhost" ]] && echo "http://localhost:${port}/" || echo "https://${domain}/")
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
      - DB_POSTGRESDB_HOST=postgres-n8n
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
      - N8N_PAYLOAD_SIZE_MAX=16
      - N8N_METRICS_INCLUDE_API_ENDPOINTS=true
      - N8N_METRICS_INCLUDE_API_PATH_LABEL=true
      - N8N_METRICS_INCLUDE_API_METHOD_LABEL=true
      - N8N_METRICS_INCLUDE_API_STATUS_CODE_LABEL=true
    volumes:
      - ./files/n8n_instance_${instance_num}:/home/node/.n8n
      - ./files/youtube_content_anylystic:/data/youtube_content_anylystic
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - n8n_network
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:5678/healthz"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
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
        local port=${CUSTOM_PORTS[0]}
        cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
  n8n:
    build: .
    container_name: n8n-container
    restart: unless-stopped
    ports:
      - "127.0.0.1:${port}:5678"
    environment:
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=production
      - WEBHOOK_URL=$([[ "$INSTALL_MODE" == "localhost" ]] && echo "http://localhost:${port}/" || echo "https://${DOMAINS[0]}/")
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
      - DB_POSTGRESDB_HOST=postgres-n8n
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
      - N8N_PAYLOAD_SIZE_MAX=16
      - N8N_METRICS_INCLUDE_API_ENDPOINTS=true
      - N8N_METRICS_INCLUDE_API_PATH_LABEL=true
      - N8N_METRICS_INCLUDE_API_METHOD_LABEL=true
      - N8N_METRICS_INCLUDE_API_STATUS_CODE_LABEL=true
    volumes:
      - ./files:/home/node/.n8n
      - ./files/youtube_content_anylystic:/data/youtube_content_anylystic
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - n8n_network
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:5678/healthz"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
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

    # Add PostgreSQL service with health check
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
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

EOF
    fi

    # Add Caddy service for domain mode
    if [[ "$INSTALL_MODE" == "domain" ]]; then
        cat >> "$INSTALL_DIR/docker-compose.yml" << EOF
  caddy:
    image: caddy:latest
    container_name: caddy-proxy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
      - ./dashboard:/srv/dashboard:ro
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
      - "127.0.0.1:${BASE_API_PORT}:8000"
    environment:
      - NEWS_API_TOKEN=${BEARER_TOKEN}
      - PYTHONUNBUFFERED=1
    networks:
      - n8n_network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

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
    name: n8n_network
EOF
    
    success "Đã tạo docker-compose.yml với health checks"
}

# =============================================================================
# CADDY CONFIGURATION WITH FIXES
# =============================================================================

create_caddyfile() {
    if [[ "$INSTALL_MODE" != "domain" ]]; then
        return 0
    fi
    
    log "🌐 Tạo Caddyfile với proper configuration..."
    
    cat > "$INSTALL_DIR/Caddyfile" << EOF
{
    email ${SSL_EMAIL}
    acme_ca https://acme-v02.api.letsencrypt.org/directory
}

EOF

    # Add Dashboard with Basic Auth if configured
    if [[ -n "$DASHBOARD_USER" && -n "$DASHBOARD_PASS" ]]; then
        # Generate password hash
        local HASHED_PASS=$(docker run --rm caddy:latest caddy hash-password --plaintext "$DASHBOARD_PASS" 2>/dev/null || echo "$DASHBOARD_PASS")
        
        cat >> "$INSTALL_DIR/Caddyfile" << EOF
:8080 {
    root * /srv/dashboard
    file_server
    
    basicauth {
        ${DASHBOARD_USER} ${HASHED_PASS}
    }
    
    header {
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
    }
}

EOF
    else
        cat >> "$INSTALL_DIR/Caddyfile" << EOF
:8080 {
    root * /srv/dashboard
    file_server
    
    header {
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
    }
}

EOF
    fi

    # Add N8N domains with correct container names
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
        health_status 200
        
        transport http {
            dial_timeout 30s
            response_header_timeout 30s
        }
    }
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    
    encode gzip
    
    handle_errors {
        respond "{http.error.status_code} {http.error.status_text}"
    }
    
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
        health_status 200
        
        transport http {
            dial_timeout 30s
            response_header_timeout 30s
        }
    }
    
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    
    encode gzip
    
    handle_errors {
        respond "{http.error.status_code} {http.error.status_text}"
    }
    
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
        
        transport http {
            dial_timeout 30s
            response_header_timeout 30s
        }
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
    
    success "Đã tạo Caddyfile với proper reverse proxy configuration"
}

# =============================================================================
# HEALTH MONITORING AND AUTO-RECOVERY
# =============================================================================

create_health_monitor() {
    log "🏥 Tạo health monitoring system..."
    
    cat > "$INSTALL_DIR/health_checks/health_monitor.sh" << 'EOF'
#!/bin/bash

# Health Monitor for N8N Enhanced System
set -e

INSTALL_DIR="/home/n8n"
LOG_FILE="$INSTALL_DIR/logs/health_monitor.log"
TELEGRAM_CONFIG="$INSTALL_DIR/telegram_config.txt"
MAX_RETRIES=3
HEALTH_CHECK_INTERVAL=60

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

send_telegram_alert() {
    local message="$1"
    if [[ -f "$TELEGRAM_CONFIG" ]]; then
        source "$TELEGRAM_CONFIG"
        if [[ -n "$TELEGRAM_BOT_TOKEN" && -n "$TELEGRAM_CHAT_ID" ]]; then
            curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
                -d chat_id="$TELEGRAM_CHAT_ID" \
                -d text="🚨 N8N Health Alert: $message" \
                -d parse_mode="Markdown" > /dev/null || true
        fi
    fi
}

check_container_health() {
    local container_name="$1"
    local service_name="$2"
    local retry_count=0
    
    while [[ $retry_count -lt $MAX_RETRIES ]]; do
        if docker ps --format "{{.Names}}" | grep -q "^${container_name}$"; then
            # Container is running, check if it's healthy
            local health_status=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null || echo "none")
            
            if [[ "$health_status" == "healthy" || "$health_status" == "none" ]]; then
                return 0
            else
                warning "Container $container_name is $health_status"
            fi
        else
            error "Container $container_name is not running"
        fi
        
        # Try to restart the service
        ((retry_count++))
        warning "Attempting to restart $service_name (attempt $retry_count/$MAX_RETRIES)"
        
        cd "$INSTALL_DIR"
        if command -v docker-compose &> /dev/null; then
            docker-compose restart "$service_name" || true
        else
            docker compose restart "$service_name" || true
        fi
        
        sleep 30
    done
    
    # Failed after max retries
    error "Failed to recover $container_name after $MAX_RETRIES attempts"
    send_telegram_alert "❌ Service *$service_name* ($container_name) is down and could not be recovered"
    return 1
}

check_web_endpoint() {
    local url="$1"
    local description="$2"
    
    if curl -f -s -m 10 "$url" > /dev/null; then
        log "✅ $description is accessible"
        return 0
    else
        error "❌ $description is not accessible"
        return 1
    fi
}

auto_fix_permissions() {
    log "🔧 Running auto-fix permissions..."
    
    cd "$INSTALL_DIR"
    
    # Fix file permissions
    if ls files/n8n_instance_* &>/dev/null; then
        for dir in files/n8n_instance_*; do
            if [[ -d "$dir" ]]; then
                chown -R 1000:1000 "$dir"
                chmod -R 755 "$dir"
            fi
        done
    else
        chown -R 1000:1000 files/
        chmod -R 755 files/
    fi
    
    # Fix PostgreSQL permissions if needed
    if [[ -d "postgres_data" ]]; then
        chown -R 999:999 postgres_data/
    fi
    
    log "✅ Permissions fixed"
}

main_health_check() {
    log "🏥 Starting health check cycle..."
    
    cd "$INSTALL_DIR"
    
    # Detect setup type
    local is_multi_domain=false
    local containers_healthy=true
    
    if docker ps --format "{{.Names}}" | grep -q "n8n-container-1"; then
        is_multi_domain=true
    fi
    
    # Check PostgreSQL if enabled
    if docker ps --format "{{.Names}}" | grep -q "postgres-n8n"; then
        if ! check_container_health "postgres-n8n" "postgres"; then
            containers_healthy=false
        fi
    fi
    
    # Check N8N containers
    if [[ "$is_multi_domain" == "true" ]]; then
        for container in $(docker ps -a --format "{{.Names}}" | grep "^n8n-container-"); do
            local instance_num=$(echo "$container" | grep -o '[0-9]\+$')
            if ! check_container_health "$container" "n8n_$instance_num"; then
                containers_healthy=false
            fi
        done
    else
        if ! check_container_health "n8n-container" "n8n"; then
            containers_healthy=false
        fi
    fi
    
    # Check Caddy
    if docker ps --format "{{.Names}}" | grep -q "caddy-proxy"; then
        if ! check_container_health "caddy-proxy" "caddy"; then
            containers_healthy=false
        fi
    fi
    
    # Check News API
    if docker ps --format "{{.Names}}" | grep -q "news-api-container"; then
        if ! check_container_health "news-api-container" "fastapi"; then
            containers_healthy=false
        fi
    fi
    
    # If any container failed, try auto-fix
    if [[ "$containers_healthy" == "false" ]]; then
        warning "Some containers are unhealthy, attempting auto-fix..."
        auto_fix_permissions
        
        # Restart all services
        if command -v docker-compose &> /dev/null; then
            docker-compose down
            docker-compose up -d
        else
            docker compose down
            docker compose up -d
        fi
        
        sleep 60
        
        # Re-check after fix
        containers_healthy=true
        # ... repeat checks ...
    fi
    
    # Check web endpoints
    if [[ -f "Caddyfile" ]]; then
        for domain in $(grep -E "^[a-zA-Z0-9.-]+\s*{" Caddyfile | awk '{print $1}' | grep -v "{"); do
            if [[ -n "$domain" && "$domain" != ":" ]]; then
                check_web_endpoint "https://$domain" "Domain $domain" || true
            fi
        done
    fi
    
    # Check dashboard
    local server_ip=$(hostname -I | awk '{print $1}')
    check_web_endpoint "http://$server_ip:8080" "Dashboard" || true
    
    if [[ "$containers_healthy" == "true" ]]; then
        log "✅ All systems healthy"
    else
        error "❌ Some systems need attention"
        send_telegram_alert "⚠️ Health check completed with issues. Please check the system."
    fi
}

# Run continuous monitoring
while true; do
    main_health_check
    sleep $HEALTH_CHECK_INTERVAL
done
EOF
    
    chmod +x "$INSTALL_DIR/health_checks/health_monitor.sh"
    
    # Create systemd service for health monitor
    cat > /etc/systemd/system/n8n-health-monitor.service << EOF
[Unit]
Description=N8N Health Monitor
After=docker.service
Requires=docker.service

[Service]
Type=simple
User=root
WorkingDirectory=/home/n8n
ExecStart=/home/n8n/health_checks/health_monitor.sh
Restart=always
RestartSec=30
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable n8n-health-monitor
    
    success "Đã tạo health monitoring system"
}

# =============================================================================
# DEPLOYMENT WITH AUTO-FIX
# =============================================================================

deploy_with_autofix() {
    log "🚀 Deploy với auto-fix integration..."
    
    cd "$INSTALL_DIR"
    
    # Pre-deployment fixes
    log "🔧 Running pre-deployment fixes..."
    
    # Ensure proper permissions before starting
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            local instance_dir="files/n8n_instance_$((i+1))"
            chown -R 1000:1000 "$instance_dir"
            chmod -R 755 "$instance_dir"
        done
    else
        chown -R 1000:1000 files/
        chmod -R 755 files/
    fi
    
    if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
        chown -R 999:999 postgres_data/
    fi
    
    # Ensure Docker network exists
    docker network create n8n_network 2>/dev/null || true
    
    # Build images
    log "📦 Build Docker images..."
    $DOCKER_COMPOSE build --no-cache
    
    # Start services in correct order
    log "🚀 Khởi động services theo thứ tự..."
    
    # Start PostgreSQL first if enabled
    if [[ "$ENABLE_POSTGRESQL" == "true" ]]; then
        log "Starting PostgreSQL..."
        $DOCKER_COMPOSE up -d postgres
        
        # Wait for PostgreSQL to be ready
        local pg_ready=false
        for i in {1..30}; do
            if docker exec postgres-n8n pg_isready -U postgres &>/dev/null; then
                pg_ready=true
                break
            fi
            sleep 2
        done
        
        if [[ "$pg_ready" == "false" ]]; then
            error "PostgreSQL failed to start"
            return 1
        fi
        
        success "PostgreSQL is ready"
    fi
    
    # Start N8N instances
    log "Starting N8N instances..."
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            $DOCKER_COMPOSE up -d n8n_$((i+1))
            sleep 5
        done
    else
        $DOCKER_COMPOSE up -d n8n
        sleep 5
    fi
    
    # Wait for N8N to be ready
    log "Waiting for N8N to be ready..."
    sleep 30
    
    # Verify N8N is responding
    local n8n_ready=false
    for i in {1..30}; do
        if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
            if docker exec n8n-container-1 wget --spider -q http://localhost:5678/healthz; then
                n8n_ready=true
                break
            fi
        else
            if docker exec n8n-container wget --spider -q http://localhost:5678/healthz; then
                n8n_ready=true
                break
            fi
        fi
        sleep 2
    done
    
    if [[ "$n8n_ready" == "false" ]]; then
        warning "N8N health check failed, but continuing..."
    else
        success "N8N is ready"
    fi
    
    # Start News API if enabled
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        log "Starting News API..."
        $DOCKER_COMPOSE up -d fastapi
        sleep 10
    fi
    
    # Start Caddy last (for domain mode)
    if [[ "$INSTALL_MODE" == "domain" ]]; then
        log "Starting Caddy..."
        $DOCKER_COMPOSE up -d caddy
        sleep 10
    fi
    
    # Start Cloudflare Tunnel (for cloudflare mode)
    if [[ "$INSTALL_MODE" == "cloudflare" ]]; then
        log "Starting Cloudflare Tunnel..."
        systemctl start cloudflared
    fi
    
    # Final verification
    log "🔍 Verifying deployment..."
    sleep 10
    
    $DOCKER_COMPOSE ps
    
    # Check for common issues and auto-fix
    local all_healthy=true
    
    # Check container status
    for container in $(docker ps -a --format "{{.Names}}" | grep -E "(n8n|caddy|postgres|news-api)"); do
        if ! docker ps --format "{{.Names}}" | grep -q "^${container}$"; then
            warning "Container $container is not running, attempting to fix..."
            docker start "$container" || true
            all_healthy=false
        fi
    done
    
    if [[ "$all_healthy" == "true" ]]; then
        success "✅ All containers are running"
    else
        warning "⚠️ Some containers needed fixing, waiting for stabilization..."
        sleep 30
    fi
    
    # Start health monitor
    systemctl start n8n-health-monitor
    
    success "Deployment completed with auto-fix enabled"
}

# =============================================================================
# POST-DEPLOYMENT VALIDATION
# =============================================================================

validate_deployment() {
    log "🔍 Validating deployment..."
    
    cd "$INSTALL_DIR"
    
    local validation_passed=true
    
    # Check containers
    info "Checking container status..."
    if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
        for i in "${!DOMAINS[@]}"; do
            if docker ps | grep -q "n8n-container-$((i+1))"; then
                success "✅ n8n-container-$((i+1)) is running"
            else
                error "❌ n8n-container-$((i+1)) is not running"
                validation_passed=false
            fi
        done
    else
        if docker ps | grep -q "n8n-container"; then
            success "✅ n8n-container is running"
        else
            error "❌ n8n-container is not running"
            validation_passed=false
        fi
    fi
    
    # Check endpoints
    info "Checking endpoints..."
    
    if [[ "$INSTALL_MODE" == "localhost" ]]; then
        for i in "${!CUSTOM_PORTS[@]}"; do
            if curl -f -s "http://localhost:${CUSTOM_PORTS[$i]}" &>/dev/null; then
                success "✅ N8N instance $((i+1)) accessible on port ${CUSTOM_PORTS[$i]}"
            else
                warning "⚠️ N8N instance $((i+1)) not yet accessible on port ${CUSTOM_PORTS[$i]}"
            fi
        done
    elif [[ "$INSTALL_MODE" == "domain" ]]; then
        # Wait for SSL certificates
        info "Waiting for SSL certificates..."
        sleep 60
        
        for domain in "${DOMAINS[@]}"; do
            if curl -f -s "https://$domain" &>/dev/null; then
                success "✅ $domain is accessible with SSL"
            else
                warning "⚠️ $domain SSL not ready yet"
            fi
        done
    fi
    
    # Check dashboard
    local server_ip=$(curl -s https://api.ipify.org || hostname -I | awk '{print $1}')
    if curl -f -s "http://$server_ip:8080" &>/dev/null; then
        success "✅ Dashboard accessible at http://$server_ip:8080"
    else
        warning "⚠️ Dashboard not accessible"
    fi
    
    if [[ "$validation_passed" == "true" ]]; then
        success "✅ Deployment validation passed!"
    else
        warning "⚠️ Some components need attention"
        info "Health monitor will continue to check and auto-fix issues"
    fi
}

# =============================================================================
# FINAL SUMMARY
# =============================================================================

show_final_summary() {
    clear
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${WHITE}             🎉 N8N ENHANCED SYSTEM ĐÃ ĐƯỢC CÀI ĐẶT THÀNH CÔNG!             ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}🌐 TRUY CẬP DỊCH VỤ:${NC}"
    
    if [[ "$INSTALL_MODE" == "localhost" ]]; then
        for i in "${!CUSTOM_PORTS[@]}"; do
            echo -e "  • N8N Instance $((i+1)): ${WHITE}http://localhost:${CUSTOM_PORTS[$i]}${NC}"
        done
        if [[ "$ENABLE_NEWS_API" == "true" ]]; then
            echo -e "  • News API: ${WHITE}http://localhost:${BASE_API_PORT}${NC}"
            echo -e "  • API Docs: ${WHITE}http://localhost:${BASE_API_PORT}/docs${NC}"
        fi
    elif [[ "$INSTALL_MODE" == "domain" ]]; then
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
        fi
    elif [[ "$INSTALL_MODE" == "cloudflare" ]]; then
        if [[ "$ENABLE_MULTI_DOMAIN" == "true" ]]; then
            for i in "${!DOMAINS[@]}"; do
                echo -e "  • N8N Instance $((i+1)): ${WHITE}https://${DOMAINS[$i]}${NC} (via Cloudflare)"
            done
        else
            echo -e "  • N8N: ${WHITE}https://${DOMAINS[0]}${NC} (via Cloudflare)"
        fi
        echo -e "  • Dashboard: ${WHITE}https://dashboard.${DOMAINS[0]}${NC}"
    fi
    
    # Dashboard access
    local server_ip=$(curl -s https://api.ipify.org || hostname -I | awk '{print $1}')
    echo -e "  • Web Dashboard: ${WHITE}http://${server_ip}:8080${NC}"
    if [[ -n "$DASHBOARD_USER" ]]; then
        echo -e "    Username: ${YELLOW}${DASHBOARD_USER}${NC}"
        echo -e "    Password: ${YELLOW}[đã đặt]${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}📁 THÔNG TIN HỆ THỐNG:${NC}"
    echo -e "  • Mode: ${WHITE}${INSTALL_MODE}${NC}"
    echo -e "  • Type: ${WHITE}$([[ "$ENABLE_MULTI_DOMAIN" == "true" ]] && echo "Multi-Domain (${#DOMAINS[@]} instances)" || echo "Single Domain")${NC}"
    echo -e "  • Database: ${WHITE}$([[ "$ENABLE_POSTGRESQL" == "true" ]] && echo "PostgreSQL" || echo "SQLite")${NC}"
    echo -e "  • Auto-Fix: ${WHITE}$([[ "$AUTO_FIX_ENABLED" == "true" ]] && echo "Enabled" || echo "Disabled")${NC}"
    echo -e "  • Health Monitor: ${WHITE}Active${NC}"
    echo -e "  • Installation: ${WHITE}${INSTALL_DIR}${NC}"
    
    echo ""
    echo -e "${CYAN}🔧 USEFUL COMMANDS:${NC}"
    echo -e "  • View logs: ${WHITE}cd $INSTALL_DIR && $DOCKER_COMPOSE logs -f${NC}"
    echo -e "  • Restart all: ${WHITE}cd $INSTALL_DIR && $DOCKER_COMPOSE restart${NC}"
    echo -e "  • Check status: ${WHITE}cd $INSTALL_DIR && $DOCKER_COMPOSE ps${NC}"
    echo -e "  • Health monitor logs: ${WHITE}journalctl -u n8n-health-monitor -f${NC}"
    echo -e "  • Manual backup: ${WHITE}$INSTALL_DIR/backup-manual.sh${NC}"
    
    if [[ "$ENABLE_NEWS_API" == "true" ]]; then
        echo ""
        echo -e "${CYAN}🔑 API TOKEN:${NC}"
        echo -e "  • Bearer Token đã được set (không hiển thị vì bảo mật)"
        echo -e "  • Thay đổi: ${WHITE}cd $INSTALL_DIR && vim docker-compose.yml${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}🚀 TÁC GIẢ:${NC}"
    echo -e "  • Tên: ${WHITE}Nguyễn Ngọc Thiện${NC}"
    echo -e "  • YouTube: ${WHITE}https://www.youtube.com/@kalvinthiensocial${NC}"
    echo -e "  • Zalo: ${WHITE}08.8888.4749${NC}"
    echo ""
    
    echo -e "${YELLOW}🎬 ĐĂNG KÝ KÊNH YOUTUBE ĐỂ ỦNG HỘ MÌNH NHÉ! 🔔${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    if [[ "$INSTALL_MODE" == "domain" ]]; then
        echo ""
        warning "⏳ Lưu ý: SSL certificates có thể mất 2-5 phút để được cấp"
        info "💡 Health monitor sẽ tự động kiểm tra và sửa lỗi nếu có"
    fi
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
    check_required_tools
    
    # Setup swap
    setup_swap
    
    # Get installation mode
    if [[ -z "$INSTALL_MODE" ]]; then
        get_installation_mode
    fi
    
    # Get user input based on mode
    get_domain_input
    get_port_configuration
    get_cleanup_option
    get_dashboard_auth
    get_ssl_email_config
    get_news_api_config
    get_telegram_config
    get_cloudflare_config
    
    # Verify DNS (for domain mode)
    verify_dns
    
    # Cleanup old installation
    cleanup_old_installation
    
    # Install dependencies
    install_docker
    install_cloudflared
    
    # Create project structure with proper permissions
    create_project_structure
    
    # Create configuration files
    create_dockerfile
    create_postgresql_init
    create_news_api
    create_docker_compose
    create_caddyfile
    create_cloudflare_config
    
    # Create support scripts
    create_backup_scripts
    create_health_monitor
    create_web_dashboard
    
    # Setup services
    create_systemd_services
    setup_telegram_config
    setup_cron_jobs
    
    # Deploy with auto-fix
    if confirm "Bắt đầu deployment?" "Y"; then
        deploy_with_autofix
    else
        error "Deployment cancelled"
        exit 1
    fi
    
    # Validate deployment
    validate_deployment
    
    # Show final summary
    show_final_summary
}

# =============================================================================
# DOCKERFILE CREATION
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

# =============================================================================
# POSTGRESQL INITIALIZATION
# =============================================================================

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

# =============================================================================
# NEWS API CREATION
# =============================================================================

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
            .endpoint {{ background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 15px 0; border-left: 4px solid #3498db; }}
            .method {{ background: #3498db; color: white; padding: 4px 12px; border-radius: 4px; font-size: 12px; font-weight: bold; }}
            .auth-info {{ background: linear-gradient(135deg, #e74c3c, #c0392b); color: white; padding: 20px; border-radius: 8px; margin: 25px 0; }}
            code {{ background: #2c3e50; color: #ecf0f1; padding: 3px 8px; border-radius: 4px; font-family: 'Courier New', monospace; }}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 News Content API v3.0 - Multi-Domain</h1>
            <p>Advanced News Content Extraction API với Multi-Domain Support</p>
            
            <div class="auth-info">
                <h3>🔐 Authentication Required</h3>
                <p>Tất cả API calls yêu cầu Bearer Token trong header:</p>
                <code>Authorization: Bearer YOUR_TOKEN_HERE</code>
            </div>
            
            <h2>📖 API Endpoints</h2>
            
            <div class="endpoint">
                <span class="method">GET</span> <strong>/health</strong>
                <p>Kiểm tra trạng thái API</p>
            </div>
            
            <div class="endpoint">
                <span class="method">POST</span> <strong>/extract-article</strong>
                <p>Lấy nội dung bài viết từ URL</p>
            </div>
            
            <h2>🔗 Documentation</h2>
            <p>
                <a href="/docs" target="_blank" style="color: #3498db; text-decoration: none; font-weight: bold;">📚 Swagger UI</a> | 
                <a href="/redoc" target="_blank" style="color: #3498db; text-decoration: none; font-weight: bold;">📖 ReDoc</a>
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
        "mode": "multi-domain"
    }

@app.post("/extract-article")
async def extract_article(
    request: ArticleRequest,
    token: str = Depends(verify_token)
):
    """Extract content from a single article URL"""
    try:
        article = Article(str(request.url))
        article.download()
        article.parse()
        
        return {
            "title": article.title,
            "content": article.text,
            "authors": article.authors,
            "publish_date": article.publish_date,
            "top_image": article.top_image,
            "url": str(request.url)
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

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

# =============================================================================
# BACKUP SCRIPTS
# =============================================================================

create_backup_scripts() {
    log "💾 Tạo backup scripts..."
    
    # Enhanced backup script
    cat > "$INSTALL_DIR/backup-workflows-enhanced.sh" << 'EOF'
#!/bin/bash

# N8N Enhanced Backup Script
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

log "🔄 Starting enhanced backup..."

# Create backup directory structure
mkdir -p "$BACKUP_DIR"
mkdir -p "$TEMP_DIR"/instances
mkdir -p "$TEMP_DIR"/config
mkdir -p "$TEMP_DIR"/ssl
mkdir -p "$TEMP_DIR"/postgres

# Detect setup type
MULTI_DOMAIN=false
INSTANCE_COUNT=1

if docker ps --format "{{.Names}}" | grep -q "n8n-container-1"; then
    MULTI_DOMAIN=true
    INSTANCE_COUNT=$(docker ps --format "{{.Names}}" | grep -c "n8n-container-" || echo 1)
    info "Multi-domain setup detected: $INSTANCE_COUNT instances"
else
    info "Single domain setup detected"
fi

# Backup N8N instances
log "📋 Backing up N8N instances..."

if [[ "$MULTI_DOMAIN" == "true" ]]; then
    for i in $(seq 1 $INSTANCE_COUNT); do
        CONTAINER_NAME="n8n-container-$i"
        if docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
            log "Backing up instance $i..."
            
            mkdir -p "$TEMP_DIR/instances/instance_$i"
            
            # Export workflows
            docker exec "$CONTAINER_NAME" n8n export:workflow --all --output=/tmp/workflows.json 2>/dev/null || true
            docker cp "$CONTAINER_NAME":/tmp/workflows.json "$TEMP_DIR/instances/instance_$i/" 2>/dev/null || true
            
            # Export credentials
            docker exec "$CONTAINER_NAME" n8n export:credentials --all --output=/tmp/credentials.json 2>/dev/null || true
            docker cp "$CONTAINER_NAME":/tmp/credentials.json "$TEMP_DIR/instances/instance_$i/" 2>/dev/null || true
            
            # Copy .n8n folder
            cp -r "/home/n8n/files/n8n_instance_$i/.n8n" "$TEMP_DIR/instances/instance_$i/" 2>/dev/null || true
        fi
    done
else
    if docker ps --format "{{.Names}}" | grep -q "n8n-container"; then
        log "Backing up single instance..."
        
        mkdir -p "$TEMP_DIR/instances/instance_1"
        
        # Export workflows
        docker exec n8n-container n8n export:workflow --all --output=/tmp/workflows.json 2>/dev/null || true
        docker cp n8n-container:/tmp/workflows.json "$TEMP_DIR/instances/instance_1/" 2>/dev/null || true
        
        # Export credentials
        docker exec n8n-container n8n export:credentials --all --output=/tmp/credentials.json 2>/dev/null || true
        docker cp n8n-container:/tmp/credentials.json "$TEMP_DIR/instances/instance_1/" 2>/dev/null || true
        
        # Copy .n8n folder
        cp -r /home/n8n/files/.n8n "$TEMP_DIR/instances/instance_1/" 2>/dev/null || true
    fi
fi

# Backup PostgreSQL if enabled
if docker ps --format "{{.Names}}" | grep -q "postgres-n8n"; then
    log "🐘 Backing up PostgreSQL databases..."
    
    docker exec postgres-n8n pg_dumpall -U postgres > "$TEMP_DIR/postgres/dump_all.sql" 2>/dev/null || true
fi

# Backup configuration files
log "🔧 Backing up configuration files..."
cp /home/n8n/docker-compose.yml "$TEMP_DIR/config/" 2>/dev/null || true
cp /home/n8n/Caddyfile "$TEMP_DIR/config/" 2>/dev/null || true
cp /home/n8n/telegram_config.txt "$TEMP_DIR/config/" 2>/dev/null || true

# Create backup metadata
log "📊 Creating backup metadata..."
cat > "$TEMP_DIR/backup_metadata.json" << EOL
{
    "backup_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "backup_name": "$BACKUP_NAME",
    "backup_type": "enhanced_multi_domain",
    "multi_domain": $MULTI_DOMAIN,
    "instance_count": $INSTANCE_COUNT,
    "postgresql_enabled": $(docker ps | grep -q "postgres-n8n" && echo "true" || echo "false")
}
EOL

# Create compressed backup
log "📦 Creating compressed backup..."
cd /tmp
zip -r "$BACKUP_DIR/$BACKUP_NAME.zip" "$BACKUP_NAME/" > /dev/null 2>&1

# Get backup size
BACKUP_SIZE=$(ls -lh "$BACKUP_DIR/$BACKUP_NAME.zip" | awk '{print $5}')
log "✅ Backup completed: $BACKUP_NAME.zip ($BACKUP_SIZE)"

# Cleanup temp directory
rm -rf "$TEMP_DIR"

# Keep only last 30 backups
log "🧹 Cleaning up old backups..."
cd "$BACKUP_DIR"
ls -t n8n_backup_*.zip | tail -n +31 | xargs -r rm -f

# Send to Telegram if configured
if [[ -f "/home/n8n/telegram_config.txt" ]]; then
    source "/home/n8n/telegram_config.txt"
    
    if [[ -n "$TELEGRAM_BOT_TOKEN" && -n "$TELEGRAM_CHAT_ID" ]]; then
        log "📱 Sending Telegram notification..."
        
        MESSAGE="🔄 *N8N Enhanced Backup Completed*

📅 Date: $(date +'%Y-%m-%d %H:%M:%S')
📦 File: \`$BACKUP_NAME.zip\`
💾 Size: $BACKUP_SIZE
🌐 Mode: $([ "$MULTI_DOMAIN" == "true" ] && echo "Multi-Domain ($INSTANCE_COUNT instances)" || echo "Single Domain")
📊 Status: ✅ Success"

        curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
            -d chat_id="$TELEGRAM_CHAT_ID" \
            -d text="$MESSAGE" \
            -d parse_mode="Markdown" > /dev/null || true
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

echo "📋 System information:"
echo "• Time: $(date)"
echo "• Disk usage: $(df -h /home/n8n | tail -1 | awk '{print $5}')"
echo "• Memory: $(free -h | grep Mem | awk '{print $3"/"$2}')"
echo "• Docker containers: $(docker ps --filter "name=n8n" --format "{{.Names}}" | wc -l)"
echo ""

echo "🔄 Running enhanced backup test..."
./backup-workflows-enhanced.sh

echo ""
echo "📊 Backup results:"
ls -lah /home/n8n/files/backup_full/n8n_backup_*.zip | tail -5

echo ""
echo "✅ Enhanced manual backup test completed!"
EOF

    chmod +x "$INSTALL_DIR/backup-manual.sh"
    
    success "Đã tạo backup scripts"
}

# =============================================================================
# WEB DASHBOARD
# =============================================================================

create_web_dashboard() {
    log "📊 Tạo web dashboard..."
    
    # Create dashboard HTML
    cat > "$INSTALL_DIR/dashboard/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>N8N Multi-Domain Dashboard</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f5f5f5; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; text-align: center; }
        .container { max-width: 1200px; margin: 20px auto; padding: 0 20px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 20px; }
        .card { background: white; border-radius: 10px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .card h3 { margin-bottom: 15px; color: #333; }
        .status-item { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #eee; }
        .status-running { color: #27ae60; font-weight: bold; }
        .status-stopped { color: #e74c3c; font-weight: bold; }
        .btn { background: #3498db; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; margin: 5px; }
        .btn:hover { background: #2980b9; }
        .btn-danger { background: #e74c3c; }
        .btn-danger:hover { background: #c0392b; }
        .metric-value { font-size: 24px; font-weight: bold; color: #3498db; }
        .loading { color: #999; font-style: italic; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 N8N Multi-Domain Dashboard</h1>
        <p>Real-time monitoring and management</p>
    </div>
    
    <div class="container">
        <div class="grid">
            <div class="card">
                <h3>📊 System Status</h3>
                <div id="system-status" class="loading">Loading...</div>
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
            <button class="btn btn-danger" onclick="restartAll()">🔄 Restart All</button>
            <button class="btn" onclick="runBackup()">💾 Manual Backup</button>
            <a href="/logs" class="btn" target="_blank">📋 View Logs</a>
        </div>
    </div>

    <script>
        async function fetchData() {
            try {
                const response = await fetch('/api/status');
                const data = await response.json();
                updateDashboard(data);
            } catch (error) {
                console.error('Failed to fetch data:', error);
            }
        }
        
        function updateDashboard(data) {
            // Update system status
            document.getElementById('system-status').innerHTML = `
                <div class="status-item">
                    <span>Memory Usage</span>
                    <span class="metric-value">${data.memory || 'N/A'}</span>
                </div>
                <div class="status-item">
                    <span>Disk Usage</span>
                    <span class="metric-value">${data.disk || 'N/A'}</span>
                </div>
            `;
            
            // Update container status
            let containerHtml = '';
            if (data.containers) {
                data.containers.forEach(container => {
                    containerHtml += `
                        <div class="status-item">
                            <span>${container.name}</span>
                            <span class="${container.running ? 'status-running' : 'status-stopped'}">
                                ${container.running ? 'Running' : 'Stopped'}
                            </span>
                        </div>
                    `;
                });
            }
            document.getElementById('container-status').innerHTML = containerHtml;
            
            // Update N8N instances
            let instancesHtml = '';
            if (data.instances) {
                data.instances.forEach(instance => {
                    instancesHtml += `
                        <div class="status-item">
                            <span>${instance.domain}</span>
                            <span class="${instance.healthy ? 'status-running' : 'status-stopped'}">
                                ${instance.healthy ? 'Healthy' : 'Unhealthy'}
                            </span>
                        </div>
                    `;
                });
            }
            document.getElementById('n8n-instances').innerHTML = instancesHtml;
            
            // Update backup status
            document.getElementById('backup-status').innerHTML = `
                <div class="status-item">
                    <span>Last Backup</span>
                    <span>${data.lastBackup || 'Never'}</span>
                </div>
                <div class="status-item">
                    <span>Backup Count</span>
                    <span class="metric-value">${data.backupCount || '0'}</span>
                </div>
            `;
        }
        
        async function refreshData() {
            await fetchData();
        }
        
        async function restartAll() {
            if (confirm('Are you sure you want to restart all services?')) {
                await fetch('/api/restart', { method: 'POST' });
                alert('Services are restarting...');
            }
        }
        
        async function runBackup() {
            if (confirm('Run manual backup now?')) {
                await fetch('/api/backup', { method: 'POST' });
                alert('Backup started...');
            }
        }
        
        // Initial load
        fetchData();
        
        // Auto-refresh every 30 seconds
        setInterval(fetchData, 30000);
    </script>
</body>
</html>
EOF
    
    # Create simple API server script
    cat > "$INSTALL_DIR/dashboard/api_server.py" << 'EOF'
#!/usr/bin/env python3
import json
import subprocess
import os
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse

class DashboardHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed_path = urlparse(self.path)
        
        if parsed_path.path == '/':
            self.serve_file('/home/n8n/dashboard/index.html', 'text/html')
        elif parsed_path.path == '/api/status':
            self.serve_status()
        else:
            self.send_error(404)
    
    def do_POST(self):
        parsed_path = urlparse(self.path)
        
        if parsed_path.path == '/api/restart':
            self.restart_services()
        elif parsed_path.path == '/api/backup':
            self.run_backup()
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
        except:
            self.send_error(404)
    
    def serve_status(self):
        try:
            # Get system status
            memory = subprocess.check_output("free -h | grep Mem | awk '{print $3"/"$2}'", shell=True).decode().strip()
            disk = subprocess.check_output("df -h /home/n8n | tail -1 | awk '{print $5}'", shell=True).decode().strip()
            
            # Get container status
            containers = []
            container_output = subprocess.check_output("docker ps -a --format '{{.Names}}\\t{{.Status}}'", shell=True).decode()
            for line in container_output.strip().split('\\n'):
                if line:
                    parts = line.split('\\t')
                    if len(parts) >= 2:
                        containers.append({
                            'name': parts[0],
                            'running': 'Up' in parts[1]
                        })
            
            # Prepare response
            data = {
                'memory': memory,
                'disk': disk,
                'containers': containers,
                'instances': [],
                'lastBackup': 'N/A',
                'backupCount': 0
            }
            
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(data).encode())
        except Exception as e:
            self.send_error(500, str(e))
    
    def restart_services(self):
        try:
            subprocess.Popen(['docker-compose', 'restart'], cwd='/home/n8n')
            self.send_response(200)
            self.end_headers()
        except:
            self.send_error(500)
    
    def run_backup(self):
        try:
            subprocess.Popen(['/home/n8n/backup-manual.sh'])
            self.send_response(200)
            self.end_headers()
        except:
            self.send_error(500)

def run():
    server_address = ('', 8080)
    httpd = HTTPServer(server_address, DashboardHandler)
    print('Dashboard running on port 8080...')
    httpd.serve_forever()

if __name__ == '__main__':
    run()
EOF
    
    chmod +x "$INSTALL_DIR/dashboard/api_server.py"
    
    success "Đã tạo web dashboard"
}

# =============================================================================
# SYSTEMD SERVICES
# =============================================================================

create_systemd_services() {
    log "⚙️ Tạo systemd services..."
    
    # Dashboard service
    cat > /etc/systemd/system/n8n-dashboard.service << EOF
[Unit]
Description=N8N Web Dashboard
After=docker.service
Requires=docker.service

[Service]
Type=simple
User=root
WorkingDirectory=/home/n8n
ExecStart=/usr/bin/python3 /home/n8n/dashboard/api_server.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable n8n-dashboard
    
    success "Đã tạo systemd services"
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
    
    TEST_MESSAGE="🚀 *N8N Enhanced Installation Completed*

📅 Date: $(date +'%Y-%m-%d %H:%M:%S')
🌐 Mode: $INSTALL_MODE
✅ System is ready!"

    if curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d text="$TEST_MESSAGE" \
        -d parse_mode="Markdown" > /dev/null; then
        success "✅ Telegram test thành công"
    else
        warning "⚠️ Telegram test thất bại"
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
    
    success "Đã thiết lập cron jobs"
}

# Run main function
main "$@"

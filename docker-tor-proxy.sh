#!/bin/bash
TOR_SERVICE="tor"
DOCKER_PROXY_CONF="/etc/systemd/system/docker.service.d/http-proxy.conf"
BACKUP_FILE="/tmp/docker-proxy-backup.conf"

set -e
check_sudo  # Check sudo first

# Check if Tor is installed
check_tor_installed() {
  if ! command -v tor &> /dev/null; then
    log_error "Tor is not installed. Please install Tor using: sudo apt install tor"
  fi
}

# Check if Docker is installed
check_docker_installed() {
  if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed. Please install Docker using: sudo apt install docker"
  fi
}

# Check if Tor service is active
check_tor_service() {
  if ! sudo systemctl is-active --quiet $TOR_SERVICE; then
    log_error "Tor service is not running. Please start Tor with: sudo systemctl start tor"
  fi
}

# Check if torsocks is installed
check_torsocks_installed() {
  if ! command -v torsocks &> /dev/null; then
    log_error "torsocks is not installed. Please install it using: sudo apt install torsocks"
  fi
}

# Check if the system is connected to the Tor network
check_tor_connection() {
  check_torsocks_installed
  set +e  # Disable set -e temporarily
  if torsocks curl -s --max-time 10 https://check.torproject.org/api/ip | grep -q '"IsTor":true'; then
    log_success "Tor connection is working"
  else
    log_error "Tor connection failed (timeout or network issue)"
  fi
  set -e  # Re-enable set -e
}

# Check sudo access
check_sudo() {
  if ! sudo -n true 2>/dev/null; then
    log_error "This script requires sudo privileges. Please run with sudo or as root."
  fi
}

# Backup Docker proxy configuration
backup_docker_config() {
  if [ -f $DOCKER_PROXY_CONF ]; then
    if sudo cp $DOCKER_PROXY_CONF $BACKUP_FILE; then
      log_success "Docker proxy configuration backed up"
    else
      log_error "Failed to backup Docker proxy configuration"
    fi
  else
    log_error "No Docker proxy configuration found to backup"
  fi
}

# Restore Docker proxy configuration from backup
restore_backup() {
  if [ -f $BACKUP_FILE ]; then
    if sudo cp $BACKUP_FILE $DOCKER_PROXY_CONF; then
      sudo systemctl daemon-reload
      sudo systemctl restart docker
      log_success "Docker configuration restored from backup"
    else
      log_error "Failed to restore Docker configuration from backup"
    fi
  else
    log_error "No backup found"
  fi
}

# Apply Docker proxy settings
apply_docker_proxy() {
  check_tor_installed
  check_docker_installed
  check_tor_service
  log_info "Applying Docker proxy settings to use Tor..."

  # Ensure necessary directory exists
  sudo mkdir -p /etc/systemd/system/docker.service.d

  # If Docker proxy configuration exists, back it up
  if [ -f $DOCKER_PROXY_CONF ]; then
    log_info "Existing Docker proxy config found. Backing it up..."
    backup_docker_config
  fi

  # Apply proxy settings
  sudo bash -c "cat > $DOCKER_PROXY_CONF <<EOF
[Service]
Environment=\"HTTP_PROXY=socks5h://127.0.0.1:9050\"
Environment=\"HTTPS_PROXY=socks5h://127.0.0.1:9050\"
Environment=\"ALL_PROXY=socks5h://127.0.0.1:9050\"
Environment=\"NO_PROXY=localhost,127.0.0.1,.docker.internal\"
EOF"
  
  restart_docker
  log_success "Docker proxy settings applied successfully"
}

# Remove Docker proxy settings
remove_docker_proxy() {
  if [ -f $DOCKER_PROXY_CONF ]; then
    log_info "Removing Docker proxy settings..."
    sudo rm -f $DOCKER_PROXY_CONF
    restart_docker
    log_success "Docker proxy settings removed"
  else
    log_info "Docker proxy settings not found"
  fi
}

# Restart Docker service
restart_docker() {
  if ! sudo systemctl daemon-reload || ! sudo systemctl restart docker; then
    log_error "Failed to restart Docker service"
  fi
  if ! sudo systemctl is-active --quiet docker; then
    log_error "Docker service is not active after restart"
  fi
  log_success "Docker service restarted successfully"
}

# Show Docker proxy status
docker_proxy_status() {
  if [ -f $DOCKER_PROXY_CONF ]; then
    log_success "Docker is configured to use the Tor proxy"
  else
    log_info "Docker is not using the Tor proxy"
  fi
}

# Log success messages
log_success() {
  echo "✅ SUCCESS: $1"
}

# Log error messages
log_error() {
  echo "❌ ERROR: $1"
  exit 1
}

# Log informational messages
log_info() {
  echo "ℹ️ INFO: $1"
}

# Script main logic
case "$1" in
  start)
    apply_docker_proxy
    ;;
  stop)
    remove_docker_proxy
    ;;
  status)
    docker_proxy_status
    ;;
  restart)
    apply_docker_proxy
    ;;
  check-tor)
    check_tor_connection
    ;;
  backup)
    backup_docker_config
    ;;
  restore)
    restore_backup
    ;;
  *)
    echo "Usage: $0 {start|stop|status|restart|check-tor|backup|restore}"
    exit 1
    ;;
esac

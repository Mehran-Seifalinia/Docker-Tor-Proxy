#!/bin/bash
TOR_SERVICE="tor"
TOR_PORT=9050
DOCKER_PROXY_CONF="/etc/systemd/system/docker.service.d/http-proxy.conf"
BACKUP_FILE="/etc/systemd/system/docker.service.d/.docker-proxy-backup.conf"

set -e

# Check root/sudo access
if [ "$EUID" -ne 0 ]; then
  echo "❌ ERROR: This script requires sudo privileges. Please run with sudo or as root." >&2
  exit 1
fi

# Function to install Tor if not installed
install_tor() {
  log_info "Installing Tor..."
  sudo apt update
  sudo apt install -y tor
  log_info "Starting and enabling Tor service..."
  sudo systemctl enable --now tor
}

# Function to install torsocks if not installed
install_torsocks() {
  log_info "Installing torsocks..."
  sudo apt update
  sudo apt install -y torsocks
}

# Install curl if not present
install_curl() {
  if ! command -v curl &> /dev/null; then
    log_info "Installing curl..."
    sudo apt update
    sudo apt install -y curl
  fi
}

# Check if Tor is installed
check_tor_installed() {
  if ! command -v tor &> /dev/null; then
    log_info "Tor is not installed. Installing Tor..."
    install_tor
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
    log_info "torsocks is not installed. Installing torsocks..."
    install_torsocks
  fi
}

# Check if the system is connected to the Tor network
check_tor_connection() {
  check_torsocks_installed
  install_curl
  set +e
  local max_attempts=12
  local attempt=0
  while [ $attempt -lt $max_attempts ]; do
    if torsocks curl -s --max-time 10 https://check.torproject.org/api/ip 2>/dev/null | grep -q '"IsTor":true'; then
      log_success "Tor connection is working"
      set -e
      return 0
    fi
    attempt=$((attempt+1))
    if [ $attempt -lt $max_attempts ]; then
      log_info "Waiting for Tor connection... (attempt $attempt/$max_attempts)"
      sleep 5
    fi
  done
  log_error "Tor connection failed after $max_attempts attempts"
  set -e
}

# Backup Docker proxy configuration
backup_docker_config() {
  if [ -f $DOCKER_PROXY_CONF ] && [ ! -f $BACKUP_FILE ]; then
    if sudo cp $DOCKER_PROXY_CONF $BACKUP_FILE; then
      log_success "Docker proxy configuration backed up"
    else
      log_error "Failed to backup Docker proxy configuration"
    fi
  elif [ -f $BACKUP_FILE ]; then
    log_info "Backup already exists, skipping backup to preserve original config"
  else
    log_info "No Docker proxy configuration found to backup"
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
  log_info "Waiting for Tor network connection..."
  check_tor_connection
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
Environment=\"HTTP_PROXY=socks5h://127.0.0.1:$TOR_PORT\"
Environment=\"HTTPS_PROXY=socks5h://127.0.0.1:$TOR_PORT\"
Environment=\"ALL_PROXY=socks5h://127.0.0.1:$TOR_PORT\"
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
  # Also remove backup if it matches the current (Tor) config? Better keep backup for restore.
}

# Restart Docker service
restart_docker() {
  if ! sudo systemctl daemon-reload; then
    log_error "Failed to reload systemd daemon"
  fi
  if ! sudo systemctl restart docker; then
    log_error "Failed to restart Docker service"
  fi
  sleep 2
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
    if [ -f $BACKUP_FILE ]; then
      restore_backup
    else
      remove_docker_proxy
    fi
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

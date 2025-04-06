
# Docker Tor Proxy

This project is a simple script that allows you to configure Docker to route all external connections through the Tor network. The script automatically installs and configures the necessary services, enabling you to run and manage Docker with Tor seamlessly.

## Prerequisites

- **Docker** must be installed.
- Root (sudo) access is required to modify system configuration files and install packages.
- This script is optimized for Debian-based systems (e.g., Ubuntu, Debian).
- Note: Tor and Torsocks will be automatically installed by the script if not present.
- Note: This script uses `apt` and `systemctl`, so it may require adjustments for non-Debian-based systems (e.g., Fedora, Arch).

## Tools Used

- **Tor**: An anonymity network that allows you to route your internet traffic through various nodes in the Tor network, ensuring privacy and security.
- **Torsocks**: A tool that forces network connections to go through Tor, enabling applications to use Tor for their network communications.
- **Docker**: A containerization platform that enables you to run applications in isolated environments (containers), making them portable and efficient.

### Why Use Tor for Docker?

Using Tor for Docker connections can be beneficial for several reasons:
- **Privacy and Anonymity**: All Docker network requests are routed through the Tor network, hiding your IP and location.
- **Bypass Censorship**: In countries with strict internet censorship, Tor allows you to bypass network restrictions and access Docker images and external services.
- **Security**: Tor adds an additional layer of security by masking your external connections and preventing your IP address from being exposed.

## Features

- **Install Tor and Torsocks**: Automatically installs Tor and Torsocks if they are not already present.
- **Configure Docker Proxy Settings**: Updates Docker to use Tor for outgoing traffic.
- **Control Docker Proxy Settings**: Manage the setup with simple commands (start, stop, status, etc.).
- **Automatic Backup**: Backs up existing Docker proxy settings before applying changes.

## Installation

To configure Docker to use Tor as a proxy, follow these steps:

1. Make the script executable:
```bash
sudo chmod +x docker-tor-proxy.sh
```

2. Run the script to install dependencies and apply proxy settings:
```bash
sudo ./docker-tor-proxy.sh start
```

**Note:** The script will automatically install Tor and Torsocks if they are not already present.

## Available Commands

You can manage the Docker Tor Proxy setup using the following commands:

### `start`

Start Docker with the Tor proxy configuration enabled:

```bash
./docker-tor-proxy.sh start
```

### `stop`

Stop Docker and disable the Tor proxy configuration:

```bash
./docker-tor-proxy.sh stop
```

### `status`

Check the current status of Docker and Tor services:

```bash
./docker-tor-proxy.sh status
```

### `restart`

Restart Docker with the Tor proxy configuration:

```bash
./docker-tor-proxy.sh restart
```

### `check-tor`

Check if the system is connected to the Tor network:

```bash
./docker-tor-proxy.sh check-tor
```

### `backup`

Create a backup of the current Docker proxy configuration:

```bash
./docker-tor-proxy.sh backup
```

### `restore`

Restore the Docker proxy configuration from the backup:

```bash
./docker-tor-proxy.sh restore
```

## How It Works

1. **Install Tor and Torsocks**: The script installs Tor and Torsocks if they are not already present on your system.
2. **Configure Docker**: Updates Docker’s systemd service to route traffic through Tor using `socks5h://127.0.0.1:9050` (default Tor port). Modify the `TOR_PORT` variable in the script to use a different port.
3. **Manage Proxy Settings**: Provides commands to enable, disable, check, and restart the Docker Tor proxy.

## Troubleshooting

- **Tor not running**: Start Tor ->
  ```bash
  sudo systemctl start tor
  ```
- **Installation fails:** Ensure you have an active internet connection and sufficient permissions ->
  ```bash
  sudo apt update && sudo apt install -y tor torsocks
  ```
- **Docker not restarting:** Restart manually ->
  ```bash
  sudo systemctl restart docker
  ```
- **Permission denied** TUse sudo ->
  ```bash
  sudo ./docker-tor-proxy.sh start
  ```

### Common Issues:
- **Tor is not running**: Ensure that the Tor service is started with the following command:
  ```bash
  sudo systemctl start tor
  ```
- **Docker not restarting properly**: Restart Docker using the following command:
  ```bash
  sudo systemctl restart docker
  ```
- **Root access needed**: Ensure that you are using `sudo` where required for modifying system configurations.

## Backup and Restore

The script automatically backs up existing Docker proxy settings before changes. Restore them with:

```bash
sudo ./docker-tor-proxy.sh restore
```

## Security Considerations

- Use this script responsibly and legally. Tor is a powerful tool for privacy but must be used with care.
- Ensure that you understand the security implications of routing all traffic through Tor, especially if used in production environments.

## License

This project is open-source and distributed under the MIT License.

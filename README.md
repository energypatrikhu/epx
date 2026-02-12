# EPX Shell Scripts

> **Heads up:** This is a hobby project. While useful, it may contain bugs or breaking changes. Use at your own risk and always review scripts before running them on important systems.

EPX is a collection of shell scripts and utilities designed to simplify and automate common system administration tasks on Linux. It provides handy commands for working with Docker, Python environments, file management, firewall (ufw), and more.

## Features

**Container & Virtualization:**
- Docker management (run, exec, logs, stats, compose generation, etc.)
- Docker container operations (start, stop, restart, remove, attach, shell access)
- Minecraft server management (For more details, checkout [minecraft-server](commands/game-servers/minecraft/README.md))
- Linux Game Server Manager (LinuxGSM) integration

**Python Development:**
- Virtual environment creation and management
- Package installation and management
- Python environment activation and configuration
- PM2 integration for Python applications

**File System Operations:**
- Archive creation and extraction (7z, tar, zst, tar.zst)
- Disk usage analysis and management
- Trash management (clear, list)
- File creation utilities (dummy files)
- Compression tools with lite options

**Network & Firewall:**
- UFW firewall rule management (add, delete, list, status)
- Samba/SMB share management (add, delete, list, restart)
- IP information lookup
- Network utilities

**IT Utilities:**
- Base64 encoding/decoding
- Hash generation (MD5, SHA1, SHA256, etc.)
- HMAC generation
- QR code generation (including WiFi QR codes)
- Barcode generation
- Regular expression testing and extraction
- URL/HTML encoding and decoding
- UUID generation
- Random utilities (numbers, strings, ports)
- Timestamp conversion and timezone info
- User agent information

**Shell & Editor:**
- Fish shell configuration and setup
- Micro editor integration and setup

**System Utilities:**
- Command shortcuts and aliases
- Disk space utilities (du-all, gtop for system overview)
- Process listing (lsp, lse)
- File finding utilities (ff)
- Docker compose utilities (automatic detection)
- Autocompletion for bash and fish shells

**EPX Management:**
- Self-update functionality
- Help system for all commands

## Installation
```bash
curl https://raw.githubusercontent.com/energypatrikhu/epx/refs/heads/main/install.sh | sudo bash -
```

## Updating
To update EPX to the latest version, simply run:
```bash
epx self-update
```
This command will fetch and apply the latest changes from the repository.

## Usage
After installation, use the provided commands and aliases to streamline your workflow. See the `commands/` and `helpers/` directories for available scripts.

## Configuration Directory

EPX stores its configuration and data in the `.config` directory located inside the `EPX_HOME` directory. These are not user-specific configs, but are used by EPX to manage its own settings and persistent data. Example configuration files with the `.example` extension are provided in this directory to show what options are available and how to customize them if needed.

## Templates

EPX includes a set of templates to help you quickly create common configuration or script files. These templates can be copied and customized for your own use. Look for template files in the project directories, and use them as a starting point for your own scripts or configurations.

---
This project is intended for users comfortable with the Linux command line.

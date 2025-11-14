# 🧹 Dikans Boot - Mac System Data Cleanup

A beautiful, interactive terminal script for cleaning up system data on macOS. Free up gigabytes of disk space with a gorgeous UI, smart prompts, and safe deletion practices.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![Shell](https://img.shields.io/badge/shell-zsh-green.svg)

## ✨ Features

- 🎨 **Beautiful Terminal UI** - Colorful interface with progress indicators and visual feedback
- 🔒 **Safe & Interactive** - Prompts before deleting large caches, shows sizes before cleanup
- 📊 **Real-time Stats** - Shows space freed with human-readable sizes (GB/MB/KB)
- 🧪 **Dry Run Mode** - Preview what will be deleted without actually removing anything
- 🎯 **Smart Detection** - Only cleans what exists on your system, skips missing tools
- 📦 **Comprehensive Coverage** - Cleans development tools, browsers, and system caches

## 🎬 Screenshot

```
  ██████╗ ██╗██╗  ██╗ █████╗ ███╗   ██╗███████╗
  ██╔══██╗██║██║ ██╔╝██╔══██╗████╗  ██║██╔════╝
  ██║  ██║██║█████╔╝ ███████║██╔██╗ ██║███████╗
  ██║  ██║██║██╔═██╗ ██╔══██║██║╚██╗██║╚════██║
  ██████╔╝██║██║  ██╗██║  ██║██║ ╚████║███████║
  ╚═════╝ ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝
  ██████╗  ██████╗  ██████╗ ████████╗
  ██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝
  ██████╔╝██║   ██║██║   ██║   ██║   
  ██╔══██╗██║   ██║██║   ██║   ██║   
  ██████╔╝╚██████╔╝╚██████╔╝   ██║   
  ╚═════╝  ╚═════╝  ╚═════╝    ╚═╝   

╭──────────────────────────────────────────────────────────────────────╮
│                   🧹  MAC SYSTEM DATA CLEANUP                        │
╰──────────────────────────────────────────────────────────────────────╯
```

## 🧰 What Gets Cleaned

### 🔥 High Priority
- **Yarn Cache** - Node.js package manager cache
- **Xcode DerivedData** - Xcode build artifacts and indexes
- **iOS Simulator Data** - Old simulator devices and logs
- **CocoaPods Cache** - iOS dependency manager cache

### 📦 Medium Priority
- **Browser Caches** - Arc, The Browser, Comet
- **Homebrew Cache** - Package manager downloads and old versions
- **node-gyp Cache** - Native addon build cache

### 🔧 Optional
- **TypeScript Cache** - Compiler cache
- **Cypress Cache** - E2E testing framework binaries

## 🚀 Installation

### Quick Install

```bash
# Download the script
curl -O https://raw.githubusercontent.com/yourusername/dikans-boot/main/mac_system_data_cleanup.zsh

# Make it executable
chmod +x mac_system_data_cleanup.zsh

# Run it
./mac_system_data_cleanup.zsh
```

### Clone Repository

```bash
git clone https://github.com/yourusername/dikans-boot.git
cd dikans-boot
chmod +x mac_system_data_cleanup.zsh
./mac_system_data_cleanup.zsh
```

## 💻 Usage

### Run Cleanup
```bash
./mac_system_data_cleanup.zsh
```

### Dry Run (Preview Only)
See what would be deleted without actually removing anything:
```bash
./mac_system_data_cleanup.zsh --dry-run
```

### Before Running
⚠️ **Close these applications first:**
- Xcode & iOS Simulator
- Arc, The Browser, Comet
- Terminal sessions running `yarn`, `pod`, or `brew`

## 📋 Requirements

- macOS (tested on macOS 10.14+)
- zsh shell (default on macOS Catalina+)
- Admin permissions for some cache directories

## 🎯 How It Works

1. **Scans** your system for cache directories
2. **Shows sizes** of what can be cleaned
3. **Prompts** for confirmation on large deletions
4. **Safely removes** approved caches
5. **Reports** total space freed

The script uses `du` to calculate sizes, `rm -rf` for safe deletion, and never touches:
- Your personal files
- Application data
- System files
- Active projects

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new features
- Add support for more caches
- Improve the UI

## 📝 License

MIT License - feel free to use, modify, and distribute!

## ⚠️ Disclaimer

This script deletes cache files. While it's designed to be safe and only removes rebuildable caches:
- **Always run with `--dry-run` first** to preview changes
- **Backup important data** before running
- **Close relevant applications** to avoid corruption
- The author is not responsible for any data loss

## 🙏 Credits

Created by **Dikans** - A full-stack developer passionate about clean systems and beautiful terminal UIs.

## 📊 Typical Results

Users typically free up:
- **5-15 GB** for active developers
- **20-50 GB** for iOS/React Native developers with simulators
- **1-5 GB** for general users

---

**Star ⭐ this repo if it helped you clean up your Mac!**

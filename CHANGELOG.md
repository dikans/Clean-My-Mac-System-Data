# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-14

### Added
- Initial release of Dikans Boot
- Beautiful terminal UI with colors and ASCII art banner
- Interactive prompts for high-impact deletions
- Dry run mode (`--dry-run` flag)
- Support for cleaning:
  - Yarn cache
  - Xcode DerivedData
  - iOS Simulator data
  - CocoaPods cache
  - Browser caches (Arc, The Browser, Comet)
  - Homebrew cache
  - node-gyp cache
  - TypeScript cache
  - Cypress cache
- Real-time space calculation and reporting
- Human-readable size formatting (GB/MB/KB)
- Smart detection of installed tools
- Progress indicators and status symbols
- Comprehensive documentation

### Features
- Safe deletion with confirmation prompts
- Shows sizes before deletion
- Calculates total freed space
- Works on any macOS system
- Automatically uses current user's home directory

---

## Future Ideas

- [ ] Add support for npm cache
- [ ] Add support for Docker cleanup
- [ ] Add interactive cache selection menu
- [ ] Add scheduled cleanup option
- [ ] Add configuration file support
- [ ] Add support for more browsers
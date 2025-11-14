#!/usr/bin/env zsh
# Interactive Mac System Data cleanup for /Users/d1k4ns
# Beautiful terminal UI with colors, progress, and visual feedback

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

TOTAL_FREED_KB=0
free_before_kb=$(df -k / | awk 'NR==2 {print $4}')

# Color definitions
if [[ -t 1 ]]; then
  RESET='\033[0m'
  BOLD='\033[1m'
  DIM='\033[2m'
  
  # Colors
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  MAGENTA='\033[0;35m'
  CYAN='\033[0;36m'
  WHITE='\033[0;37m'
  
  # Bold colors
  BRED='\033[1;31m'
  BGREEN='\033[1;32m'
  BYELLOW='\033[1;33m'
  BBLUE='\033[1;34m'
  BMAGENTA='\033[1;35m'
  BCYAN='\033[1;36m'
  BWHITE='\033[1;97m'
else
  RESET='' BOLD='' DIM=''
  RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' WHITE=''
  BRED='' BGREEN='' BYELLOW='' BBLUE='' BMAGENTA='' BCYAN='' BWHITE=''
fi

# Box drawing characters
CORNER_TL='╭'
CORNER_TR='╮'
CORNER_BL='╰'
CORNER_BR='╯'
HORIZ='─'
VERT='│'
TEE_R='├'
TEE_L='┤'

human_kb() {
  local kb=$1
  awk -v k="$kb" 'BEGIN {
    if (k >= 1048576) { printf "%.2f GB", k/1048576 }
    else if (k >= 1024) { printf "%.2f MB", k/1024 }
    else { printf "%d KB", k }
  }'
}

path_size_kb() { local p="$1"; [ -e "$p" ] || { echo 0; return; }; du -sk "$p" 2>/dev/null | awk '{print $1}'; }
path_size_h()  { local p="$1"; [ -e "$p" ] || { echo "0B"; return; }; du -sh "$p" 2>/dev/null | awk '{print $1}'; }

print_header() {
  local text="$1"
  local width=70
  local text_len=${#text}
  local padding=$(( (width - text_len - 2) / 2 ))
  
  echo ""
  printf "${BCYAN}${CORNER_TL}"
  printf "${HORIZ}%.0s" {1..$width}
  printf "${CORNER_TR}${RESET}\n"
  
  printf "${BCYAN}${VERT}${RESET}"
  printf "%*s" $padding ""
  printf "${BWHITE}${text}${RESET}"
  printf "%*s" $(( width - text_len - padding )) ""
  printf "${BCYAN}${VERT}${RESET}\n"
  
  printf "${BCYAN}${CORNER_BL}"
  printf "${HORIZ}%.0s" {1..$width}
  printf "${CORNER_BR}${RESET}\n"
  echo ""
}

print_section() {
  local icon="$1"
  local text="$2"
  echo ""
  printf "${BMAGENTA}${icon} ${text}${RESET}\n"
  printf "${DIM}${HORIZ}%.0s${RESET}" {1..70}
  echo ""
}

print_info() {
  local label="$1"
  local value="$2"
  printf "${CYAN}  ▸ ${RESET}${label}: ${BWHITE}${value}${RESET}\n"
}

print_success() {
  printf "${GREEN}  ✓ ${RESET}$1\n"
}

print_skip() {
  printf "${YELLOW}  ⊘ ${RESET}${DIM}$1${RESET}\n"
}

print_warning() {
  printf "${YELLOW}  ⚠ ${RESET}$1\n"
}

print_error() {
  printf "${RED}  ✗ ${RESET}$1\n"
}

print_freed() {
  local amount="$1"
  printf "${BGREEN}  ↓ Freed: ${amount}${RESET}\n"
}

spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    local temp=${spinstr#?}
    printf "${BCYAN}  %c${RESET}  " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

progress_bar() {
  local current=$1
  local total=$2
  local width=40
  local percentage=$((current * 100 / total))
  local filled=$((width * current / total))
  local empty=$((width - filled))
  
  printf "\r${CYAN}  ["
  printf "${BGREEN}${"━" * $filled}${RESET}"
  printf "${DIM}${"─" * $empty}${RESET}"
  printf "${CYAN}]${RESET} ${BWHITE}${percentage}%%${RESET}"
}

confirm() {
  local prompt="$1"
  local size="$2"
  printf "${BYELLOW}  ? ${RESET}${prompt}"
  if [ -n "$size" ]; then
    printf " ${BMAGENTA}(${size})${RESET}"
  fi
  printf " ${DIM}[y/N]${RESET} "
  if read -q; then echo; return 0; else echo; return 1; fi
}

delete_dir() {
  local p="$1"; local label="$2"
  if [ ! -e "$p" ]; then print_skip "$label not found"; return; fi
  
  local before_kb=$(path_size_kb "$p")
  local pretty=$(path_size_h "$p")
  
  print_info "$label" "$pretty"
  
  if [ "$DRY_RUN" = true ]; then
    printf "${DIM}  → Would remove: $p${RESET}\n"
    return
  fi
  
  rm -rf -- "$p" 2>/dev/null || print_warning "Could not fully remove (might be in use)"
  
  local after_kb=$(path_size_kb "$p")
  local freed_kb=$(( before_kb - after_kb ))
  (( freed_kb > 0 )) && TOTAL_FREED_KB=$(( TOTAL_FREED_KB + freed_kb ))
  print_freed "$(human_kb $freed_kb)"
}

delete_dir_contents() {
  local d="$1"; local label="$2"
  if [ ! -d "$d" ]; then print_skip "$label not found"; return; fi
  
  local before_kb=$(path_size_kb "$d")
  local pretty=$(path_size_h "$d")
  
  print_info "$label" "$pretty"
  
  if [ "$DRY_RUN" = true ]; then
    printf "${DIM}  → Would remove contents of: $d${RESET}\n"
    return
  fi
  
  find "$d" -mindepth 1 -maxdepth 1 -print0 2>/dev/null | xargs -0 rm -rf -- 2>/dev/null || print_warning "Some files could not be removed"
  
  local after_kb=$(path_size_kb "$d")
  local freed_kb=$(( before_kb - after_kb ))
  (( freed_kb > 0 )) && TOTAL_FREED_KB=$(( TOTAL_FREED_KB + freed_kb ))
  print_freed "$(human_kb $freed_kb)"
}

clean_yarn() {
  local label="Yarn cache"
  local yc=""
  if command -v yarn >/dev/null 2>&1; then yc="$(yarn cache dir 2>/dev/null | tail -n1)"; fi
  local fallbacks=("$HOME/Library/Caches/Yarn" "$HOME/.cache/yarn")
  local target=""
  if [ -n "$yc" ] && [ -e "$yc" ]; then target="$yc"; fi
  if [ -z "$target" ]; then
    for p in "${fallbacks[@]}"; do [ -e "$p" ] && { target="$p"; break; }; done
  fi
  if [ -z "$target" ]; then print_skip "Yarn cache not found"; return; fi
  
  local pretty=$(path_size_h "$target")
  if confirm "Clear $label?" "$pretty"; then
    if [ "$DRY_RUN" = true ]; then
      printf "${DIM}  → Would run 'yarn cache clean' and remove cache directories${RESET}\n"
    else
      printf "${CYAN}  ⟳${RESET} Cleaning Yarn cache...\n"
      if command -v yarn >/dev/null 2>&1; then
        yarn cache clean --all >/dev/null 2>&1 || yarn cache clean >/dev/null 2>&1 || true
      fi
      delete_dir "$target" "$label"
      for p in "${fallbacks[@]}"; do
        [ "$p" != "$target" ] && [ -e "$p" ] && delete_dir "$p" "$label (fallback)"
      done
    fi
  else
    print_skip "$label"
  fi
}

clean_deriveddata() {
  local d="$HOME/Library/Developer/Xcode/DerivedData"
  if [ ! -d "$d" ]; then print_skip "Xcode DerivedData not found"; return; fi
  
  local pretty=$(path_size_h "$d")
  if confirm "Delete Xcode DerivedData contents?" "$pretty"; then
    delete_dir_contents "$d" "Xcode DerivedData"
  else
    print_skip "Xcode DerivedData"
  fi
}

clean_coresimulator() {
  local cs="$HOME/Library/Developer/CoreSimulator"
  if [ ! -d "$cs" ]; then print_skip "CoreSimulator not found"; return; fi
  
  local pretty=$(path_size_h "$cs")
  if confirm "Prune iOS Simulator data?" "$pretty"; then
    if [ "$DRY_RUN" = true ]; then
      printf "${DIM}  → Would run simulator cleanup commands${RESET}\n"
    else
      printf "${CYAN}  ⟳${RESET} Shutting down simulators...\n"
      xcrun simctl shutdown all >/dev/null 2>&1 || true
      printf "${CYAN}  ⟳${RESET} Deleting unavailable devices...\n"
      xcrun simctl delete unavailable >/dev/null 2>&1 || true
      delete_dir "$cs/Caches" "CoreSimulator Caches"
      delete_dir "$cs/Logs" "CoreSimulator Logs"
    fi
  else
    print_skip "CoreSimulator"
  fi
}

clean_cocoapods() {
  local label="CocoaPods cache"
  local d="$HOME/Library/Caches/CocoaPods"
  local pretty=$(path_size_h "$d")
  
  if [ -d "$d" ] || command -v pod >/dev/null 2>&1; then
    if confirm "Clear $label?" "$pretty"; then
      if [ "$DRY_RUN" = true ]; then
        printf "${DIM}  → Would run 'pod cache clean --all' and remove cache${RESET}\n"
      else
        printf "${CYAN}  ⟳${RESET} Cleaning CocoaPods cache...\n"
        if command -v pod >/dev/null 2>&1; then pod cache clean --all >/dev/null 2>&1 || true; fi
        [ -d "$d" ] && delete_dir "$d" "$label"
      fi
    else
      print_skip "CocoaPods cache"
    fi
  else
    print_skip "CocoaPods not found"
  fi
}

clean_browser_cache() {
  local name="$1"; local p="$2"
  [ -e "$p" ] || { print_skip "$name cache not found"; return; }
  delete_dir "$p" "$name cache"
}

clean_brew() {
  if ! command -v brew >/dev/null 2>&1; then print_skip "Homebrew not installed"; return; fi
  
  local cache="$(brew --cache 2>/dev/null)"
  local before_kb=$(path_size_kb "$cache")
  local pretty=$(human_kb "$before_kb")
  
  if confirm "Run Homebrew cleanup?" "$pretty"; then
    if [ "$DRY_RUN" = true ]; then
      printf "${DIM}  → Would run 'brew cleanup -s' and 'brew autoremove'${RESET}\n"
    else
      printf "${CYAN}  ⟳${RESET} Running Homebrew cleanup...\n"
      brew cleanup -n || true
      brew cleanup -s || true
      brew autoremove -n || true
      brew autoremove || true
    fi
    local after_kb=$(path_size_kb "$cache")
    local freed_kb=$(( before_kb - after_kb ))
    (( freed_kb > 0 )) && TOTAL_FREED_KB=$(( TOTAL_FREED_KB + freed_kb ))
    print_freed "$(human_kb $freed_kb)"
  else
    print_skip "Homebrew cleanup"
  fi
}

main() {
  clear
  
  # ASCII Art Banner
  printf "${BRED}"
  cat << 'EOF'
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
EOF
  printf "${RESET}\n"
  
  # Banner
  print_header "🧹  MAC SYSTEM DATA CLEANUP"
  
  if [ "$DRY_RUN" = true ]; then
    printf "${BYELLOW}  ⚠  DRY RUN MODE - No files will be deleted${RESET}\n\n"
  fi
  
  printf "${YELLOW}  ⚠  ${RESET}${BOLD}Before proceeding, please close:${RESET}\n"
  printf "${DIM}     • Xcode, Simulator, iOS apps\n"
  printf "     • Arc, The Browser, Comet\n"
  printf "     • Terminals running yarn, pod, or brew${RESET}\n\n"
  
  print_info "Free space before" "$(human_kb $free_before_kb)"
  
  # HIGH PRIORITY
  print_section "🔥" "HIGH PRIORITY"
  clean_yarn
  clean_deriveddata
  clean_coresimulator
  clean_cocoapods

  # MEDIUM PRIORITY
  print_section "📦" "MEDIUM PRIORITY"
  clean_browser_cache "Arc" "$HOME/Library/Caches/Arc"
  clean_browser_cache "The Browser" "$HOME/Library/Caches/company.thebrowser.Browser"
  clean_browser_cache "Comet" "$HOME/Library/Caches/Comet"
  clean_brew
  
  if [ -d "$HOME/Library/Caches/node-gyp" ]; then
    delete_dir "$HOME/Library/Caches/node-gyp" "node-gyp cache"
  else
    print_skip "node-gyp cache not found"
  fi

  # OPTIONAL
  print_section "🔧" "OPTIONAL / LOWER PRIORITY"
  
  if [ -d "$HOME/Library/Caches/typescript" ]; then
    delete_dir "$HOME/Library/Caches/typescript" "TypeScript cache"
  else
    print_skip "TypeScript cache not found"
  fi
  
  if [ -d "$HOME/Library/Caches/Cypress" ]; then
    if confirm "Clear Cypress cache (removes downloaded versions)?" "$(path_size_h "$HOME/Library/Caches/Cypress")"; then
      delete_dir "$HOME/Library/Caches/Cypress" "Cypress cache"
    else
      print_skip "Cypress cache"
    fi
  else
    print_skip "Cypress cache not found"
  fi

  # Summary
  echo ""
  print_section "📊" "SUMMARY"
  
  local free_after_kb=$(df -k / | awk 'NR==2 {print $4}')
  local delta_kb=$(( free_after_kb - free_before_kb ))
  
  print_info "Total freed (calculated)" "$(human_kb $TOTAL_FREED_KB)"
  print_info "Free space after" "$(human_kb $free_after_kb)"
  print_info "Disk free delta" "$(human_kb $delta_kb)"
  
  echo ""
  printf "${DIM}  Note: APFS may defer reclaiming some purgeable space${RESET}\n"
  echo ""
  print_success "Cleanup complete! ✨"
  echo ""
}

main "$@"

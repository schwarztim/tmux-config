#!/bin/bash
# tmux status bar — system info (called every 5s)
# Cross-platform: macOS + Linux (including Asahi/Apple Silicon)

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

OS=$(uname -s)

# CPU — average across cores
if [[ "$OS" == "Darwin" ]]; then
  cores=$(sysctl -n hw.ncpu 2>/dev/null || echo 8)
  cpu=$(ps -A -o %cpu | awk -v c="$cores" '{s+=$1} END {printf "%.0f", s / c}')
else
  cpu=$(awk '/^cpu /{u=$2+$4; t=$2+$3+$4+$5+$6+$7+$8; printf "%.0f", (u/t)*100}' /proc/stat 2>/dev/null)
fi

# Memory
if [[ "$OS" == "Darwin" ]]; then
  mem_total=$(sysctl -n hw.memsize 2>/dev/null | awk '{printf "%.0f", $1/1073741824}')
  mem_used=$(memory_pressure 2>/dev/null | awk '/percentage/{gsub(/%/,"",$5); print $5; exit}')
  if [[ -n "$mem_used" ]]; then
    mem_gb=$(awk "BEGIN {printf \"%.0f\", $mem_total * $mem_used / 100}")
    mem="${mem_gb}/${mem_total}GB"
  else
    mem="${mem_total}GB"
  fi
else
  read -r mem_total mem_avail <<< "$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%.0f %.0f", t/1048576, a/1048576}' /proc/meminfo)"
  mem_used=$((mem_total - mem_avail))
  mem="${mem_used}/${mem_total}GB"
fi

# Network — bytes/sec
if [[ "$OS" == "Darwin" ]]; then
  net=$(nettop -P -L 1 -J bytes_in,bytes_out -t wifi -t wired 2>/dev/null | awk -F, '
    NR>1 && $2 != "" {din+=$2; dout+=$3}
    END {
      if (din > 1048576) printf "%.1fMB↓ ", din/1048576
      else if (din > 1024) printf "%.0fkB↓ ", din/1024
      else printf "0B↓ "
      if (dout > 1048576) printf "%.1fMB↑", dout/1048576
      else if (dout > 1024) printf "%.0fkB↑", dout/1024
      else printf "0B↑"
    }')
else
  read_net() { awk '/:/{gsub(/:/," "); rx+=$2; tx+=$10} END{print rx, tx}' /proc/net/dev; }
  read -r rx1 tx1 <<< "$(read_net)"
  sleep 1
  read -r rx2 tx2 <<< "$(read_net)"
  din=$((rx2 - rx1))
  dout=$((tx2 - tx1))
  fmt_bytes() {
    local b=$1
    if (( b > 1048576 )); then echo "$b" | awk '{printf "%.1fMB", $1/1048576}'
    elif (( b > 1024 )); then echo "$b" | awk '{printf "%.0fkB", $1/1024}'
    else printf "%dB" "$b"; fi
  }
  net="$(fmt_bytes $din)↓ $(fmt_bytes $dout)↑"
fi

# Battery / Power
if [[ "$OS" == "Darwin" ]]; then
  batt=$(pmset -g batt 2>/dev/null | grep -o '[0-9]*%' | head -1)
  charging=$(pmset -g batt 2>/dev/null | grep -c 'AC Power')
  if [[ "$charging" -gt 0 ]]; then
    power="⚡${batt}"
  else
    power="🔋${batt}"
  fi
else
  # Find battery: standard BAT* or Asahi macsmc-battery
  bat_path=$(find /sys/class/power_supply/ -maxdepth 1 \( -name 'BAT*' -o -name '*battery' \) 2>/dev/null | head -1)
  if [[ -n "$bat_path" ]]; then
    batt=$(cat "$bat_path/capacity" 2>/dev/null)
    status=$(cat "$bat_path/status" 2>/dev/null)
    if [[ "$status" == "Charging" || "$status" == "Full" ]]; then
      power="⚡${batt}%"
    else
      power="🔋${batt}%"
    fi
  else
    power="⚡AC"
  fi
fi

echo "CPU:${cpu}%  MEM:${mem}  NET:${net}  ${power}"

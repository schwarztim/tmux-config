#!/bin/bash
# tmux status bar — system info (called every 5s)
# Uses absolute paths because tmux #() runs with empty PATH

export PATH="/usr/bin:/bin:/usr/sbin:/sbin"

# CPU — average across cores
cpu=$(/bin/ps -A -o %cpu | /usr/bin/awk '{s+=$1} END {printf "%.0f", s / 8}')

# Memory — used/total
mem_used=$(/usr/bin/memory_pressure 2>/dev/null | /usr/bin/awk '/percentage/{gsub(/%/,"",$5); print $5; exit}')
mem_total=$(/usr/sbin/sysctl -n hw.memsize 2>/dev/null | /usr/bin/awk '{printf "%.0f", $1/1073741824}')
if [[ -n "$mem_used" ]]; then
  mem_gb=$(/usr/bin/awk "BEGIN {printf \"%.0f\", $mem_total * $mem_used / 100}")
  mem="${mem_gb}/${mem_total}GB"
else
  mem="${mem_total}GB"
fi

# Network — bytes/sec via nettop snapshot
net=$(/usr/bin/nettop -P -L 1 -J bytes_in,bytes_out -t wifi -t wired 2>/dev/null | /usr/bin/awk -F, '
  NR>1 && $2 != "" {din+=$2; dout+=$3}
  END {
    if (din > 1048576) printf "%.1fMB↓ ", din/1048576
    else if (din > 1024) printf "%.0fkB↓ ", din/1024
    else if (din > 0) printf "%.0fB↓ ", din
    else printf "0B↓ "
    if (dout > 1048576) printf "%.1fMB↑", dout/1048576
    else if (dout > 1024) printf "%.0fkB↑", dout/1024
    else if (dout > 0) printf "%.0fB↑", dout
    else printf "0B↑"
  }')

# Battery
batt=$(/usr/bin/pmset -g batt 2>/dev/null | /usr/bin/grep -o '[0-9]*%' | /usr/bin/head -1)
charging=$(/usr/bin/pmset -g batt 2>/dev/null | /usr/bin/grep -c 'AC Power')
if [[ "$charging" -gt 0 ]]; then
  batt_icon="AC:"
else
  batt_icon="DC:"
fi

echo "CPU:${cpu}%  MEM:${mem}  NET:${net}  ${batt_icon}${batt}"

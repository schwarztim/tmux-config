# tmux Configuration

Cross-platform (macOS + Linux) terminal multiplexer setup that inherits your terminal's color theme, with kitty integration, sesh session management, and a performance status bar.

## Recommended Terminal: kitty

This config is designed for [kitty](https://sw.kovidgoyal.net/kitty/). tmux pushes the session name to kitty's tab title via `set-titles-string '#S'`, so project-based sessions like `bambu/frontend` show directly in the kitty tab bar. Any terminal that respects OSC title sequences will work, but kitty is recommended for the best experience.

## What's Included

| File                     | Installs To                | Purpose                                        |
| ------------------------ | -------------------------- | ---------------------------------------------- |
| `tmux.conf`              | `~/.tmux.conf`             | Main tmux config                               |
| `.config/tmux/status.sh` | `~/.config/tmux/status.sh` | Status bar script (CPU, RAM, network, battery) |
| `.config/sesh/sesh.toml` | `~/.config/sesh/sesh.toml` | sesh session manager config                    |

## Platform Support

| Feature | macOS | Linux |
|---------|-------|-------|
| CPU usage | `ps -A -o %cpu` | `/proc/stat` |
| Memory | `memory_pressure` + `sysctl` | `/proc/meminfo` |
| Network throughput | `nettop` | `/proc/net/dev` (1s delta) |
| Battery | `pmset` | `/sys/class/power_supply/` (BAT*, macsmc-battery) |
| Keychain passthrough | `reattach-to-user-namespace` (auto-detected) | N/A |

### Linux Notes

Tested on Fedora Asahi Remix (Apple Silicon) and standard x86_64 Fedora. The battery detection handles both standard `BAT0`/`BAT1` paths and Asahi's `macsmc-battery`.

**Fedora/Asahi PATH issue**: If you see `command not found` errors for `grep`, `sed`, etc. when launching tmux sessions, create `~/.zshenv` to bootstrap PATH before profile.d scripts run:

```bash
echo 'export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin${PATH:+:$PATH}"' > ~/.zshenv
```

This is needed because Fedora's `/etc/zshenv` doesn't set PATH, so profile.d scripts (which need core utils) fail during shell init inside tmux.

**`reattach-to-user-namespace`**: This macOS-only utility is conditionally loaded via `if-shell` — it won't break on Linux.

## Dependencies

- [tmux](https://github.com/tmux/tmux) 3.x+
- [kitty](https://sw.kovidgoyal.net/kitty/) (recommended terminal)
- [sesh](https://github.com/joshmedeski/sesh) (session manager)
- [fzf](https://github.com/junegunn/fzf) (fuzzy finder)
- [fd](https://github.com/sharkdp/fd) (file finder, used in sesh binding)
- [TPM](https://github.com/tmux-plugins/tpm) (plugin manager)

## Plugins (auto-installed via TPM)

- `tmux-resurrect` — persist sessions across restarts
- `tmux-continuum` — auto-save every 10 minutes, auto-restore on start

## Install

### macOS

```bash
# Clone
git clone https://github.com/schwarztim/tmux-config.git ~/tmux-config && cd ~/tmux-config

# Symlink configs
ln -sf "$PWD/tmux.conf" ~/.tmux.conf
mkdir -p ~/.config/tmux ~/.config/sesh
ln -sf "$PWD/.config/tmux/status.sh" ~/.config/tmux/status.sh
ln -sf "$PWD/.config/sesh/sesh.toml" ~/.config/sesh/sesh.toml

# Install TPM + plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

chmod +x ~/.config/tmux/status.sh
```

### Linux (Fedora / Asahi)

```bash
# Clone
git clone https://github.com/schwarztim/tmux-config.git ~/tmux-config && cd ~/tmux-config

# Symlink configs
ln -sf "$PWD/tmux.conf" ~/.tmux.conf
mkdir -p ~/.config/tmux ~/.config/sesh
ln -sf "$PWD/.config/tmux/status.sh" ~/.config/tmux/status.sh
ln -sf "$PWD/.config/sesh/sesh.toml" ~/.config/sesh/sesh.toml

# Fix PATH for tmux shell init (Fedora-specific)
echo 'export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin${PATH:+:$PATH}"' > ~/.zshenv

# Install TPM + plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

chmod +x ~/.config/tmux/status.sh
```

Or if you use [claude-rules](https://github.com/schwarztim/claude-rules), onboarding deploys this automatically:

```bash
cd ~/claude-rules && bin/onboard.sh
```

## Features

- **Cross-platform**: macOS and Linux (including Asahi on Apple Silicon)
- **Theme-adaptive**: uses `default` colors — inherits whatever your terminal provides
- **Kitty integration**: session name pushed to tab title via `set-titles`
- **sesh + fzf**: `prefix + j` opens session picker with icons, zoxide, config views
- **Performance bar**: CPU%, memory used/total, network throughput, battery (⚡ charging / 🔋 on battery)
- **Auto-rename**: windows named after current directory
- **Mouse**: enabled
- **Base-1 indexing**: windows and panes start at 1

## Status Bar

The right side of the status bar shows system metrics updated every 5 seconds:

```
CPU:12%  MEM:6/16GB  NET:45kB↓ 12kB↑  🔋87%
```

| Indicator | Meaning |
|-----------|---------|
| `CPU:N%` | Average CPU usage across all cores |
| `MEM:used/totalGB` | Memory consumption |
| `NET:↓ ↑` | Network throughput (1-second sample on Linux, snapshot on macOS) |
| `⚡N%` | Plugged in / charging |
| `🔋N%` | On battery |
| `⚡AC` | Desktop / no battery detected |

## Session Naming Convention

Sessions are named `{project}/{label}` (e.g., `bambu/frontend`, `ms365-hub/api`). This integrates with the project-first tmux launcher in [claude-rules](https://github.com/schwarztim/claude-rules) and shows cleanly in kitty's tab bar.

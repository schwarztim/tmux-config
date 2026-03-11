# tmux Configuration — Matrix Theme

Terminal multiplexer setup with Matrix-inspired green-on-black theme, kitty integration, sesh session management, and a performance status bar.

## What's Included

| File                     | Installs To                | Purpose                                        |
| ------------------------ | -------------------------- | ---------------------------------------------- |
| `tmux.conf`              | `~/.tmux.conf`             | Main tmux config                               |
| `.config/tmux/status.sh` | `~/.config/tmux/status.sh` | Status bar script (CPU, RAM, network, battery) |
| `.config/sesh/sesh.toml` | `~/.config/sesh/sesh.toml` | sesh session manager config                    |

## Dependencies

- [tmux](https://github.com/tmux/tmux) 3.x+
- [kitty](https://sw.kovidgoyal.net/kitty/) (terminal — optional, any terminal works)
- [sesh](https://github.com/joshmedeski/sesh) (session manager)
- [fzf](https://github.com/junegunn/fzf) (fuzzy finder)
- [fd](https://github.com/sharkdp/fd) (file finder, used in sesh binding)
- [TPM](https://github.com/tmux-plugins/tpm) (plugin manager)

## Plugins (auto-installed via TPM)

- `tmux-resurrect` — persist sessions across restarts
- `tmux-continuum` — auto-save every 10 minutes, auto-restore on start

## Install

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

# Make status script executable
chmod +x ~/.config/tmux/status.sh
```

## Features

- **Matrix theme**: green (`#00ff41`) on black (`#0d0d0d`), minimal chrome
- **Kitty integration**: session name pushed to terminal title via `set-titles`
- **sesh + fzf**: `prefix + j` opens session picker with icons, zoxide, config views
- **Performance bar**: CPU%, memory used/total, network throughput, battery + AC/DC
- **Auto-rename**: windows named after current directory
- **Mouse**: enabled
- **Base-1 indexing**: windows and panes start at 1

# How to Use tmux for Backups (macOS → Cluster → TrueNAS)

## Why use tmux?
- tmux lets you run terminal sessions that stay alive even if you disconnect or log out.
- Perfect for long-running tasks like backups over SSH.

---

## Step-by-Step Guide

### 1. Install tmux (if not already installed)
```sh
brew install tmux
```

### 2. Connect to the Cluster via SSH
```sh
ssh username@cluster-address
```

### 3. Start a tmux Session
```sh
tmux new -s backup_session
```
- This creates a new tmux session named `backup_session`.

### 4. Run Your Backup Command
- Use `rsync` or `scp` to copy files from the cluster to your TrueNAS server.
- Example using `rsync`:
```sh
rsync -avz /path/to/source username@truenas-address:/path/to/destination
```
- Replace paths and usernames as needed.

### 5. Detach from tmux (Leave Backup Running)
- Press `Ctrl+b`, then release and press `d`.
- This detaches you from the tmux session, but your backup keeps running.

### 6. Log Out or Disconnect
- You can safely close your terminal or disconnect from SSH. The backup continues in tmux.

### 7. Reconnect to tmux Later
- SSH back into the cluster, then run:
```sh
tmux attach -t backup_session
```
- This reattaches to your running session.

### 8. End the tmux Session (When Done)
- Inside tmux, type `exit` or press `Ctrl+d` to close the session.

---

## Tips
- List all tmux sessions: `tmux ls`
- Kill a session: `tmux kill-session -t backup_session`
- For more: [tmux Cheat Sheet](https://tmuxcheatsheet.com/)

---

## tmux Quick Reference

| Action                        | Command / Shortcut                                 | Notes                                      |
|-------------------------------|----------------------------------------------------|---------------------------------------------|
| Start new session             | `tmux new -s session_name`                         | Create a named session                      |
| List sessions                 | `tmux ls`                                          |                                             |
| Attach to session             | `tmux attach -t session_name`                      | Reconnect to a session                      |
| Detach from session           | `Ctrl+b`, then `d`                                 | Leaves session running in background        |
| Rename session                | `Ctrl+b`, then `:$`                                | Type new name and press Enter               |
| Kill (delete) session         | `tmux kill-session -t session_name`                | Ends the session                            |
| Kill all sessions             | `tmux kill-server`                                 | Ends all tmux sessions                      |
| New window                    | `Ctrl+b`, then `c`                                 | Opens a new window in session               |
| Next window                   | `Ctrl+b`, then `n`                                 | Switch to next window                       |
| Previous window               | `Ctrl+b`, then `p`                                 | Switch to previous window                   |
| Split pane horizontally       | `Ctrl+b`, then `"`                                 | Splits current pane left/right              |
| Split pane vertically         | `Ctrl+b`, then `%`                                 | Splits current pane top/bottom              |
| Switch pane                   | `Ctrl+b`, then arrow key                           | Move between panes                          |
| Close pane/window             | `exit`                                             | Type in the pane or window                  |
| Show shortcuts                | `Ctrl+b`, then `?`                                 | Shows tmux help                             |
| Scroll in history             | `Ctrl+b`, then `[`                                 | Use arrow keys, `q` to quit                 |

---

## Example .tmux.conf Explained
```
# ---------------------------------------
# Basic .tmux.conf
# Author: Martin Balcewicz
# Date: June 2025
# ---------------------------------------

# Set prefix to Ctrl+a
unbind C-b                # Unbind default prefix (Ctrl+b)
set-option -g prefix C-a  # Set prefix to Ctrl+a
bind-key C-a send-prefix  # Allow sending prefix to nested tmux

# Enable mouse mode
set -g mouse on           # Enable mouse for pane/window selection and resizing

# Split panes using | and -
bind | split-window -h    # Split pane horizontally with |
bind - split-window -v    # Split pane vertically with -
unbind '"'                # Unbind default horizontal split shortcut
unbind %                  # Unbind default vertical split shortcut

# Switch panes using Alt-arrow without prefix
bind -n M-Left select-pane -L   # Move to left pane with Alt+Left
bind -n M-Right select-pane -R  # Move to right pane with Alt+Right
bind -n M-Up select-pane -U     # Move to upper pane with Alt+Up
bind -n M-Down select-pane -D   # Move to lower pane with Alt+Down

# Reload config file
bind r source-file ~/.tmux.conf \; display "Reloaded!"  # Reload config with prefix+r

# Don't rename windows automatically
set-option -g allow-rename off   # Prevent tmux from auto-renaming windows

# Improve colors
set -g default-terminal "screen-256color"  # Enable 256-color support

# Status bar customization
set -g status-bg black           # Status bar background color
set -g status-fg white           # Status bar text color
set -g status-left '#[fg=green](#S) '   # Session name in green on left
set -g status-right '#[fg=yellow]%Y-%m-%d %H:%M '  # Date/time in yellow on right
set -g status-justify centre     # Center window list in status bar
setw -g window-status-current-style fg=black,bg=green  # Active window: black text, green background
```

---

## Example Workflow
1. `ssh username@cluster-address`
2. `tmux new -s backup_session`
3. `rsync -avz /data user@truenas:/backup/data`
4. Detach: `Ctrl+b`, then `d`
5. Log out or disconnect
6. Later: SSH in, `tmux attach -t backup_session`

---

**tmux is highly recommended for this use case!**

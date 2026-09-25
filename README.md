# Machines

- `icelake` - my laptop with icelake arch

## Nix installing on non-NixOS systems
Install nix via a script or your system's package manager and sometimes you will optionally need to:
```sh
sudo usermod -aG nix-users $(whoami) # nix-users group must be
sudo systemctl start nix-daemon
sudo systemctl enable --now nix-daemon.socket nix-daemon.service
```

### First system-build with home-manager
```sh
git clone https://github.com/Ortm/flake-rei.git ~/flake-rei
cd ~/flake-rei
./install.sh --machine <machine name> # or ./install.sh and pick interactively
# flags: --no-niri to skip niri linking, FLAKE_MACHINE=<name> env also works
```

## Setup niri config:

- icelake

```sh
export FLAKE_MACHINE=<machine name>
~/flake-rei/scripts/setup_niri.sh
```

If `~/.config/niri` already exists, the script moves it to a timestamped backup
(`~/.config/niri.bak.YYYYMMDD-HHMMSS`) before linking the new config.

# Keybinds

`Mod` = `Super`. Source of truth: `dotfiles/niri/generic/binds.kdl` +
`dotfiles/niri/icelake/binds.kdl` (icelake wins on conflict).
Keyboard layouts `us,ru`, toggle with `CapsLock`.

## Launch / system

| Keys | Description |
| ---- | ----------- |
| `Mod + Return` | Open terminal (foot) |
| `Mod + Space` | App launcher (noctalia) |
| `Mod + X` | OCR selected area into clipboard |
| `Mod + P` | Session panel (noctalia) |
| `Mod + Shift + P` | Lock screen |
| `Mod + I` | Control center (noctalia) |
| `Mod + Shift + I` | Power off monitors |
| `Mod + Tab` | Toggle overview |

## Windows

| Keys | Description |
| ---- | ----------- |
| `Mod + Q` | Close focused window |
| `Mod + C` | Toggle tabbed column display |
| `Mod + Comma / Period` | Consume / expel window (in/out of column) |
| `Mod + S` | Screenshot screen |
| `Mod + Shift + S` | Screenshot window (clipboard only) |
| `Mod + Ctrl + S` | Screenshot window (save to disk) |
| `Mod + V` | Clipboard history (wofi) |
| `Mod + Ctrl + V` | Wipe clipboard history |

## Focus / move / resize

Arrows or vim-style (`H` left, `J` down, `K` up, `L` right).

| Keys | Description |
| ---- | ----------- |
| `Mod + Arrows` / `Mod + H / J / K / L` | Focus window / column |
| `Mod + Wheel` | Switch workspace (up/down), focus column (left/right) |
| `Mod + Shift + Arrows` / `Mod + Shift + K / J / H / L` | Move window / column |
| `Mod + Ctrl + Arrows` / `Mod + Ctrl + K / J / H / L` | Resize window / column (±5%) |
| `Mod + Home / End` | Focus first / last column |
| `Mod + Shift + Home / End` | Move column to first / last |

## Column width presets (icelake)

| Keys | Description |
| ---- | ----------- |
| `Mod + F` | Column width 100% |
| `Mod + G` | Column width 90% |

## Workspaces

| Keys | Description |
| ---- | ----------- |
| `Mod + 1–9` | Focus workspace 1–9 |
| `Mod + Shift + 1–9` | Move column to workspace (with focus) |
| `Mod + Ctrl + 1–9` | Send column to workspace (keep focus) |
| `Mod + F1–F9` | Focus column N |

## Volume / media / brightness (work when locked)

| Keys | Description |
| ---- | ----------- |
| `Mod + Equal / Minus` | Volume up / down |
| `Mod + 0` | Mute toggle |
| `Mod + Shift + Equal / Minus` | Next / previous track |
| `Mod + Backspace` | Play / pause |
| `XF86Audio* / XF86MonBrightness*` | Volume, mic, media, brightness (via noctalia) |

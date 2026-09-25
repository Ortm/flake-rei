# flake-rei

Home Manager flake for my Niri + Catppuccin machines: packages, CLI/TUI tool
config, theming and the niri compositor config (`dotfiles/niri`, symlinked into
`~/.config/niri`).

## Requirements

| | |
| --- | --- |
| Architecture | `x86_64-linux` / `aarch64-linux`: `install.sh` detects the system it runs on and passes it to the flake as `FLAKE_SYSTEM` (override with `FLAKE_SYSTEM=aarch64-linux ./install.sh`). Falls back to `x86_64-linux` when nothing is set. |
| Nix | with flakes enabled — install with the [Determinate installer](https://install.determinate.systems/nix) or your distro's package |
| Desktop stack | tier 1 (`wofi`, `cliphist`, `wl-clipboard`, `playerctl`, `grim`, `slurp`, `imagemagick`, `brightnessctl`, `swaylock`, `noctalia`) comes from the flake — see [Desktop stack](#desktop-stack-tier-1); the compositor session, portals and the polkit daemon stay with your distro. The OCR bind (`Mod+X`) also needs `easyocr` on `PATH`. |

## Install

```sh
git clone https://github.com/Ortm/flake-rei.git ~/flake-rei   # any path works
cd ~/flake-rei
./install.sh                # pick a machine interactively
./install.sh icelake        # or pass it directly
```

Flags: `--machine <name>`, `--no-niri` (skip niri config linking), `--yes`.
`FLAKE_MACHINE=<name> ./install.sh` works too. The build system is detected
(`FLAKE_SYSTEM=<system>` to override) and identity comes from the environment,
which is why everything that switches passes `--impure`.

`install.sh` also handles the non-NixOS papercuts: it starts `nix-daemon` if it
is down, adds you to `nix-users` if that group exists, and registers a freshly
added machine directory with git (`git add -N`) because nix flakes only see
git-tracked files.

### Which user gets installed

The installing user is detected automatically. `hm-modules/user.nix` fills
`home.username` and `home.homeDirectory` from the environment of whoever runs
the switch, which is why `install.sh` and `just hm` pass `--impure`; a fresh
clone therefore installs for your own account with no config edit.

To install for a different account (or to pin the values anyway), set them in
the machine module:

```nix
# machines/<machine>/default.nix
{
  rei.user = {
    username = "alice";
    homeDirectory = "/home/alice";
    name = "Alice";              # git/jujutsu commit name
    fullName = "Alice Liddell";  # pandoc author (defaults to `name`)
    email = "alice@example.com"; # git/jujutsu commit email
  };
}
```

`name` defaults to your capitalized login name, `email` to nothing — with no
email the flake leaves `user.email` alone, so git keeps whatever you configure.

### Adding your own machine

Machine configurations are discovered from the filesystem: every
`machines/<name>/default.nix` becomes a `.#<name>` homeConfiguration, so no
flake edit is needed.

```sh
mkdir -p machines/mylaptop
cp machines/icelake/default.nix machines/mylaptop/default.nix   # then edit it
$EDITOR machines/mylaptop/default.nix                           # FLAKE_MACHINE + rei.user
./install.sh mylaptop
```

A machine directory holds everything host specific: `FLAKE_MACHINE`, your
identity, and — under `dotfiles/niri/<machine>/` — outputs, layout presets,
autostart and the polkit agent path your distro ships.

## Desktop stack (tier 1)

`hm-modules/desktop-stack.nix` installs the user-space helpers the niri config
spawns — `wofi`, `cliphist`, `wl-clipboard`, `playerctl`, `grim`, `slurp`,
`imagemagick`, `brightnessctl`, `swaylock-effects` and the `noctalia` shell —
straight from nixpkgs, so a fresh install does not depend on distro/AUR
packages. It is on by default; a machine whose distro already provides them sets
`rei.desktopStack.enable = false;` (icelake does, so the flake's copies do not
shadow its AUR ones in the session `PATH`). Related knobs:
`rei.desktopStack.includeShell = false` skips `noctalia` (nixpkgs currently
ships it as a beta, and the legacy `noctalia-shell` v4 package is a different
program with a different binary name), and
`rei.desktopStack.extraPackages = [ pkgs.fuzzel ];` adds more.

`easyocr` (used by the `Mod+X` OCR bind) is deliberately *not* part of tier 1 —
it drags in torch, ~1 GB. Install it from your distro, or
`rei.desktopStack.extraPackages = [ pkgs.easyocr ];`.

What stays host-side on purpose: the compositor session itself (greeter, seat,
GPU/driver handling, the `wayland-sessions` entry), `xdg-desktop-portal*` (two
portal stacks on one D-Bus session fight over the same names, which breaks
screenshots and file pickers) and PAM-backed tools like `swaylock`, whose
unlock needs the host's `/etc/pam.d/swaylock`.

## Any Linux distro

Nothing here assumes NixOS. The flake installs user-space packages and files
that behave the same on any distro, and `targets.genericLinux` (in `home.nix`)
wires up the driver / GL paths a store binary needs on a foreign distro — set it
to `false` on NixOS.

What your distro still has to provide is the host side of the desktop: the
compositor session (greeter, seat, drivers, the `wayland-sessions` entry),
`xdg-desktop-portal*`, the polkit agent, and PAM files such as
`/etc/pam.d/swaylock` — see [Desktop stack](#desktop-stack-tier-1) for why.

The module list in `flake.nix` is grouped by area (core, CLI tools, Wayland,
theming) and is distro-neutral apart from `targets.genericLinux`: nothing in it
needs host integration or a NixOS-only feature. The niri config is linked out of
this checkout by `scripts/setup_niri.sh` and only spawns home-manager-owned paths
(`~/.config/rei/...`, `~/.local/bin/rei-ocr`), so the clone can live anywhere.

## Nix on non-NixOS systems

Install nix via a script or your system's package manager and sometimes you will
optionally need to:

```sh
sudo usermod -aG nix-users $(whoami) # nix-users group must be
sudo systemctl start nix-daemon
sudo systemctl enable --now nix-daemon.socket nix-daemon.service
```

### Manual first switch

`./install.sh` already does this; the manual equivalent is:

```sh
export FLAKE_MACHINE=<machine name>
nix run home-manager/master -- switch --flake ~/flake-rei#$FLAKE_MACHINE -b backup --impure
```

Later rebuilds: `just hm` (same command), or `scripts/flake_rebuild.sh`
(formats, git-backups, then switches, and can be run from any checkout path).

## Machines

- `icelake` — my laptop with icelake arch

## Setup niri config

`install.sh` links it automatically when the machine has niri dotfiles; to do it
by hand:

```sh
export FLAKE_MACHINE=<machine name>
~/flake-rei/scripts/setup_niri.sh
```

If `~/.config/niri` already exists, the script moves it to a timestamped backup
(`~/.config/niri.bak.YYYYMMDD-HHMMSS`) before linking the new config. The binds
reference their helper files through `~/.config/rei/...` and `~/.local/bin/...`,
which home-manager owns (`hm-modules/wayland/niri-assets.nix`), so the checkout
can live anywhere.

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

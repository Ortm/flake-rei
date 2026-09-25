# flake-rei

Home Manager flake for my Niri + Catppuccin machines: packages, CLI/TUI tool
config, theming and the niri compositor config (`dotfiles/niri`, symlinked into
`~/.config/niri`).

## Requirements

| | |
| --- | --- |
| Architecture | `x86_64-linux` / `aarch64-linux`: `install.sh` detects the system it runs on and passes it to the flake as `FLAKE_SYSTEM` (override with `FLAKE_SYSTEM=aarch64-linux ./install.sh`). Falls back to `x86_64-linux` when nothing is set. |
| Nix | with flakes enabled — install with the [Determinate installer](https://install.determinate.systems/nix) or your distro's package |
| Desktop stack | tier 1 (`wofi`, `cliphist`, `wl-clipboard`, `playerctl`, `grim`, `slurp`, `imagemagick`, `brightnessctl`, `noctalia`, `easyocr`) comes from the flake and, with `rei.desktopSession.enable` (tier 2), so do niri itself, the D-Bus portals, a polkit agent, the keyring and the session apps — see [Desktop stack](#desktop-stack-tier-1) and [Tier 2](#tier-2--the-session-itself). Left to the distro: drivers, logind/udev, PAM and the display manager. |

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

By hand, from this directory:

```sh
FLAKE_MACHINE=<machine> ./scripts/flake_rebuild.sh          # format, backup, switch
# or the raw command:
nix run home-manager/master -- switch --flake .#<machine> -b backup --impure
```

Later rebuilds: `just hm`, or `./scripts/flake_rebuild.sh` (it can be run from
any checkout path).

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
`imagemagick`, `brightnessctl` and the `noctalia` shell — straight from nixpkgs,
so a fresh install does not depend on distro/AUR packages. It is on by default;
a machine whose distro already provides them sets
`rei.desktopStack.enable = false;` (icelake does, so the flake's copies do not
shadow its AUR ones in the session `PATH`). Related knobs:
`rei.desktopStack.includeShell = false` skips `noctalia` (nixpkgs currently
ships it as a beta, and the legacy `noctalia-shell` v4 package is a different
program with a different binary name), and
`rei.desktopStack.extraPackages = [ pkgs.fuzzel ];` adds more.

`easyocr`, which the `Mod+X` OCR bind runs after grabbing the region with
grim/slurp, is part of tier 1 as well — via `rei.desktopStack.includeOcr`
(default `true`). It is the heaviest piece of the module (torch, ~1.5 GB of
closure) and fetches its models into `~/.EasyOCR` the first time the bind runs;
turn the option off if you never use it.

What stays host-side on purpose, even with tier 2 on: the display manager /
greeter, GPU driver handling, logind/seat and udev rules, the system polkit
daemon, PAM files such as `/etc/pam.d/swaylock`, and PipeWire/WirePlumber behind
the `wpctl` volume binds.

## Tier 2 — the session itself

`hm-modules/desktop-session.nix` (`rei.desktopSession.*`) installs the session
itself, so a freshly installed distro needs almost nothing preinstalled. It is
off by default; a machine turns it on with `rei.desktopSession.enable = true;`.

| Option | Default | What it installs |
| --- | --- | --- |
| `compositor` | `true` | niri through home-manager's module: `niri`, `niri-session` (start it from a TTY), its systemd user units, `xwayland-satellite` for X11 apps, niri's own D-Bus portal configuration, and a `wayland-sessions/niri.desktop` entry under `~/.local/share` |
| `polkitAgent` | `true` | polkit-gnome plus a systemd user service that starts its agent with the session, so privilege prompts work without a desktop-specific agent |
| `keyring` | `true` | GNOME Keyring (+ libsecret); unlocking it at login needs a PAM hook, so without one it asks for the password |
| `sessionApps` | `true` | `telegram-desktop` and `discord` — the apps `dotfiles/niri/generic/autostart.kdl` spawns |
| `userDirs` | `true` | XDG user directories, including `~/Pictures/Screenshots` for niri's `screenshot-path` |
| `extraPackages` | `[ ]` | anything else this session needs |

Logging in: `niri-session` is on `PATH` now, so a TTY login works; the generated
`~/.local/share/wayland-sessions/niri.desktop` is picked up by display managers
that scan user data directories, most only look at `/usr/share/wayland-sessions`.

## Any Linux distro

Nothing here assumes NixOS. The flake installs user-space packages and files
that behave the same on any distro, and `targets.genericLinux` (in `home.nix`)
wires up the driver / GL paths a store binary needs on a foreign distro — set it
to `false` on NixOS.

What your distro still has to provide is the host side of the session: GPU
drivers (`mesa`/`vulkan` and `/run/opengl-driver`), logind/seat and udev rules,
the display manager, the system polkit daemon, PAM files such as
`/etc/pam.d/swaylock`, and PipeWire/WirePlumber for the volume binds. Everything
else comes from the flake — the helpers in [Desktop stack](#desktop-stack-tier-1)
always, and with [Tier 2](#tier-2--the-session-itself) the compositor, portals,
polkit agent, keyring and session apps as well.

The module list in `flake.nix` is grouped by area (core, CLI tools, Wayland,
theming) and is distro-neutral apart from `targets.genericLinux`: nothing in it
needs host integration or a NixOS-only feature. The niri config is linked out of
this checkout by `scripts/setup_niri.sh` and only spawns home-manager-owned paths
(`~/.config/rei/...`, `~/.local/bin/rei-ocr`), so the clone can live anywhere.

## Setup niri config

`install.sh` links it automatically when the machine has niri dotfiles
(`--no-niri` skips it); by hand, from the checkout:

```sh
FLAKE_MACHINE=<machine> ./scripts/setup_niri.sh
```

If `~/.config/niri` already exists, the script moves it to a timestamped backup
(`~/.config/niri.bak.YYYYMMDD-HHMMSS`) before linking `config_<machine>.kdl`,
`generic/` and `<machine>/` into it. Everything the config spawns is resolved
through home-manager-owned paths (`~/.config/rei/...`, `~/.local/bin/rei-ocr`),
so the checkout can live anywhere.

## Keybinds

`Mod` = `Super`. Source of truth: `dotfiles/niri/generic/binds.kdl` +
`dotfiles/niri/icelake/binds.kdl` (icelake wins on conflict) — the same list
`niri msg binds` prints. The `us,ru` layout with `CapsLock` toggling it is
icelake's (`dotfiles/niri/icelake/input.kdl`).

### Launch / system

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

### Windows

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

### Focus / move / resize

Arrows or vim-style (`H` left, `J` down, `K` up, `L` right).

| Keys | Description |
| ---- | ----------- |
| `Mod + Arrows` / `Mod + H / J / K / L` | Focus window / column |
| `Mod + Wheel` | Switch workspace (up/down), focus column (left/right) |
| `Mod + Shift + Arrows` / `Mod + Shift + K / J / H / L` | Move window / column |
| `Mod + Ctrl + Arrows` / `Mod + Ctrl + K / J / H / L` | Resize window / column (±5%) |
| `Mod + Home / End` | Focus first / last column |
| `Mod + Shift + Home / End` | Move column to first / last |

### Fullscreen / column width

| Keys | Description |
| ---- | ----------- |
| `Mod + F` | Fullscreen (generic binds); icelake overrides it to column width 100% |
| `Mod + G` | Column width 90% (icelake) |

### Workspaces

| Keys | Description |
| ---- | ----------- |
| `Mod + 1–9` | Focus workspace 1–9 |
| `Mod + Shift + 1–9` | Move column to workspace (with focus) |
| `Mod + Ctrl + 1–9` | Send column to workspace (keep focus) |
| `Mod + F1–F9` | Focus column N |

### Volume / media / brightness (work when locked)

| Keys | Description |
| ---- | ----------- |
| `Mod + Equal / Minus` | Volume up / down |
| `Mod + 0` | Mute toggle |
| `Mod + Shift + Equal / Minus` | Next / previous track |
| `Mod + Backspace` | Play / pause |
| `XF86Audio* / XF86MonBrightness*` | Volume, mic, media, brightness (via noctalia) |

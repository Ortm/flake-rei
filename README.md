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

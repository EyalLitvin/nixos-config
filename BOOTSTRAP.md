# New Machine Bootstrap Guide

Full bring-up sequence from bare metal to a running dotfiles config — done entirely from the NixOS ISO, no intermediate install needed.

**What you need:**
- A NixOS minimal ISO on a USB stick (nixos.org/download)
- The target machine
- Network access (ethernet recommended)
- Your SOPS age private key

---

## Phase 1 — Boot and partition the disk

Boot from the USB stick. You'll land at a shell as root.

### 1.1 Identify your disk

```bash
lsblk
```

Find your target disk — typically `/dev/sda` (SATA/USB) or `/dev/nvme0n1` (NVMe). Set it:

```bash
DISK=/dev/nvme0n1   # change to your actual disk
```

### 1.2 Wipe and partition

**This destroys all data on the disk.**

```bash
parted $DISK -- mklabel gpt
parted $DISK -- mkpart ESP fat32 1MB 512MB
parted $DISK -- set 1 esp on
parted $DISK -- mkpart primary 512MB 100%
```

Verify with `parted $DISK -- print` before continuing.

> **NVMe:** partitions are `nvme0n1p1`, `nvme0n1p2`  
> **SATA/USB:** partitions are `sda1`, `sda2`

### 1.3 Format and mount

```bash
mkfs.fat -F 32 -n boot ${DISK}p1
mkfs.ext4 -L nixos ${DISK}p2

mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
```

---

## Phase 2 — Set up the dotfiles on the ISO

The ISO has `nix` available, so you can get any package on the fly with `nix-shell -p`.

### 2.1 Get git

```bash
nix-shell -p git
```

This drops you into a shell with git available. All subsequent commands run inside it.

### 2.2 Clone the dotfiles

```bash
git clone https://github.com/EyalLitvin/.dotfiles.git /tmp/.dotfiles
cd /tmp/.dotfiles
```

### 2.3 Generate and save the hardware configuration

```bash
HOSTNAME=<newmachine>   # e.g. "slate", "desk", "tower"

mkdir -p hosts/$HOSTNAME
nixos-generate-config --root /mnt --show-hardware-config \
  > hosts/$HOSTNAME/hardware-configuration.nix
```

### 2.4 Create the host configuration files

**`hosts/$HOSTNAME/configuration.nix`** — set the hostname and any hardware-specific options:

```nix
{ ... }: {
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "<newmachine>";

  # Enable hardware modules this machine needs:
  # systemSettings.hardware.nvidia.enable = true;
  # systemSettings.hardware.audio.enable  = true;
}
```

**`hosts/$HOSTNAME/home.nix`** — usually empty to start:

```nix
{ ... }: {
  # All home modules are active by default.
  # Add per-machine userSettings overrides here if needed.
}
```

### 2.5 Stage the new host files so nix can see them

Nix flakes only evaluate files that are tracked by git. You don't need to commit — staging is enough:

```bash
git add hosts/$HOSTNAME
```

---

## Phase 3 — Install directly from the flake

```bash
nixos-install --flake /tmp/.dotfiles#$HOSTNAME
```

This builds and installs the full dotfiles config onto `/mnt`. No temporary `configuration.nix`, no intermediate state.

When it finishes, **don't reboot yet**.

---

## Phase 4 — Place the SOPS age key before first boot

The age private key must exist before home-manager runs, otherwise it can't decrypt the SSH key.

```bash
mkdir -p /mnt/home/eyal/.config/sops/age
# paste or copy your age private key:
nano /mnt/home/eyal/.config/sops/age/keys.txt
chmod 600 /mnt/home/eyal/.config/sops/age/keys.txt
```

The file should contain a single line: `AGE-SECRET-KEY-1...`

---

## Phase 5 — Reboot and activate home-manager

```bash
reboot
```

Remove the USB stick. Log in as `eyal` using the password set in `system/security/users/default.nix`.

Run home-manager to set up the full user environment:

```bash
cd ~/.dotfiles
home-manager switch --flake .#eyal@$HOSTNAME
```

After this, the SSH key is deployed from SOPS. Switch the git remote to SSH and push the new host:

```bash
git remote set-url origin git@github.com:EyalLitvin/.dotfiles.git
git commit -m "add $HOSTNAME host"
git push
```

---

## Post-install checklist

- [ ] Verify WiFi works (if applicable): `nmcli device wifi list`
- [ ] Verify SSH key deployed: `ls -la ~/.ssh/id_ed25519`
- [ ] Push the new host commit
- [ ] Add the new host to `PROGRESS.md`

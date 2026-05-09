# mkOption Migration Plan

Converting hardcoded modules to the `mkOption` / `mkEnableOption` pattern so that
host files (`hosts/<name>/configuration.nix` and `hosts/<name>/home.nix`) become the
single control centre for what is active on each machine.

---

## Decisions made before writing this plan

| Question | Decision |
|---|---|
| Desktop modules — single flag or individual flags? | Single `userSettings.desktop.enable` |
| NetworkManager / firewall — opt-in? | No — always-on, stay hardcoded |
| Python — opt-in? | No — always-on, stay hardcoded |
| Nixvim editor — opt-in? | No — always-on, stay hardcoded |

---

## System-level changes (`system/`)

### 1. `system/boot/kernel/default.nix`
The RTL88x2bu driver is hardware-specific to onyx. A second machine without that
WiFi adapter must not load it.

- **New option:** `options.systemSettings.hardware.wifi.rtl88x2bu.enable = lib.mkEnableOption "RTL88x2bu USB WiFi driver"`
- Wrap the existing `boot.extraModulePackages` line in `lib.mkIf`.
- **Host update:** `hosts/onyx/configuration.nix` → `systemSettings.hardware.wifi.rtl88x2bu.enable = true`

---

### 2. `system/display/hyprland/default.nix`
System-level Hyprland enable is meaningless on a headless server.

- **New option:** `options.systemSettings.display.hyprland.enable = lib.mkEnableOption "Hyprland window manager"`
- Wrap `programs.hyprland.enable = true` in `lib.mkIf`.
- **Host update:** `hosts/onyx/configuration.nix` → `systemSettings.display.hyprland.enable = true`

---

### 3. `system/display/greeter/default.nix`
The greetd/tuigreet greeter is part of the desktop stack; useless on a server.

- **New option:** `options.systemSettings.display.greeter.enable = lib.mkEnableOption "greetd/tuigreet login greeter"`
- Wrap all greeter config in `lib.mkIf`.
- **Host update:** `hosts/onyx/configuration.nix` → `systemSettings.display.greeter.enable = true`

---

### 4. `system/networking/ssh/default.nix`
An SSH *server* is opt-in — you don't always want sshd listening.

- **New option:** `options.systemSettings.networking.ssh.enable = lib.mkEnableOption "OpenSSH server"`
- Wrap `services.openssh.enable` and the known-host entry in `lib.mkIf`.
- **Host update:** `hosts/onyx/configuration.nix` → `systemSettings.networking.ssh.enable = true`

---

### 5. `system/locale/default.nix`
Timezone and locale are machine-specific facts, not universal constants.
Use `mkOption` (not `mkEnableOption`) because these are configurable strings, not
on/off switches.

- **New options:**
  ```nix
  options.systemSettings.locale.timezone = lib.mkOption {
    type    = lib.types.str;
    default = "UTC";
  };
  options.systemSettings.locale.locale = lib.mkOption {
    type    = lib.types.str;
    default = "en_US.UTF-8";
  };
  ```
- Replace the hardcoded `"Asia/Jerusalem"` / `"en_US.UTF-8"` strings with
  `config.systemSettings.locale.timezone` / `config.systemSettings.locale.locale`.
- **Host update:** `hosts/onyx/configuration.nix` → `systemSettings.locale.timezone = "Asia/Jerusalem"`
  (locale stays at the default so no entry needed).

---

## Home-level changes (`home/`)

### 6. `home/dev/repos/default.nix`
Auto-cloning four specific repos on activation is onyx-specific. A second machine
(or a fresh setup that manages repos differently) must not run this.

- **New option:** `options.userSettings.dev.repos.enable = lib.mkEnableOption "auto-clone personal repos on activation"`
- Wrap the activation script in `lib.mkIf`.
- **Host update:** `hosts/onyx/home.nix` → `userSettings.dev.repos.enable = true`

---

### 7. `userSettings.desktop.enable` — single flag for all desktop tools

Declare the option once in `home/desktop/default.nix` (the desktop collector).
Each of the eight desktop-related modules wraps its entire `config` block in
`lib.mkIf config.userSettings.desktop.enable { ... }`.

**Option declaration (in `home/desktop/default.nix`):**
```nix
options.userSettings.desktop.enable = lib.mkEnableOption "desktop environment (Hyprland, Waybar, apps, theming, …)";
```

**Modules to wrap:**

| File | What it gates |
|---|---|
| `home/desktop/hyprland/default.nix` | Hyprland user config, keybindings, workspace rules |
| `home/desktop/waybar/default.nix` | Waybar status bar |
| `home/desktop/notifications/default.nix` | mako + libnotify |
| `home/desktop/clipboard/default.nix` | cliphist, wl-clipboard, fuzzel |
| `home/desktop/screenshot/default.nix` | grimblast |
| `home/browser/default.nix` | qutebrowser |
| `home/apps/default.nix` | firefox, claude-code, zapzap |
| `home/theming/default.nix` | stylix, wallpaper tooling |

- **Host update:** `hosts/onyx/home.nix` → `userSettings.desktop.enable = true`

---

## Summary of host file changes

After all migrations, `hosts/onyx/configuration.nix` will gain:
```nix
systemSettings.hardware.wifi.rtl88x2bu.enable = true;
systemSettings.display.hyprland.enable        = true;
systemSettings.display.greeter.enable         = true;
systemSettings.networking.ssh.enable          = true;
systemSettings.locale.timezone                = "Asia/Jerusalem";
```

And `hosts/onyx/home.nix` will gain:
```nix
userSettings.desktop.enable  = true;
userSettings.dev.repos.enable = true;
```

---

## What stays hardcoded (and why)

| Module | Reason |
|---|---|
| `system/networking/networkmanager` | All planned machines use NetworkManager |
| `system/networking/firewall` | Security baseline — always on |
| `system/nix/settings` | Flake settings are universal across all machines |
| `system/security/users` | User accounts are fundamental; host-specific password is already handled via hashing |
| `home/shell/zsh` + `starship` | Shell is universal |
| `home/terminal/kitty` | Terminal is universal |
| `home/cli/*` | Lightweight, universal CLI tools |
| `home/editor/nixvim` | Always wanted on every machine |
| `home/dev/git` + `direnv` | Universal dev baseline |
| `home/dev/languages` (Python) | Universal for all machines |
| `home/media/imv` | Lightweight, no reason to gate |
| `home/secrets` | sops config is tied to the user identity, always needed |

---
name: nixos-system-changes
description: Use whenever a task touches this machine's OS or user environment. Triggers - installing, removing or upgrading any app, package, CLI tool, font, driver or language toolchain (including npm -g, pip install, cargo install, go install, curl | sh); enabling or configuring a service or daemon; changing a system, desktop, keyboard, display, audio or shell setting; editing anything under /etc or ~/.config; needing a tool that is not on PATH; or setting up a project dev environment. This machine is NixOS - everything is declared in ~/.dotfiles and imperative installs break reproducibility. Also covers one-off tool use (nix shell / nix run), dev shells, rebuilding and rollback.
---

# Making changes to this NixOS machine

This machine is **NixOS**, configured declaratively by a flake at `~/.dotfiles`.
The rule that governs everything below:

> **Changing the machine means editing a file in `~/.dotfiles` and rebuilding.
> It never means running an install command.**

An imperative install (`nix-env -i`, `npm -g`, `pip install`, `cargo install`,
`curl | sh`, `apt`) either fails outright, silently disappears on the next
rebuild, or - worst case - lingers as untracked state that makes the machine
irreproducible. The owner of this machine (Eyal) cares specifically about that
last point, so do not do it, and do not suggest it as a fallback.

Eyal is a **novice at Nix but wants to understand it**. Explain what you are
changing and why the Nix mechanism works that way; don't just make the edit.

## 0. Orient yourself first

```bash
hostname                 # -> "onyx" or "phoenix"; both are configured in this repo
ls ~/.dotfiles           # the single source of truth for this machine
```

`~/.dotfiles/CLAUDE.md` is the authoritative map of the repo: the layer split,
the category folders, the `mkOption` "control center" pattern, and the rules.
**Read it before editing anything in there** - this skill tells you *how to
approach* OS-level work, that file tells you *where each thing lives*.

## 1. Which layer does the change belong to?

| The change affects | Layer | Lives in | Applied by |
| --- | --- | --- | --- |
| `/etc`, boot, kernel, drivers, system services, users, networking | NixOS | `~/.dotfiles/system/<category>/` | `nixos-rebuild` (root) |
| `~/`, user apps, dotfiles, shell, editor, desktop config, user services | home-manager | `~/.dotfiles/home/<category>/` | `home-manager` (user) |

Default to **home-manager**. A GUI app, a CLI tool, a font, an editor plugin,
a keybinding, a status-bar tweak - all of that is user-level. Reach for
`system/` only when it genuinely needs root: hardware, drivers, boot,
networking, a system-wide daemon, anything under `/etc`.

Modules in `home/` and `system/` apply to **every host**. If a change should
only affect one machine, don't hardcode it - declare an option in the module
and set it from `hosts/<hostname>/`. See the `mkOption` section of
`~/.dotfiles/CLAUDE.md`.

## 2. Installing an app or package

1. Find the real attribute name - **never guess it**:
   ```bash
   nix search nixpkgs discord
   ```
2. Add it to the **relevant existing module**, not to a host file and not to a
   new catch-all list. A new CLI tool goes in `home/cli/`, a GUI app in
   `home/apps/`, a language toolchain in `home/dev/languages/`, and so on:
   ```nix
   # home/cli/<tool>/default.nix
   { pkgs, ... }: {
     home.packages = [ pkgs.newtool ];
   }
   ```
   Then register the leaf in that category's `default.nix` imports list.
3. If the tool has a home-manager program module (`programs.<tool>.*`), **use
   it instead of a bare package + a hand-written config file**. It's the
   difference between an installed binary and a declaratively configured one:
   ```bash
   # is there a proper option for this tool?
   nix repl --expr 'import <home-manager/modules> {}'   # or:
   man home-configuration.nix | grep -i <tool>
   ```
   Check `search.nixos.org/options` (NixOS) and
   `home-manager-options.extranix.com` (home-manager) when unsure.
4. **`git add` the new file.** Flakes only see git-tracked files - a new
   `.nix` file that isn't staged is invisible to the build and produces a
   confusing "file not found" or "attribute missing" error.
5. Rebuild (section 4).

Unfree packages are already allowed (`nixpkgs.config.allowUnfree = true`).
If a package isn't in nixpkgs at all, package it in the module - see
`home/apps/openacp.nix` for a worked `buildNpmPackage` example - and say so
rather than falling back to a global npm/pip install.

## 3. Changing a setting

- **Never edit a config file under `~/.config/` or `/etc/` directly.** Most of
  them are read-only symlinks into `/nix/store`; the edit will fail, and if it
  somehow succeeds it will be wiped on the next rebuild.
- To find what generates a config file, follow the symlink and grep the repo:
  ```bash
  readlink -f ~/.config/waybar/config
  grep -rn "waybar" ~/.dotfiles/home/
  ```
- **Never `sudo systemctl enable`** a unit. Declare it (`services.foo.enable`
  for system, `systemd.user.services.*` / a home-manager module for user).
  `systemctl --user restart <unit>` to *test* something after a rebuild is
  fine - it changes no persistent state.
- Desktop/compositor services (waybar, kanshi, notifications) must be **user**
  services bound to `hyprland-session.target`, not root services - Hyprland
  owns the outputs. See the Wayland notes in `~/.dotfiles/CLAUDE.md`.
- Secrets never go in the repo in plaintext: they're sops-encrypted under
  `secrets/` and exposed via the sops-nix home module.

## 4. Rebuilding

Always **build before you switch**, and **ask before switching** - switch
mutates the live machine, and `nixos-rebuild` needs sudo.

```bash
cd ~/.dotfiles

# home-manager (user-level changes)
home-manager build  --flake .#eyal@$(hostname)     # safe: builds, activates nothing
home-manager switch --flake .#eyal@$(hostname)

# NixOS (system-level changes)
nixos-rebuild build        --flake .#$(hostname)   # safe
sudo nixos-rebuild switch  --flake .#$(hostname)

nix flake check                                    # evaluate without building
```

Report build failures with the actual error text. Nix errors are long but the
useful line is usually the last `error:` plus its trace - quote it, don't
paraphrase it.

**Rollback** if a switch goes wrong:

```bash
/nix/var/nix/profiles/per-user/eyal/home-manager-*-link/activate   # pick previous gen
sudo nixos-rebuild switch --rollback                               # system
```
A bad system generation can also be picked from the systemd-boot menu at boot.

## 5. One-off and temporary tools

Needing a tool *for the current task* is not the same as installing it. Use an
ephemeral shell - it leaves no trace and needs no rebuild:

```bash
nix run   nixpkgs#cowsay -- "hello"      # run once
nix shell nixpkgs#jq -c jq . file.json   # run a command with it on PATH
nix shell nixpkgs#ffmpeg                 # interactive subshell
```

Use this freely for your own work. Just be explicit that it is temporary - if
Eyal will want the tool tomorrow, that's a section-2 change instead.

## 6. Per-project dev environments

Project toolchains do **not** belong in the global profile. This repo drives
project checkouts and their dev shells declaratively through `prolix` in
`home/dev/repos/default.nix` - each project gets a `shell.drv = pkgs.mkShell { ... }`
and `direnv` loads it on `cd`. Add or extend a project's shell there.

For a repo that isn't managed by prolix, add a `flake.nix` with a `devShells`
output plus a `.envrc` containing `use flake`, and run `direnv allow`.

## 7. Never do these

- `nix-env -i`, `nix-env -e`, `nix profile install` - untracked mutable state
- `npm i -g`, `pip install`, `cargo install`, `go install`, `curl ... | sh`
- `sudo systemctl enable/disable`, editing `/etc/*` or `~/.config/*` by hand
- Adding packages straight to `environment.systemPackages` in a host file, or
  writing raw NixOS config in `hosts/*/` - hosts set options, modules do work
- Creating a new top-level category when an existing one fits
- Adding something "just in case" for a hypothetical future need
- Making a change and instantly reversing it when questioned - discuss first

## 8. When you can't do it now

If a request needs a decision from Eyal, more investigation, or hardware that
isn't present, append one plain-English line to `~/.dotfiles/INBOX.md` rather
than leaving an undocumented imperative workaround in place. If something
truly cannot be declarative yet, do it imperatively **and** write down in the
relevant module (as a comment) what was done and why it can't be declared.

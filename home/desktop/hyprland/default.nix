{ lib, ... }:

# Hyprland is configured in its Lua format (`hyprland.lua`), not the older
# hyprlang `hyprland.conf`. Hyprland 0.56 warns that `.conf` support is removed
# in 0.57, so the Lua format is the only forward-compatible option.
#
# In the Lua format every top-level attribute below becomes an `hl.<name>(...)`
# call, and a list value becomes one call per element. `_args` turns an attrset
# into a multi-argument call, and `mkLuaInline` emits a raw Lua expression
# (needed for dispatchers, which are Lua values rather than strings).
let
  inherit (lib.generators) mkLuaInline;

  # Program/modifier indirection lives in Nix rather than as Lua locals — the
  # generated file is an artifact, so the abstraction belongs in the source.
  mod      = "SUPER";
  terminal = "kitty";
  browser  = "qutebrowser";
  explorer = "oil";

  # Lua string literal. JSON's escaping rules are a subset of Lua's, so this is
  # safe for the shell snippets below (quotes, backslashes).
  luaStr = builtins.toJSON;

  exec = cmd: "hl.dsp.exec_cmd(${luaStr cmd})";

  # hl.bind(keys, dispatcher[, opts])
  bind = keys: dispatcher: { _args = [ keys (mkLuaInline dispatcher) ]; };
  bindOpts = keys: dispatcher: opts: { _args = [ keys (mkLuaInline dispatcher) opts ]; };
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";

    settings = {
      # ── Variables ─────────────────────────────────────────
      config = {
        input = {
          kb_layout = "us,il";
          kb_options = "grp:alt_shift_toggle";
        };

        general = {
          gaps_in = 4;
          gaps_out = 8;
          border_size = 2;
        };

        decoration = {
          rounding = 8;
          blur = {
            enabled = true;
            size = 4;
            passes = 2;
          };
          shadow = {
            enabled = true;
            range = 8;
            render_power = 2;
          };
        };

        animations.enabled = true;
      };

      # ── Animations ────────────────────────────────────────
      # hl.curve replaces `bezier = name, x1, y1, x2, y2`
      curve = {
        _args = [
          "ease"
          {
            type = "bezier";
            points = [ [ 0.25 0.1 ] [ 0.25 1.0 ] ];
          }
        ];
      };

      # hl.animation replaces `animation = leaf, onoff, speed, curve, style`
      animation = [
        { leaf = "windows";    enabled = true; speed = 3; bezier = "ease"; style = "popin 85%"; }
        { leaf = "fade";       enabled = true; speed = 4; bezier = "ease"; }
        { leaf = "workspaces"; enabled = true; speed = 4; bezier = "ease"; style = "slide"; }
      ];

      # ── Autostart ─────────────────────────────────────────
      # Replaces `exec-once`. Home Manager adds a second hyprland.start hook of
      # its own for the systemd session target.
      on = {
        _args = [
          "hyprland.start"
          (mkLuaInline ''
            function()
              hl.exec_cmd(${luaStr "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"})
              hl.exec_cmd(${luaStr "awww-daemon"})
              hl.exec_cmd(${luaStr "sh -c 'sleep 2; while true; do for output in $(hyprctl monitors -j | jq -r \".[].name\"); do awww img $(find ~/.dotfiles/assets/wallpapers -type f | shuf -n1) --outputs $output --transition-type grow --transition-pos center --transition-duration 2; done; sleep 1200; done'"})
              hl.exec_cmd(${luaStr "wl-paste --watch cliphist store"})
            end'')
        ];
      };

      # ── Keybinds ──────────────────────────────────────────
      bind = [
        # Apps
        (bind "${mod} + Return" (exec terminal))
        (bind "${mod} + B" (exec browser))
        (bind "${mod} + E" (exec "${terminal} -e ${explorer}"))
        (bind "${mod} + D" (exec "fuzzel"))
        (bind "${mod} + V" (exec "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))
        (bind "${mod} + N" (exec "open-notification-history"))

        # Window management
        (bind "${mod} + Q" "hl.dsp.window.close()")
        (bind "${mod} + F" ''hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" })'')
        (bind "${mod} + Space" ''hl.dsp.window.float({ action = "toggle" })'')
        (bind "${mod} + M" "hl.dsp.exit()")

        # Focus movement (vim-style)
        (bind "${mod} + H" ''hl.dsp.focus({ direction = "left" })'')
        (bind "${mod} + L" ''hl.dsp.focus({ direction = "right" })'')
        (bind "${mod} + K" ''hl.dsp.focus({ direction = "up" })'')
        (bind "${mod} + J" ''hl.dsp.focus({ direction = "down" })'')

        # Move windows
        (bind "${mod} + SHIFT + H" ''hl.dsp.window.move({ direction = "left" })'')
        (bind "${mod} + SHIFT + L" ''hl.dsp.window.move({ direction = "right" })'')
        (bind "${mod} + SHIFT + K" ''hl.dsp.window.move({ direction = "up" })'')
        (bind "${mod} + SHIFT + J" ''hl.dsp.window.move({ direction = "down" })'')

        # Workspace cycling
        (bind "${mod} + Tab" ''hl.dsp.focus({ workspace = "e+1" })'')
        (bind "${mod} + SHIFT + Tab" ''hl.dsp.focus({ workspace = "e-1" })'')

        # Switch to workspace
        (bind "${mod} + 1" "hl.dsp.focus({ workspace = 1 })")
        (bind "${mod} + 2" "hl.dsp.focus({ workspace = 2 })")
        (bind "${mod} + 3" "hl.dsp.focus({ workspace = 3 })")
        (bind "${mod} + 4" "hl.dsp.focus({ workspace = 4 })")
        (bind "${mod} + 5" "hl.dsp.focus({ workspace = 5 })")

        # Move window to workspace
        (bind "${mod} + SHIFT + 1" "hl.dsp.window.move({ workspace = 1 })")
        (bind "${mod} + SHIFT + 2" "hl.dsp.window.move({ workspace = 2 })")
        (bind "${mod} + SHIFT + 3" "hl.dsp.window.move({ workspace = 3 })")
        (bind "${mod} + SHIFT + 4" "hl.dsp.window.move({ workspace = 4 })")
        (bind "${mod} + SHIFT + 5" "hl.dsp.window.move({ workspace = 5 })")

        # Resize (held down — `repeating` replaces the old `binde`)
        (bindOpts "${mod} + ALT + H" "hl.dsp.window.resize({ x = -20, y = 0, relative = true })" { repeating = true; })
        (bindOpts "${mod} + ALT + L" "hl.dsp.window.resize({ x = 20, y = 0, relative = true })" { repeating = true; })
        (bindOpts "${mod} + ALT + K" "hl.dsp.window.resize({ x = 0, y = -20, relative = true })" { repeating = true; })
        (bindOpts "${mod} + ALT + J" "hl.dsp.window.resize({ x = 0, y = 20, relative = true })" { repeating = true; })

        # Volume (media keys — no modifier needed)
        (bind "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
        (bind "XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
        (bind "XF86AudioRaiseVolume" (exec "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"))
      ];

      # Workspace-to-monitor pinning lives in hosts/<machine>/monitors.nix
      # (monitor connector names are machine-specific)
    };
  };
}

{ pkgs, ... }:

# Claude Code: the package plus its user-level configuration.
#
# ~/.claude/ is otherwise Claude Code's own mutable state directory (sessions,
# history, settings.json it rewrites itself), so only the two files we own are
# symlinked in — never the whole directory.
{
  home.packages = [ pkgs.claude-code ];

  # Global instructions loaded into every Claude session on this machine.
  home.file.".claude/CLAUDE.md".source = ./user-instructions.md;

  # Personal skills — available in every project, on every host in this flake.
  home.file.".claude/skills/nixos-system-changes/SKILL.md".source =
    ./skills/nixos-system-changes/SKILL.md;
}

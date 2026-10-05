{ ... }:

{
  programs.gh = {
    enable = true;

    settings = {
      # Use SSH for anything gh clones or creates a remote for, matching the
      # SSH-based setup in ../ssh. Without this gh defaults to HTTPS and would
      # hand new clones a remote that needs a different auth path than every
      # existing one. (The pre-Nix config.yml this module replaced was on the
      # HTTPS default.)
      git_protocol = "ssh";

      # gh's own stock alias, carried over from that same pre-Nix config so
      # taking the file over declaratively doesn't quietly remove it.
      aliases.co = "pr checkout";
    };
  };

  # Note: programs.gh.gitCredentialHelper.enable defaults to true, which
  # registers gh as git's credential helper for github.com over HTTPS. That is
  # inert while remotes are SSH, and is what makes an occasional HTTPS clone
  # work without a PAT, so it is left at the default.
}

{ ... }:

# Lets unmodified, dynamically-linked binaries that weren't built by Nix run
# (e.g. prebuilt native binaries that tools like npx/pip fetch at runtime).
# NixOS has no dynamic linker at the standard FHS path those binaries expect;
# nix-ld provides a generic stub there. See https://nix.dev/permalink/stub-ld
{
  programs.nix-ld.enable = true;
}

# CLAUDE.md — Eyal's NixOS Dotfiles

## About this repo

Personal NixOS configuration for everyday use (includes development, file management, web browsing and so on). Managed with Nix flakes, standalone home-manager, and a growing set of modules.

## About the user

Eyal is a **novice to NixOS/Nix**, but enthusiastic and willing to go deep. The goal is not just a working system, but genuine understanding of every piece of it.

He uses Claude Code as an interactive tutor + pair programmer: explain concepts, deliberate decisions together, then act.

## Collaboration style

- **Explain before acting.** When introducing a concept, tool, or approach, give a short explanation of what it is and why it matters in NixOS terms.
- **Deliberate, don't just comply.** If Eyal questions a decision, don't immediately reverse it. Explain the reasoning, explore trade-offs, then reach a conclusion together.
- **Never make silent trade-offs.** If there are two ways to do something, say so briefly and recommend one — don't just pick one silently.

## Philosophy

Eyal cares deeply about doing things **the Nix Way**:

- Declarative over imperative wherever possible.
- Pure and reproducible — avoid `nix-env -i`, mutable state, or workarounds that break reproducibility.
- Everything should be expressible in the flake/modules; one-off shell commands are a last resort, not a first instinct.
- If there is a "proper" NixOS/home-manager option for something, use it rather than a raw package install + manual config file.

## What to avoid

- Don't make a change and then immediately reverse it when questioned — discuss first.
- Don't add things "just in case" or for hypothetical future needs.
- Don't leave imperative steps undocumented (if something *must* be done imperatively, note it clearly and explain why it can't be declarative yet).

{ pkgs, ... }:

  {
    programs.neovim = {
      enable = true;
      defaultEditor = true;

      initLua = ''
        -- Basic options
        vim.opt.number = true
        vim.opt.relativenumber = true
        vim.opt.tabstop = 2
        vim.opt.shiftwidth = 2
        vim.opt.expandtab = true
        vim.opt.smartindent = true
        vim.opt.wrap = false
        vim.opt.scrolloff = 8
        vim.opt.signcolumn = "yes"
        vim.opt.updatetime = 50

        -- Leader key
        vim.g.mapleader = " "
        vim.g.maplocalleader = " "
      '';
    };
  }

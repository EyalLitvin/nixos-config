{ pkgs, ... }:

  {
    programs.nixvim = {
      enable = true;
      defaultEditor = true;

      opts = {
        number = true;
        relativenumber = true;
        tabstop = 2;
        shiftwidth = 2;
        expandtab = true;
        smartindent = true;
        wrap = true;
        scrolloff = 8;
        signcolumn = "yes";
        updatetime = 50;
      };

      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };

      keymaps = [
        {
          mode = "n";
          key = "<leader>w";
          action = "<cmd>w<cr>";
          options.desc = "Save file";
        }
      ];

      colorschemes.tokyonight.enable = true;

      plugins.which-key = {
        enable = true;
        settings.preset = "modern";
      };
    };
  }

{ ... }:

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
        clipboard = "unnamedplus";
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
        {
          mode = "n";
          key = "<leader>e";
          action = "<cmd>Oil<cr>";
          options.desc = "File Explorer";
        }
        {
          mode = "n";
          key = "<leader>g";
          action = "<cmd>Neogit<cr>";
          options.desc = "Git";
        }
      ];

      colorschemes.tokyonight.enable = true;

      plugins.web-devicons.enable = true;

      plugins.which-key = {
        enable = true;
        settings = {
          preset = "modern";
          spec = [
          {
            __unkeyed-1 = "<leader>f";
            group = "find";
          }
          #{
          #  __unkeyed-1 = "<leader>e";
          #  group = "explorer";
          #}
          ];
        };
      };

      plugins.treesitter = {
        enable = true;
        settings.highlight.enable = true;
      };

      plugins.neogit = {
        enable = true;
      };

      plugins.lsp = {
        enable = true;
        servers = {
          pyright.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
          nixd.enable = true;
        };
      };

      plugins.telescope = {
        enable = true;
        keymaps = {
          "<leader>ff" = {
            action = "find_files";
            options.desc = "Find Files";
          };
          "<leader>fg" = {
            action = "live_grep";
            options.desc = "Live Grep";
          };
          "<leader>fb" = {
            action = "buffers";
            options.desc = "Buffers";
          };
          "<leader>fh" = {
            action = "help_tags";
            options.desc = "Help Tags";
          };
        };
      };
      
      plugins.oil = {
        enable = true;
        settings = {
          default_file_explorer = true;
          view_options.show_hidden = true;
        };
      };
    };
  }

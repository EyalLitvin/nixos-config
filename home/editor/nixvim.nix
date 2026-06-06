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
      clipboard = "unnamedplus";
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    keymaps = [
      { mode = "n"; key = "<leader>w"; action = "<cmd>w<cr>";          options.desc = "Save file"; }
      { mode = "n"; key = "<leader>e"; action = "<cmd>Oil<cr>";        options.desc = "File Explorer"; }
      { mode = "n"; key = "<leader>g"; action = "<cmd>Neogit<cr>";     options.desc = "Git"; }
      { mode = "n"; key = "<leader>t"; action = "<cmd>ToggleTerm<cr>"; options.desc = "Terminal"; }
      { mode = "n"; key = "<leader>p"; action.__raw = ''
          function()
            local ft = vim.bo.filetype
            if ft == "typst" then
              local client = vim.lsp.get_clients({ bufnr = 0, name = "tinymist" })[1]
              if client then
                client:exec_cmd({
                  command = "tinymist.startDefaultPreview",
                  arguments = { { uri = vim.uri_from_fname(vim.api.nvim_buf_get_name(0)) } },
                })
              end
            end
          end
        ''; options.desc = "Preview"; }
    ];

    colorschemes.tokyonight.enable = true;

    plugins.web-devicons.enable = true;

    plugins.which-key = {
      enable = true;
      settings = {
        preset = "modern";
        spec = [
          { __unkeyed-1 = "<leader>f"; group = "find"; }
        ];
      };
    };

    plugins.treesitter = {
      enable = true;
      settings.highlight.enable = true;
    };

    plugins.neogit.enable = true;

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
        tinymist = {
          enable = true;
          settings.exportPdf = "onSave";
        };
      };
    };

    plugins.cmp = {
      enable = true;
      settings.sources = [
        { name = "nvim_lsp"; }
        { name = "buffer"; }
        { name = "path"; }
      ];
      settings.mapping = {
        "<C-Space>" = "cmp.mapping.complete()";
        "<CR>"      = "cmp.mapping.confirm({ select = true })";
        "<Tab>"     = "cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' })";
        "<S-Tab>"   = "cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' })";
      };
    };

    plugins.gitsigns.enable = true;

    plugins.comment.enable = true;

    plugins.indent-blankline.enable = true;

    plugins.telescope = {
      enable = true;
      keymaps = {
        "<leader>ff" = { action = "find_files";  options.desc = "Find Files"; };
        "<leader>fg" = { action = "live_grep";   options.desc = "Live Grep"; };
        "<leader>fb" = { action = "buffers";     options.desc = "Buffers"; };
        "<leader>fh" = { action = "help_tags";   options.desc = "Help Tags"; };
      };
    };

    plugins.oil = {
      enable = true;
      settings = {
        default_file_explorer = true;
        view_options.show_hidden = true;
      };
    };

    plugins.render-markdown.enable = true;

    plugins.toggleterm = {
      enable = true;
      settings = {
        direction = "float";
        float_opts.border = "curved";
      };
    };

    extraPlugins = [ pkgs.vimPlugins.kitty-scrollback-nvim ];
    extraConfigLua = ''
      require('kitty-scrollback').setup({
        paste_window = { enabled = false },
      })
      vim.filetype.add({ extension = { mdx = "markdown" } })

      -- Extend HTML treesitter injection queries so that text content inside
      -- JSX component elements (uppercase tag names like <Lead>, <Callout>)
      -- is parsed as markdown_inline. This lets render-markdown find and render
      -- inline_link nodes inside MDX component blocks.
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          local existing = ""
          for _, path in ipairs(vim.api.nvim_get_runtime_file("queries/html/injections.scm", true)) do
            local f = io.open(path, "r")
            if f then
              existing = existing .. f:read("*a") .. "\n"
              f:close()
            end
          end
          local addition = [[
(element
  (start_tag (tag_name) @_name)
  (text) @injection.content
  (#match? @_name "^[A-Z]")
  (#set! injection.language "markdown_inline"))
]]
          vim.treesitter.query.set("html", "injections", existing .. addition)
        end,
      })
    '';
  };
}

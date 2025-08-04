{ config
, lib
, pkgsUnstable
, ...
}:

let
  cfg = config.custom.nvim.lsp;
  parent = config.custom.nvim;

  luaPluginInline = plugin: config: {
    inherit plugin config;
    type = "lua";
  };

  luaPlugin = plugin: configPath: {
    inherit plugin;
    type = "lua";
    config = builtins.readFile configPath;
  };

  inherit (lib) mkIf;
in
{
  options.custom.nvim.lsp = with lib; {
    enable = mkOption rec {
      description = "Whether to enable and configure LSP-related neovim plugins";
      type = types.bool;
      default = true;
      example = !default;
    };
  };

  config = mkIf (parent.enable && cfg.enable) {
    programs.neovim = {
      plugins = (with pkgsUnstable.vimPlugins; [
        cmp-cmdline
        cmp-fuzzy-path
        cmp-nvim-lsp
        cmp_luasnip
        fuzzy-nvim
        lspkind-nvim
        luasnip

        (luaPlugin fidget-nvim ./config/fidget.lua)
        (luaPlugin nvim-cmp ./config/nvim-cmp.lua)
        (luaPlugin nvim-lspconfig ./config/lspconfig.lua)
        (luaPlugin vim-illuminate ./config/illuminate.lua)

        (luaPluginInline rustaceanvim ''
          local cmp_lsp = require'cmp_nvim_lsp'
          local capabilities = cmp_lsp.default_capabilities()
          
          local inlay_group = vim.api.nvim_create_augroup('inlay_highlight', {})
          vim.api.nvim_create_autocmd('ColorScheme', {
            group = inlay_group,
            pattern = '*',
            callback = function()
              vim.cmd('highlight! LspInlayHint ctermfg=59 guifg=#5c6370 gui=italic')
            end,
          })
          
          vim.g.rustaceanvim = {
            tools = {
            },
            server = {
              cmd = { 'rust-analyzer' },
              capabilities = capabilities,
              on_attach = function(client, bufnr)
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
              end,
              default_settings = {
                ['rust-analyzer'] = {
                  assist = {
                    importEnforceGranularity = true,
                    importPrefix = "crate",
                  },
                  -- cargo = {
                  --   allFeatures = true,
                  -- },
                  -- checkOnSave = {
                  --   command = "clippy",
                  -- },
                  completion = {
                    postfix = {
                      enable = false,
                    },
                  },
                  diagnostics = {
                    disabled = {
                      "unresolved-proc-macro",
                    },
                  },
                  hover = {
                    links = {
                      -- It's ugly when rust-analyzer tries to display docs.rs links for links in
                      -- markdown docs.
                      enable = false,
                    },
                    imports = {
                      prefix = {
                        "self",
                      },
                    },
                  },
                },
              },
            },
            dap = {
            },
          }
        '')
      ]);

      extraPackages = with pkgsUnstable; [
        lua-language-server
        nil # NIx Language server
        nixpkgs-fmt # For nil to format stuff
        nodePackages.bash-language-server # Bash language server
        shellcheck # For Bash
        texlab # TeX language server
        tinymist # Typst language server
      ];
    };
  };
}

{ config
, lib
, pkgs
, pkgsUnstable
, ...
}:

let
  cfg = config.custom.nvim.lsp;
  parent = config.custom.nvim;

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
      plugins = (with pkgs.vimPlugins; [
        cmp-cmdline
        cmp-fuzzy-path
        cmp-nvim-lsp
        cmp_luasnip
        fuzzy-nvim
        lspkind-nvim
        luasnip

        (luaPlugin fidget-nvim ./config/fidget.lua)
        (luaPlugin nvim-lspconfig ./config/lspconfig.lua)
        (luaPlugin vim-illuminate ./config/illuminate.lua)
      ]) ++ (with pkgsUnstable.vimPlugins; [
        (luaPlugin nvim-cmp ./config/nvim-cmp.lua)
        (luaPlugin rust-tools-nvim ./config/rust-tools.lua)
      ]);

      extraPackages = with pkgs; [
        lua-language-server
        nil # NIx Language server
        nixpkgs-fmt # For nil to format stuff
        nodePackages.bash-language-server # Bash language server
        shellcheck # For Bash
        texlab # TeX language server
        typst-lsp # Typst language server
      ];
    };
  };
}

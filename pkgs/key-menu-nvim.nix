{
  lib,
  vimUtils,
  fetchFromGitHub,
}: let
  owner = "cetanu";
  repo = "key-menu.nvim";
  rev = "8437c2a764707d75f7ecc418035f417b70534c69";
  sha256 = "sha256-uWAZKk5cdP+KeDfySjVIDkPOYZHy+zOPzoRgfuIKkzs=";
in
  vimUtils.buildVimPlugin {
    pname = repo;
    version = rev;

    src = fetchFromGitHub {
      inherit owner repo rev sha256;
    };
  }

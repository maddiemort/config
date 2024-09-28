{ lib
, vimUtils
, fetchFromGitHub
}:

let
  owner = "susliko";
  repo = "tla.nvim";
  rev = "e419c75e805ab6d9967c7325bf35734c372d3d4b";
  sha256 = "sha256-fts2Y7qUPcqZeBUVwBULWrquUA9Dc9C6RbeMlBG3wjM=";
in

vimUtils.buildVimPlugin {
  pname = repo;
  version = rev;

  src = fetchFromGitHub {
    inherit owner repo rev sha256;
  };
}

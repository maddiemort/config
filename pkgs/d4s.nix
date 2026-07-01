{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule (finalAttrs: rec {
  pname = "d4s";
  version = "0.49.100";

  src = fetchFromGitHub {
    owner = "jr-k";
    repo = pname;
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-YraKzfMVnWxR4Ec0bwuhjdyCugkP/G2Nb2yaMUfV948=";
  };

  vendorHash = "sha256-OdjlW33gkV30hP8tPdv6qFEmStgCW4XyxCo2onV8X7w=";

  meta = {
    description = "A fast, keyboard-driven terminal UI to manage Docker containers, Compose stacks, and Swarm services with the ergonomics of K9s";
    homepage = "https://d4scli.io";
    license = lib.licenses.asl20; # Apache-2.0
    maintainers = [ ];
  };
})

{ config, ... }: {
  imports = [
    ../work.nix
  ];

  age.identityPaths = [
    "${config.home.homeDirectory}/.ssh/id_ed25519_maddie_eq_0265"
  ];

  age.secrets.id_ed25519_jj_ikerian = {
    file = ../../secrets/id_ed25519_jj_ikerian.age;
    path = "$HOME/.ssh/id_ed25519_jj_ikerian";
  };

  age.secrets.id_ed25519_sk_maddie_ikerian = {
    file = ../../secrets/id_ed25519_sk_maddie_ikerian.age;
    path = "$HOME/.ssh/id_ed25519_sk_maddie_ikerian";
  };

  age.secrets.id_ed25519_sk_maddie_ikerian_c = {
    file = ../../secrets/id_ed25519_sk_maddie_ikerian_c.age;
    path = "$HOME/.ssh/id_ed25519_sk_maddie_ikerian_c";
  };

  custom = {
    auth = {
      publicKeys = {
        "*" = [
          "~/.ssh/id_ed25519_sk_maddie_ikerian"
          "~/.ssh/id_ed25519_sk_maddie_ikerian_c"
        ];
      };
    };

    git = {
      user = {
        signingKey = "~/.ssh/id_ed25519_jj_ikerian";
      };
    };
  };

  home = {
    file.".ssh/id_ed25519_jj_ikerian.pub".source = ../../keys/maddie-jj-ikerian.pub;
    file.".ssh/id_ed25519_sk_maddie_ikerian.pub".source = ../../keys/maddie-ikerian.pub;
    file.".ssh/id_ed25519_sk_maddie_ikerian_c.pub".source = ../../keys/maddie-ikerian-c.pub;

    stateVersion = "25.11";
    username = "madeleine.mortensen";
  };

  xdg.configFile."jj/conf.d/20-EQ-0265.toml".text = ''
    [signing]
    key = "~/.ssh/id_ed25519_jj_ikerian.pub"
  '';
}

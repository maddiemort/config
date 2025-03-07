{ pkgs
, ...
}:

{
  age.secrets.id_ed25519_jj_ditto = {
    file = ../../secrets/id_ed25519_jj_ditto.age;
    path = "/Users/maddie/.ssh/id_ed25519_jj_ditto";
  };

  age.secrets.id_ed25519_sk_maddie_ditto = {
    file = ../../secrets/id_ed25519_sk_maddie_ditto.age;
    path = "/Users/maddie/.ssh/id_ed25519_sk_maddie_ditto";
  };

  age.secrets.id_ed25519_sk_maddie_wtf = {
    file = ../../secrets/id_ed25519_sk_maddie_wtf.age;
    path = "/Users/maddie/.ssh/id_ed25519_sk_maddie_wtf";
  };

  home = {
    file.".ssh/id_ed25519_jj_ditto.pub".source = ../../keys/maddie-jj-ditto.pub;
    file.".ssh/id_ed25519_sk_maddie_ditto.pub".source = ../../keys/maddie-ditto.pub;
    file.".ssh/id_ed25519_sk_maddie_wtf.pub".source = ../../keys/maddie-wtf.pub;
  };

  xdg.configFile."jj/conf.d/20-nashira.toml".text = ''
    [signing]
    key = "~/.ssh/id_ed25519_jj_ditto.pub"
  '';

  xdg.configFile."jj/conf.d/30-ditto.toml".text = ''
    --when.repositories = ["~/src/github.com/getditto"]

    [user]
    email = "maddie@ditto.live"
  '';

  custom = {
    auth = {
      publicKeys = [
        { host = "*"; path = "~/.ssh/id_ed25519_sk_maddie_ditto"; }
      ];
    };

    git = {
      user = {
        key = "~/.ssh/id_ed25519_sk_maddie_wtf";
      };

      includes =
        let
          ditto-include = pkgs.writeText "config-ditto-include" ''
            [user]
                email = "maddie@ditto.live"
                signingkey = "~/.ssh/id_ed25519_sk_maddie_ditto"
          '';
        in
        [
          {
            condition = "gitdir:~/src/github.com/getditto/";
            path = ditto-include;
          }
        ];
    };
  };
}

{ pkgs
, ...
}:

{
  age.secrets.id_ed25519_jj_ditto = {
    file = ../../secrets/id_ed25519_jj_ditto.age;
    path = "/Users/maddie/.ssh/id_ed25519_jj_ditto";
  };

  age.secrets.id_ed25519_sk_maddie_ditto_c = {
    file = ../../secrets/id_ed25519_sk_maddie_ditto_c.age;
    path = "/Users/maddie/.ssh/id_ed25519_sk_maddie_ditto_c";
  };

  age.secrets.id_ed25519_sk_maddie_wtf_c = {
    file = ../../secrets/id_ed25519_sk_maddie_wtf_c.age;
    path = "/Users/maddie/.ssh/id_ed25519_sk_maddie_wtf_c";
  };

  home = {
    file.".ssh/id_ed25519_jj_ditto.pub".source = ../../keys/maddie-jj-ditto.pub;
    file.".ssh/id_ed25519_sk_maddie_ditto_c.pub".source = ../../keys/maddie-ditto-c.pub;
    file.".ssh/id_ed25519_sk_maddie_wtf_c.pub".source = ../../keys/maddie-wtf-c.pub;
  };

  custom = {
    auth = {
      publicKeys = [
        { host = "*"; path = "~/.ssh/id_ed25519_sk_maddie_ditto_c"; }
      ];
    };

    git = {
      user = {
        key = "~/.ssh/id_ed25519_sk_maddie_wtf_c";
      };

      includes =
        let
          ditto-include = pkgs.writeText "config-ditto-include" ''
            [user]
                email = "maddie@ditto.live"
                signingkey = "~/.ssh/id_ed25519_sk_maddie_ditto_c"
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

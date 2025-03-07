{ ...
}:

{
  age.secrets.id_ed25519_jj_wtf = {
    file = ../../secrets/id_ed25519_jj_wtf.age;
    path = "/Users/maddie/.ssh/id_ed25519_jj_wtf";
  };

  age.secrets.id_ed25519_sk_maddie_wtf_c = {
    file = ../../secrets/id_ed25519_sk_maddie_wtf_c.age;
    path = "/Users/maddie/.ssh/id_ed25519_sk_maddie_wtf_c";
  };

  home = {
    file.".ssh/id_ed25519_jj_wtf.pub".source = ../../keys/maddie-jj-wtf.pub;
    file.".ssh/id_ed25519_sk_maddie_wtf_c.pub".source = ../../keys/maddie-wtf-c.pub;
  };

  xdg.configFile."jj/conf.d/20-betelgeuse.toml".text = ''
    [signing]
    key = "~/.ssh/id_ed25519_jj_wtf.pub"
  '';

  custom = {
    auth = {
      publicKeys = [
        { host = "*"; path = "~/.ssh/id_ed25519_sk_maddie_wtf_c"; }
      ];
    };

    git = {
      user = {
        key = "~/.ssh/id_ed25519_sk_maddie_wtf_c";
      };
    };
  };
}

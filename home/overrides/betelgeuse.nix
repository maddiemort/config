{ ...
}:

{
  # age.secrets.id_ed25519_sk_maddie_wtf_c = {
  #   file = ../../secrets/id_ed25519_sk_maddie_wtf_c.age;
  #   path = "/Users/maddie/.ssh/id_ed25519_sk_maddie_wtf_c";
  # };

  home = {
    file.".ssh/id_ed25519_sk_maddie_wtf_c.pub".source = ../../keys/maddie-wtf-c.pub;
  };

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

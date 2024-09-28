{ ...
}:

{
  # age.secrets.id_ed25519_sk_maddie_wtf = {
  #   file = ../../secrets/id_ed25519_sk_maddie_wtf.age;
  #   path = "/Users/maddie/.ssh/id_ed25519_sk_maddie_wtf";
  # };

  home = {
    # file.".ssh/id_ed25519_sk_maddie_wtf.pub".source = ../../keys/maddie-wtf.pub;
  };

  custom = {
    auth = {
      publicKeys = [
        { host = "*"; path = "~/.ssh/id_ed25519_sk_maddie_wtf"; }
      ];
    };

    git = {
      user = {
        key = "~/.ssh/id_ed25519_sk_maddie_wtf";
      };
    };
  };
}

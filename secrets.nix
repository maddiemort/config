let
  inherit (builtins) mapAttrs readFile;

  # Public keys of specific machines.
  merope = readFile ./keys/merope.pub;
  EQ-0265 = readFile ./keys/EQ-0265.pub;

  # Each of the secrets is given a list of public keys that should be used to
  # encrypt them. Right now, only the machine-specific keys from above are added
  # to the list for each secret, because these are the keys that will not
  # necessarily be given access to every secret.
  secrets = {
    "secrets/id_ed25519_jj_wtf.age".publicKeys = [merope];
    "secrets/id_ed25519_jj_ikerian.age".publicKeys = [EQ-0265];
    "secrets/id_ed25519_sk_maddie_ikerian.age".publicKeys = [EQ-0265];
    "secrets/id_ed25519_sk_maddie_ikerian_c.age".publicKeys = [EQ-0265];
    "secrets/id_ed25519_sk_maddie_wtf.age".publicKeys = [];
    "secrets/id_ed25519_sk_maddie_wtf_c.age".publicKeys = [merope];
  };

  # Keys that should always be able to access every secret, so they can be used to access and
  # re-encrypt secrets.
  general = let
    # Public keys of age-plugin-yubikey keys, the counterparts to the keygrips in `./identities/`.
    #
    # These are not Yubikey SSH keys, because those can't be used with agenix at the moment.
    maddie-wtf = "age1yubikey1qdtdsjttgdcsfvu0g5n3vsf50e35ntcgjkjpd4d7hgzez8gk55rguc6tte7";
    maddie-wtf-c = "age1yubikey1q0cqe58rgzxjaky7nj3gzs6a9eujsu35lkchl9njlep80atwd6w4v3nu7pz";
    maddie-ikerian = "age1yubikey1qd46egdvcm4snry90v4kxj25tg30mjsx93fkququlkaf6gjwjtq7g5gr8am";
    maddie-ikerian-c = "age1yubikey1qt4t5gjkzljvpr3tm2svdv4wcnskf4jupsyyr3gx7p4fz0rqwlhlkjqhy4u";
  in [
    maddie-wtf
    maddie-wtf-c
    maddie-ikerian
    maddie-ikerian-c
  ];
in
  # Map each secret's `publicKeys` list to a new one that also includes `general`.
  mapAttrs
  (_: secret: {publicKeys = secret.publicKeys ++ general;})
  secrets

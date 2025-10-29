let
  inherit (builtins) mapAttrs readFile;

  # Public keys of specific machines.
  nashira = readFile ./keys/nashira.pub;
  natasha = readFile ./keys/natasha.pub;

  # Each of the secrets is given a list of public keys that should be used to
  # encrypt them. Right now, only the machine-specific keys from above are added
  # to the list for each secret, because these are the keys that will not
  # necessarily be given access to every secret.
  secrets = {
    "secrets/ditto-license.age".publicKeys = [nashira natasha];
    "secrets/id_ed25519_jj_ditto.age".publicKeys = [nashira];
    "secrets/id_ed25519_jj_ditto_com.age".publicKeys = [nashira natasha];
    "secrets/id_ed25519_jj_wtf.age".publicKeys = [];
    "secrets/id_ed25519_sk_maddie_ditto.age".publicKeys = [nashira];
    "secrets/id_ed25519_sk_maddie_ditto_c.age".publicKeys = [natasha];
    "secrets/id_ed25519_sk_maddie_wtf.age".publicKeys = [];
    "secrets/id_ed25519_sk_maddie_wtf_c.age".publicKeys = [natasha];
    "secrets/quay-email-ditto.age".publicKeys = [nashira natasha];
    "secrets/quay-token-ditto.age".publicKeys = [nashira natasha];
    "secrets/quay-user-ditto.age".publicKeys = [nashira natasha];
  };

  # Public keys of age-plugin-yubikey keys, the counterparts to the keygrips in
  # `./identities/`.
  #
  # These are not Yubikey SSH keys, because those can't be used with agenix at
  # the moment.
  maddie-ditto = "age1yubikey1qgeyg6v9kch8g0tu05ms05z40lv250eguy0ujep7em4l2hqvrd3uwtjm47u";
  maddie-ditto-c = "age1yubikey1q29q3ykjxvwxv6dmtldkxjuc2c0227x5lsknpvmxxk64nhggxc7dqzpnp0l";
  maddie-wtf = "age1yubikey1qdtdsjttgdcsfvu0g5n3vsf50e35ntcgjkjpd4d7hgzez8gk55rguc6tte7";
  maddie-wtf-c = "age1yubikey1q0cqe58rgzxjaky7nj3gzs6a9eujsu35lkchl9njlep80atwd6w4v3nu7pz";

  # Keys that should always be able to access every secret, so they can be used
  # to access and re-encrypt secrets.
  general = [
    maddie-ditto
    maddie-ditto-c
    maddie-wtf
    maddie-wtf-c
  ];
in
  # Map each secret's `publicKeys` list to a new one that also includes `general`.
  mapAttrs
  (_: secret: {publicKeys = secret.publicKeys ++ general;})
  secrets

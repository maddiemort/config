let
  inherit (builtins) mapAttrs readFile;

  # Public keys of specific machines.
  nashira = readFile ./keys/nashira.pub;

  # Each of the secrets is given a list of public keys that should be used to
  # encrypt them. Right now, only the machine-specific keys from above are added
  # to the list for each secret, because these are the keys that will not
  # necessarily be given access to every secret.
  secrets = {
    "secrets/ditto-license.age".publicKeys = [ nashira ];
    "secrets/id_ed25519_jj_ditto.age".publicKeys = [ nashira ];
    "secrets/id_ed25519_sk_maddie_ditto.age".publicKeys = [ nashira ];
    "secrets/quay-email-ditto.age".publicKeys = [ nashira ];
    "secrets/quay-token-ditto.age".publicKeys = [ nashira ];
    "secrets/quay-user-ditto.age".publicKeys = [ nashira ];
  };

  # Public key of an age-plugin-yubikey key, the counterpart to the keygrip
  # `./identities/maddie-ditto.txt`.
  #
  # This is not a Yubikey SSH key, because those can't be used with agenix at
  # the moment.
  maddie-ditto = "age1yubikey1qgeyg6v9kch8g0tu05ms05z40lv250eguy0ujep7em4l2hqvrd3uwtjm47u";

  # Keys that should always be able to access every secret, so they can be used 
  # to access and re-encrypt secrets.
  general = [ maddie-ditto ];
in
# Map each secret's `publicKeys` list to a new one that also includes `general`.
mapAttrs
  (_: secret: { publicKeys = secret.publicKeys ++ general; })
  secrets

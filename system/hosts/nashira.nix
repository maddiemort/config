{ config
, lib
, pkgs
, pkgsUnstable
, ...
}:

{
  age.secrets.ditto-license = {
    file = ../../secrets/ditto-license.age;
    owner = "maddie";
  };
  age.secrets.quay-email-ditto = {
    file = ../../secrets/quay-email-ditto.age;
    owner = "maddie";
  };
  age.secrets.quay-token-ditto = {
    file = ../../secrets/quay-token-ditto.age;
    owner = "maddie";
  };
  age.secrets.quay-user-ditto = {
    file = ../../secrets/quay-user-ditto.age;
    owner = "maddie";
  };

  environment = {
    extraInit = ''
      export DITTO_LICENSE="$(cat ${config.age.secrets.ditto-license.path})"
      export QUAY_EMAIL="$(cat ${config.age.secrets.quay-email-ditto.path})"
      export QUAY_TOKEN="$(cat ${config.age.secrets.quay-token-ditto.path})"
      export QUAY_USER="$(cat ${config.age.secrets.quay-user-ditto.path})"

      ulimit -n unlimited
    '';

    systemPackages = (with pkgs; [
      # ninja
      # swig
      tlaplus18
    ]) ++ (with pkgsUnstable; [
      cachix
      carapace
    ]);

    systemPath = [
      "/opt/jetbrains-toolbox"
    ];
  };

  homebrew = {
    brews = [
      # "ios-deploy"
      # "libimobiledevice"
      "swiftlint"
    ];

    casks = [
      "cool-retro-term"
      # "insomnia"
      "docker"
      "jetbrains-toolbox"
      "loom"
      "notion"
      "obs"
      # "slack" # installed automatically by Pixel
      "tla+-toolbox"
      # "zoom" # installed automatically by Pixel
      "zulip"
    ];
  };

  system.stateVersion = 5;
}

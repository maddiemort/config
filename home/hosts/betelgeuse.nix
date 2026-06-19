{
  pkgs,
  pkgsUnstable,
  ...
}: {
  imports = [
    ../non-work.nix
  ];

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

    packages =
      (with pkgs; [
        jdk17
        lagrange
      ])
      ++ (with pkgsUnstable; [
        prismlauncher
        thorium-reader

        (python314.withPackages (pyPkgs:
          with pyPkgs; [
            beancount
            fava
            pygments
            # pymobiledevice3
            python-lsp-black
            python-lsp-server
          ]))
      ]);

    sessionVariables = {
      JRE8 = "${pkgs.jre8}";
    };

    stateVersion = "22.11";
  };

  xdg.configFile."jj/conf.d/20-betelgeuse.toml".text = ''
    [signing]
    key = "~/.ssh/id_ed25519_jj_wtf.pub"
  '';

  custom = {
    auth = {
      publicKeys = {
        "*" = [
          "~/.ssh/id_ed25519_sk_maddie_wtf_c"
          "~/.ssh/id_ed25519_sk_maddie_wtf"
        ];
      };
    };

    git = {
      user = {
        signingKey = "~/.ssh/id_ed25519_sk_maddie_wtf_c";
      };
    };
  };
}

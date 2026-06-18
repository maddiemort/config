{pkgsUnstable, ...}: {
  home.packages = with pkgsUnstable; [
    jujutsu
    pdfpc
    polylux2pdfpc
    rustup
  ];

  xdg.configFile."jj/conf.d/30-non-work.toml".text = ''
  '';
}

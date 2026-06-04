{pkgsUnstable, ...}: {
  home.packages = with pkgsUnstable; [
    pdfpc
    polylux2pdfpc
  ];

  xdg.configFile."jj/conf.d/30-non-work.toml".text = ''
  '';
}

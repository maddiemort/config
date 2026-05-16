{pkgsUnstable, ...}: {
  home.packages = with pkgsUnstable; [
    pdfpc
    polylux2pdfpc
    unison-ucm
  ];

  xdg.configFile."jj/conf.d/30-non-work.toml".text = ''
  '';
}

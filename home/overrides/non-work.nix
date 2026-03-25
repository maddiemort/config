{...}: {
  xdg.configFile."jj/conf.d/30-non-work.toml".text = ''
    [[--scope]]
    --when.repositories = ["~/src/github.com/maddiemort"]

    [--scope.remotes.origin]
    auto-track-bookmarks = "*"
  '';
}

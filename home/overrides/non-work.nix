{...}: {
  xdg.configFile."jj/conf.d/30-non-work.toml".text = ''
    [ui]
    diff-formatter = ":git"
    pager = "less"

    [[--scope]]
    --when.repositories = ["~/src/github.com/maddiemort"]

    [--scope.remotes.origin]
    auto-track-bookmarks = "*"
  '';
}

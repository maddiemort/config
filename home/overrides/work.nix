{...}: {
  xdg.configFile."jj/conf.d/40-ditto.toml".text = ''
    [ui]
    diff.format = "git"

    [[--scope]]
    --when.repositories = ["~/src/github.com/getditto"]

    [--scope.user]
    email = "maddie@ditto.com"
  '';
}

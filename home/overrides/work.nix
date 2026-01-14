{...}: {
  xdg.configFile."jj/conf.d/40-ditto.toml".text = ''
    [[--scope]]
    --when.repositories = ["~/src/github.com/getditto"]

    [--scope.user]
    email = "maddie@ditto.com"

    [--scope.templates]
    git_push_bookmark = '"mm/push-" ++ change_id.short()'
  '';
}

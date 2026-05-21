{
  pkgs,
  lib,
  ...
}:
{
  # The home.stateVersion option does not have a default and must be set
  home.stateVersion = "25.11";
  home.packages = with pkgs; [ fastfetch ];

  #  # "home-manager does not exist" fix
  #  programs.home-manager.enable = true;

  # Programs

  programs.yazi = {
    enable = true;
    plugins = {
      mount = pkgs.yaziPlugins.mount;
      ouch = pkgs.yaziPlugins.ouch;
      recycle-bin = pkgs.yaziPlugins.recycle-bin;
    };
    keymap = {
      mgr.prepend_keymap = [
        {
          on = "C";
          run = "plugin ouch";
          desc = "Compress with ouch";
        }
      ];
    };
    settings = {
      opener = {
        play = [
          {
            run = "mpv \"$@\"";
            orphan = true;
            for = "unix";
          }
        ];
        edit = [
          {
            run = "nvim \"$@\"";
            block = true;
            for = "unix";
          }
        ];
        open = [
          {
            run = "xdg-open \"$@\"";
            desc = "Open";
          }
        ];
        extract = [
          {
            run = "ouch d -y \"$@\"";
            desc = "Extract here with ouch";
            for = "unix";
          }
        ];
      };
    };
  };
}

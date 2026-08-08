{
  config,
  pkgs,
  inputs,
  system,
  ...
}: {
  home.username = "sak";
  home.homeDirectory = "/home/sak";
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11";
  home.packages =
    [
      (pkgs.gitu.overrideAttrs (oldAttrs: {
        doCheck = false;
      }))
    ]
    ++ (with pkgs; [
      inputs.neovim.packages.${system}.default
      fd
      feh
      fzf
      direnv
      #gitu
      jq
      ripgrep
      tree
    ]);
  # # It is sometimes useful to fine-tune packages, for example, by applying
  # # overrides. You can do that directly here, just don't forget the
  # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
  # # fonts?
  # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
  # # You can also create simple shell scripts directly inside your
  # # configuration. For example, this adds a command 'my-hello' to your
  # # environment:
  # (pkgs.writeShellScriptBin "my-hello" ''
  #   echo "Hello, ${config.home.username}!"
  # '')
  programs.home-manager.enable = true;
}

{
  config,
  pkgs,
  ...
}: let
  stdenv = pkgs.stdenv;
  getTool = path: (builtins.getFlake path).packages.${pkgs.stdenv.hostPlatform.system}.default;
  nixpackPath = "${config.home.homeDirectory}/nixpack";
in {
  imports = [
    ./programs.nix
  ];
  home.username = "sak";
  home.homeDirectory =
    if stdenv.isDarwin
    then "/Users/sak"
    else "/home/sak";
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11";
  home.packages =
    [
      (pkgs.gitu.overrideAttrs (oldAttrs: {
        doCheck = false;
      }))
      (getTool "${nixpackPath}/neovim")
      (getTool "${nixpackPath}/zellij")
    ]
    ++ (with pkgs; [
      btop
      fastfetch
      fd
      feh
      fzf
      #gitu
      jq
      ripgrep
      tree
    ])
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
    ++ (pkgs.lib.optionals stdenv.isLinux (with pkgs; [
      pavucontrol
      lemonbar
      rofi
      unzip
      xclip
      xfce4-screenshooter
      mlterm
    ]))
    ++ (pkgs.lib.optionals stdenv.isDarwin (with pkgs; [
      #iterm2
    ]));
  home.file = {
    ".p10k.zsh".source = ./.p10k.zsh;
  };
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  programs.home-manager.enable = true;
}

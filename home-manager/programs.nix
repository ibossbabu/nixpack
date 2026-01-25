{
  pkgs,
  config,
  ...
}: let 
   stdenv = pkgs.stdenv;
   in{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
  programs.zsh = {
    enable = true;
    shellAliases = {
      vim = "nvim";
      zj = "zellij";
      ls = "ls --color=auto";
    };
    history = {
      size = 6666;
      save = 6666;
      path = "${config.home.homeDirectory}/.histfile";
    };
    initContent = pkgs.lib.mkBefore ''
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      export EDITOR=nvim
      export VISUAL=nvim
      export PATH="$HOME/.local/bin:$PATH"

      bindkey -v

      # Zinit Setup
      ZINIT_HOME="''${XDG_DATA_HOME:-''${HOME}/.local/share}/zinit/zinit.git"
      [ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
      [ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
      source "''${ZINIT_HOME}/zinit.zsh"

      zinit light zsh-users/zsh-autosuggestions
      zinit ice depth=1; zinit light romkatv/powerlevel10k
      zinit snippet OMZ::plugins/git/git.plugin.zsh

      # Powerlevel10k Config
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      zinit load zsh-users/zsh-syntax-highlighting

      # Machine-specific adjustments
      ${
        if stdenv.isDarwin
        then ''
          # for Mac
        ''
        else ''
          # for linux
        ''
      }
    '';
  };
}

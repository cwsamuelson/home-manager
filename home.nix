{ config, pkgs, ... }:
 
# https://www.atlassian.com/git/tutorials/dotfiles
# https://nix-community.github.io/home-manager/options.xhtml
{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  fonts.fontconfig.enable = true;

  home.username = "chris";
  home.homeDirectory = "/home/chris";
 
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
 
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # fundamental
    direnv
 
    firefox

    curl
 
    # development
    gitkraken
    jetbrains.clion

    devbox

    ccache
 
    # radiance projects
    awscli2
    ssm-session-manager-plugin

    #open-vm-tools# this doesn't seem to work...
    #open-vm-tools-desktop# this doesn't seem to work...
  ];
 
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
 
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };
 
  # environment variables
  # will only apply to enabled shells
  # programs.bash.enable = true;
  home.sessionVariables = {
    CONAN_TOKEN="";
    CONAN_USER="csamuelson.external";
    CONAN_REVISIONS_ENABLED=1;
  };
 
  home.shellAliases = {
    switch = "home-manager switch";
    ls = "ls -lha --color=auto";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.xplr = {
    enable = true;
  };

  # doesn't seem to work correctly on ubuntu
  #programs.kitty = {
  #  enable = true;
  #  shellIntegration.enableZshIntegration = true;#programs.zsh.enable;
  #  shellIntegration.enableBashIntegration = false;#programs.bash.enable;
  #};
 
  programs.zsh = {
    enable = true;
    #enableAutosuggestions.enable = true;
    syntaxHighlighting.enable = true;
 
    history = {
      ignoreAllDups = true;
      ignoreSpace = true;
    };
 
    oh-my-zsh = {
      enable = true;
 
      plugins = [
        "git"
        "history"
      ];
    };
  };
 
  programs.bash = {
    enable = true;
 
    # ignoreboth = ignorespace and ignoredups
    # ignorespace will not log to history any command with a leading space
    historyControl = [
      "ignorespace"
      "ignoredups"
    ];
 
    # manual additions to bashrc
    initExtra = ''
      # setup prompt
 
      # https://bash-prompt-generator.org/
      # basic prompt
      #PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
 
      GIT_PROMPT_FILE_NIXOS="/run/current-system/sw/share/bash-completion/completions/git-prompt.sh"
      GIT_PROMPT_FILE_NIX="$HOME/.nix-profile/share/git/contrib/completion/git-prompt.sh"
 
      if [[ -f "$GIT_PROMPT_FILE_NIXOS" ]]; then
        source "$GIT_PROMPT_FILE_NIXOS"
      elif [[ -f "$GIT_PROMPT_FILE_NIX" ]]; then
        source "$GIT_PROMPT_FILE_NIX"
      fi
 
      update_prompt() {
        PS1='\[\e[92m\]\u\[\e[0m\]@\[\e[92m\]\H\[\e[0m\]:\[\e[38;5;37m\]\w\[\e[0m\]'
 
        if [[ $(command -v __git_ps1) ]]; then
          PS1_CMD1=$(__git_ps1 " (%s)")
          PS1+="\[\e[38;5;247m\]''${PS1_CMD1}\[\e[0m\]"
 
          if [ -n "$DIRENV_DIR" ]; then
            PS1+="% " # % for direnv directories
          else
            PS1+="\\$ " # $ for non-direnv directories
          fi
        fi
      }
 
      PROMPT_COMMAND='update_prompt'

      cheatsh() {
        curl cheat.sh/$1
      }
 
      # setup direnv
      eval "$(direnv hook bash)"
    '';
  };
 
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
 
  programs.git = {
    enable = true;
    userName = "Chris Samuelson";
    userEmail = "christopher.samuelson@radiancetech.com";
 
    aliases = {
      co = "checkout";
    };
 
    difftastic = {
      enable = true;
      background = "dark";
      color = "auto";
      display = "side-by-side";
    };
 
    ignores = [
    ];
 
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
 
  programs.vim = {
    enable = true;###
    defaultEditor = true;
 
    settings = {
      expandtab = true;
      number = true;
      relativenumber = true;
      tabstop = 2;
      shiftwidth = 2;
      mouse = "a";
    };
 
    extraConfig = ''
      set scrolloff=8
    '';
  };
 
  programs.neovim = {
    enable = false;###
    defaultEditor = true;
    vimAlias = true;
  };
 
  # might be interested in using chezmoi and age?
  # doesn't look like they're directly supported by home manager, may require additional channels or finagling
}
 

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
    firefox
    gitkraken
    jetbrains-toolbox

    curl
    fd
    bat
    most
    # I think ov might be too much of a pain in the ass...but it works for now
    ov
    # markdown
    # ov --section-delimiter "^#" --section-header README.md
    # top
    # top -b -c -w512|ov --column-delimiter "/\s+/" --section-delimiter "^top" --column-mode --column-rainbow --follow-section -w=false
 
    direnv
    devbox
  ];
 
  home.file = {
    # ".screenrc".source = dotfiles/screenrc;
    ".inputrc".source = dotfiles/inputrc;
  };
 
  home.sessionVariables = {
    CONAN_REVISIONS_ENABLED=1;
    BAT_PAGER="ov -F H3";
    MANPAGER="ov --section-delimiter '^[^\s]' --section-header";
  };
 
  # color=always can cause problems sometimes :(
  # piping to commands and files will include the command characters
  # my usage of these commands doesn't typically run into that problem
  home.shellAliases = {
    switch = "home-manager switch";
    # -l list vertically, with add metadata
    # -h human readable file sizes
    # -A 'all', but excluding '.' and '..'
    ls = "ls -lhA --color=always";
    # -I skip binary files
    # -n include line numbers
    # -r recursive
    # -i case insensitive
    grep = "grep -Ini --color=always";
    oops = "sudo $(history -p !!)";
    cat = "bat --wrap=never";
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
      "erasedups"
    ];

    shellOptions = [
        "-histappend"
        "histverify"
        "autocd"
        "checkjobs"
        "checkwinsize"
        "extglob"
        "globstar"
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
 
      # manage history
      function merge_history() {
        history -n; history -w; history -c; history -r;
      }
      PROMPT_COMMAND='history -a;update_prompt'

      set -o vi +o emacs

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

    defaultCommand = "fd --type f";
  };
 
  programs.git = {
    enable = true;
    userName = "Chris Samuelson";
    userEmail = "chris.sam55@gmail.com";
 
    aliases = {
      uncommit = "reset --soft HEAD^";
      discard = "reset HEAD --hard";

      # this diff-intent style makes commands discoverable by autocomplete, and more organized
      # <command>-<intent>
      diff-all = "!\"for name in $(git diff --name-only $1); do git difftool -y $1 $name & done\"";
      diff-changed = "diff --name-status -r";
      diff-stat = "diff --stat --ignore-space-change -r";
      diff-staged = "diff --cached";
      diff-upstream = "!git fetch origin && git diff main origin/main";
      diff-words = "diff --color-words='[^[:space:]]|([[:alnum:]]|UTF_8_GUARD)+'";
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

      core.pager = "ov -F";
      pager.diff = "ov --config $XDG_CONFIG_HOME/ov/config.yaml -F --section-delimiter '^diff' --section-header";
      pager.log = "ov --config $XDG_CONFIG_HOME/ov/config.yaml -F --section-delimiter '^commit' --section-header-num 3";
      pager.show = "ov --config $XDG_CONFIG_HOME/ov/config.yaml -F --header 3";

      grep.lineNumber = "true";
      grep.fullName = "true";
    };
  };
 
  programs.vim = {
    enable = false;
    defaultEditor = true;
 
    settings = {
      expandtab = true;
      number = true;
      relativenumber = true;
      tabstop = 2;
      shiftwidth = 2;
      mouse = "a";
      ignorecase = true;
      smartcase = true;
    };
 
    extraConfig = ''
      set nocompatible
      set scrolloff=8
    '';
  };
 
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;

    extraConfig = ''
      set nocompatible
      set mouse=a
      set expandtab
      set tabstop=2
      set shiftwidth=2

      set number
      set relativenumber

      set scrolloff=8

      set ignorecase
      set smartcase

      colorscheme torte
    '';

  };

  # might be interested in using chezmoi and age?
  # doesn't look like they're directly supported by home manager, may require additional channels or finagling

  # ccache
  # cachix
  # clip
  #   cliphist
  #   clipman
  #   clipmenu
  # fonts
  #   powerline/nerdfont
  #   https://github.com/belluzj/fantasque-sans
  # tldr help reader
  #   https://github.com/dbrgn/tealdeer
  #   https://github.com/tldr-pages/tldr
  #   https://github.com/cheat/cheat
  #   https://github.com/denisidoro/navi
  #   https://github.com/gnebbia/kb
  #   https://github.com/srsudar/eg
  # tmux
  #   sessionizer? https://github.com/jrmoulton/tmux-sessionizer?tab=readme-ov-file
  # gdb dashboard
  #   https://github.com/cyrus-and/gdb-dashboard

  # tools:
  # https://devhints.io/bash
  # https://bash-prompt-generator.org/
  # https://nix-community.github.io/home-manager/options.xhtml
  # https://devhints.io/
}
 

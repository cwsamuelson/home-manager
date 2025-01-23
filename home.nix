{ config, pkgs, nixgl, ... }:
 
# https://www.atlassian.com/git/tutorials/dotfiles
# https://nix-community.github.io/home-manager/options.xhtml
{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  fonts.fontconfig.enable = true;

  home = {
    username = "chris";
    homeDirectory = "/home/chris";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "23.11"; # Please read the comment before changing.
   
    # The packages option allows you to install Nix packages into your
    # environment.
    packages = with pkgs; [
      firefox
      gitkraken
      jetbrains-toolbox
      stdman
      obsidian

      curl
      fd
      # delta?
      # https://github.com/dandavison/delta
      bat
      most
      tree
   
      direnv
      devbox
    ];
 
    file = {
    # ".screenrc".source = dotfiles/screenrc;
      ".inputrc".source = dotfiles/inputrc;
    };
   
    sessionVariables = {
      CONAN_REVISIONS_ENABLED=1;
      CONAN_TOKEN="cmVmdGtuOjAxOjE3NjMxNDY5OTg6UE05Z0s3OXN6NGVMa3pxMWF2Rm4xUkNrWmpx";
      CONAN_USER="csamuelson.external";
      CONAN_PASSWORD="cmVmdGtuOjAxOjE3NjMxNDY5OTg6UE05Z0s3OXN6NGVMa3pxMWF2Rm4xUkNrWmpx";
      CONAN_LOGIN_USERNAME="csamuelson.external";
    };
   
    # color=always can cause problems sometimes :(
    # piping to commands and files will include the command characters
    # my usage of these commands doesn't typically run into that problem
    shellAliases = {
      # search on path
      # how to accept arguments?
      # name = "find ${PATH//:/\/ } -iname 'search term'
      # create variation of search using arbitrary var?
      # search as array:
      # name = "find \"${array[@]}\" -iname "$file"

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
      docker-clean = "docker system df && docker container prune -f && docker image prune -f && docker builder prune -f && docker volume prune -a -f && docker system df";
      podman-clean = "podman system df && podman container prune -f -a && podman image prune -f && podman builder prune -f && podman volume prune -f && podman system df";
    };
  };

  nixGL.packages = nixgl.packages;
 
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    xplr.enable = true;

    # doesn't seem to work correctly on ubuntu
    kitty = {
      package = config.lib.nixGL.wrap pkgs.kitty;
      enable = true;
      shellIntegration.enableZshIntegration = true;#programs.zsh.enable;
      shellIntegration.enableBashIntegration = false;#programs.bash.enable;

      font = {
        name = "DejaVuSansMono";
        size = 18;
      };
    };

    zsh = {
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
 
    bash = {
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
        function highlight() {
          egrep --color=always "''${1}|$" $2
        }

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
          curl -s cheat.sh/$1 | cat
        }

        # https://gist.github.com/daytonn/8677243
        # Colors
        end="\033[0m"
        black="\033[0;30m"
        blackb="\033[1;30m"
        white="\033[0;37m"
        whiteb="\033[1;37m"
        red="\033[0;31m"
        redb="\033[1;31m"
        green="\033[0;32m"
        greenb="\033[1;32m"
        yellow="\033[0;33m"
        yellowb="\033[1;33m"
        blue="\033[0;34m"
        blueb="\033[1;34m"
        purple="\033[0;35m"
        purpleb="\033[1;35m"
        lightblue="\033[0;36m"
        lightblueb="\033[1;36m"

        function black {
          echo -e "''${black}''${1}''${end}"
        }

        function blackb {
          echo -e "''${blackb}''${1}''${end}"
        }

        function white {
          echo -e "''${white}''${1}''${end}"
        }

        function whiteb {
          echo -e "''${whiteb}''${1}''${end}"
        }

        function red {
          echo -e "''${red}''${1}''${end}"
        }

        function redb {
          echo -e "''${redb}''${1}''${end}"
        }

        function green {
          echo -e "''${green}''${1}''${end}"
        }

        function greenb {
          echo -e "''${greenb}''${1}''${end}"
        }

        function yellow {
          echo -e "''${yellow}''${1}''${end}"
        }

        function yellowb {
          echo -e "''${yellowb}''${1}''${end}"
        }

        function blue {
          echo -e "''${blue}''${1}''${end}"
        }

        function blueb {
          echo -e "''${blueb}''${1}''${end}"
        }

        function purple {
          echo -e "''${purple}''${1}''${end}"
        }

        function purpleb {
          echo -e "''${purpleb}''${1}''${end}"
        }

        function lightblue {
          echo -e "''${lightblue}''${1}''${end}"
        }

        function lightblueb {
          echo -e "''${lightblueb}''${1}''${end}"
        }

        function colors {
          black "black"
          blackb "blackb"
          white "white"
          whiteb "whiteb"
          red "red"
          redb "redb"
          green "green"
          greenb "greenb"
          yellow "yellow"
          yellowb "yellowb"
          blue "blue"
          blueb "blueb"
          purple "purple"
          purpleb "purpleb"
          lightblue "lightblue"
          lightblueb "lightblueb"
        }

        function colortest {
          # The test text
          if [[ ! -z "$1" ]]; then
            T="$1"
          else
            T='gYw'
          fi

          echo -e "\n                 40m     41m     42m     43m\
               44m     45m     46m     47m";

          for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
                     '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
                     '  36m' '1;36m' '  37m' '1;37m';
            do FG=''${FGs// /}
            echo -en " $FGs \033[$FG  $T  "
            for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
              do echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
            done
            echo;
          done
          echo
        }

        # this makes all the color functions and variables available to scripts
        # the functions are commented out because of a bug in devbox that clobbers the names and causes errors
        # https://github.com/jetify-com/devbox/issues/995
        #export -f colors
        #export -f colortest
        #export -f black
        #export -f blackb
        #export -f white
        #export -f whiteb
        #export -f red
        #export -f redb
        #export -f green
        #export -f greenb
        #export -f yellow
        #export -f yellowb
        #export -f blue
        #export -f blueb
        #export -f purple
        #export -f purpleb
        #export -f lightblue
        #export -f lightblueb
        export black
        export blackb
        export white
        export whiteb
        export red
        export redb
        export green
        export greenb
        export yellow
        export yellowb
        export blue
        export blueb
        export purple
        export purpleb
        export lightblue
        export lightblueb
        export end
 
        # setup direnv
        eval "$(direnv hook bash)"
      '';
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;

      defaultCommand = "fd --type f";
    };
 
    git = {
      enable = true;
      userName = "Chris Samuelson";
      userEmail = "christopher.samuelson@radiancetech.com";
 
      aliases = {
        co = "checkout";
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
   
      ignores = [];
   
      extraConfig = {
        init.defaultBranch = "main";

        grep.lineNumber = "true";
        grep.fullName = "true";
      };
    };
 
    vim = {
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

    neovim = {
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
  };
}
 

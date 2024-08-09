# nix setup

## we need curl to install nix
apt install curl

### https://nixos.wiki/wiki/Nix_Installation_Guide
## install nix
sh <(curl -L https://nixos.org/nix/install) --daemon --yes

## remove packages that will conflict in nix
snap remove --purge firefox
apt purge curl git firefox -y
apt autoremove

## if running a script, we need to source the profile to get nix commands
source /etc/profile

## https://nixos.org/manual/nix/stable/installation/upgrading
## synchronize the version in nix and home manager
nix-channel --add https://github.com/nixos/nixpkgs/archive/nixos-23.11.tar.gz nixpkgs

## https://nix-community.github.io/home-manager/#sec-install-standalone
## add channel for home manager
nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager

## apply previous channel additions
nix-channel --update

## install home manager
nix-shell '<home-manager>' -A install

# Direnv
### https://direnv.net/docs/hook.html
## add bashrc for direnv
eval "$(direnv hook bash)"

# Option2
- sudo apt install curl -y && sh <(curl -L https://nixos.org/nix/install) --daemon --yes
- mv ~/.bashrc ~/.bashrc.backup && mv ~/.profile ~/.profile.backup && nix --extra-experimental-features 'nix-command flakes' run github:cwsamuelson/home-manager/main#homeConfigurations."chris".activationPackage

Note: the above command will likely not work for this repo, because it is private.  To circumvent this, try this alternative command, after logging in or setting up ssh keys

nix --extra-experimental-features 'nix-command flakes' run github:cwsamuelson/home-manager/main#homeConfigurations."$USER".activationPackage



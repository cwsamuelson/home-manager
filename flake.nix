{
  description = "things and stuff";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11"; # Stable 23.11
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # Unstable

    home-manager = {
      # url = "github:nix-community/home-manager/release-23.11"; # Stable 23.11
      url = "github:nix-community/home-manager"; # Unstable
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;

    security.chromiumSuidSandbox.enable = true;

    homeConfigurations = {
      "chris" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };

        modules = [ ./home.nix ];
      };
    };
  };
}


{
  description = "things and stuff";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      # url = "github:nix-community/home-manager"; # Unstable
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl.url = "github:nix-community/nixGL";
  };

  outputs = { nixpkgs, home-manager, nixgl, ... }: {
    defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;

    security.chromiumSuidSandbox.enable = true;

    homeConfigurations = {
      "chris" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = { inherit nixgl; };
        pkgs = import nixpkgs {
          system =  "x86_64-linux";
          overlays = [ nixgl.overlay ];
        };
        modules = [ ./home.nix ];
      };
    };
  };
}


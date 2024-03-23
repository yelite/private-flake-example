{
  description = "The public flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
  }: {
    nixosModules.default = {pkgs, ...}: {
      imports = [
        home-manager.nixosModules.default
      ];

      config = let
        username = "example";
      in {
        home-manager = {
          users.${username} = {};
          useGlobalPkgs = true;
          sharedModules = [
            ({pkgs, ...}: {
              home.packages = [
                pkgs.neovim
              ];
            })
          ];
        };

        users.users.${username} = {
          isNormalUser = true;
          shell = pkgs.fish;
          extraGroups = ["wheel"];
        };
      };
    };

    nixosConfigurations = {
      example = nixpkgs.lib.nixosSystem {
        modules = [
          self.nixosModules.default
          {
            nixpkgs.hostPlatform = "x86_64-linux";
          }
        ];
      };
    };
  };
}

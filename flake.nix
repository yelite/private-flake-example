{
  description = "The private flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {nixpkgs, ...}: let
    # evaluate the public flake directly, without having it in flake inputs.
    publicOutputs = (import ./public/flake.nix).outputs (inputs // {self = publicFlake;});
    publicFlake =
      publicOutputs
      // {
        inherit inputs;
        outputs = publicOutputs;
        outPath = ./public;
        _type = "flake";
      };
  in
    # we need to ensure that the two flakes have same inputs, because they share the same lock file
    assert (import ./public/flake.nix).inputs == (import ./flake.nix).inputs; {
      nixosConfigurations =
        # inherits all nixos config from the public flake
        publicFlake.nixosConfigurations
        // {
          example-private = nixpkgs.lib.nixosSystem {
            modules = [
              # use the nixos module exported by the public flake
              publicFlake.nixosModules.default
              # combined with sensitive config
              {
                services.openssh.ports = [12345];
                nixpkgs.hostPlatform = "x86_64-linux";
              }
            ];
          };
        };
    };
}

{
  description = "NixOS-on-Lima configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-lima = {
      url = "github:nixos-lima/nixos-lima/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-lima, home-manager, ... }@inputs:
    let
      system = "aarch64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            unstablePkgs = nixpkgs-unstable.legacyPackages.${system};
          };
          modules = [
            nixos-lima.nixosModules.lima
            ./nixos-lima-config.nix
          ];
        };

        # You'll need to change the configuration name to match the username
        # that Lima automatically creates (same as your host username)
        homeConfigurations."lima" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [
            {
               home.username = "lima";
               home.homeDirectory = "/home/lima.guest";
               home.stateVersion = "26.05";
               programs.git.settings.user.email = "lima@nowaythisdomainexistsreally.com";
               programs.git.settings.user.name  = "Lima User";
            }
            ./home.nix
          ];

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
        };
    };
}

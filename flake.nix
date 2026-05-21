{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # caelestia-shell = {
    #   url = "github:caelestia-dots/shell";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    home-manager = {
      # Follow corresponding `release` branch from Home Manager
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    slippi = {
      url = "github:lytedev/slippi-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # upbge = {
    #   url = "github:zzephyr01/upbge-flake";
    # };
    # windscribe-bin = {
    #   url = "github:itzderock/windscribe-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nvf,
      slippi,
      # windscribe-bin,
      ...
    }:
    {
      packages."x86_64-linux".default =
        (nvf.lib.neovimConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [ ./mike-nvf-config.nix ];
        }).neovim;
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs.inputs = inputs;
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          inputs.dms.nixosModules.dank-material-shell
          inputs.nvf.nixosModules.default
          slippi.nixosModules.default # optional: GameCube adapter optimization
          {
            environment.systemPackages = [
              slippi.packages.x86_64-linux.default
            ];
          }
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
              };
              users.zeph = {
                imports = [ ./home.nix ];
              };
            };
          }
        ];
      };
    };
}

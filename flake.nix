{
  nixConfig = {
    extra-substituters = ["https://nix-community.cachix.org"];
    extra-trusted-public-keys = [
      nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
    ];
  };
  description = "Description for the project brrrt";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";

    nil.url = "github:oxalica/nil";
    devshell.url = "github:numtide/devshell";
    neovim-flake.url = "github:nix-community/neovim-nightly-overlay";
    alejandra.url = "github:kamadorueda/alejandra";
  };

  outputs = inputs @ {
    flake-parts,
    systems,
    rust-overlay,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [./parts/flake-module.nix];

      systems = import systems;
    };
}

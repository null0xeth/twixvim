{
  nixConfig = {
	extra-substituters = [ "https://nix-community.cachix.org" ];
	extra-trusted-public-keys = [
	nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
	];
  };
  description = "Description for the project brrrt";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    nil.url = "github:oxalica/nil";
    devshell.url = "github:numtide/devshell";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    neovim-flake.url = "github:nix-community/neovim-nightly-overlay";
    #neovim-flake.url = "github:neovim/neovim?dir=contrib";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
  };

  outputs = inputs @ {
    flake-parts,
    systems,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [./parts/flake-module.nix];

      systems = import systems;
    };
}

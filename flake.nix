{
  description = "Darren's personal nix packages";

  nixConfig = {
    # If you use Cachix, add it here so consumers auto-use your cache
    # extra-substituters = [ "https://darren-nix-pkgs.cachix.org" ];
    # extra-trusted-public-keys = [
    #   "darren-nix-pkgs.cachix.org-1:REPLACE_WITH_YOUR_KEY"
    # ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    naersk.url = "github:nix-community/naersk";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      naersk,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { system, ... }:
        let
          pkgs = import nixpkgs { inherit system; };
          naerskLib = naersk.lib.${system};
          # helper to import a package derivation from pkgs/<name>/package.nix
          mk =
            name:
            import (./pkgs + "/${name}/package.nix") {
              inherit pkgs naerskLib system;
              src = ./pkgs + "/${name}";
            };
        in
        {
          packages = {
            # expose all packages here
            git-init = mk "git-init";
            gloc = mk "gloc";

            # handy default
            default = self.packages.${system}.git-init;
          };

          # Overlay so consumers can do: pkgs.git-init / pkgs.gloc
          overlays.default = final: prev: {
            git-init = self.packages.${system}.git-init;
            gloc = self.packages.${system}.gloc;
          };

          # Dev shell for building Rust stuff
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              rustc
              cargo
              clippy
              rustfmt
            ];
          };

          # Optional: apps (nix run .#git-init)
          apps.git-init = {
            type = "app";
            program = "${self.packages.${system}.git-init}/bin/git-init";
          };
          apps.default = self.apps.${system}.git-init;
        };
    };
}

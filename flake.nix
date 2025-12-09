{
  description = "Darren's personal nix packages";

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
          mk =
            name:
            import ./pkgs/${name}/package.nix {
              inherit pkgs naerskLib system;
              src = ./pkgs/${name};
            };
        in
        {
          packages = {
            git-init = mk "git-init";
            gloc = mk "gloc";
            default = self.packages.${system}.git-init;
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              rustc
              cargo
              clippy
              rustfmt
            ];
          };

          apps.git-init = {
            type = "app";
            program = "${self.packages.${system}.git-init}/bin/git-init";
          };
          apps.default = self.apps.${system}.git-init;
        };

      # 👇 move overlay to global (not perSystem)
      flake.overlays.default = final: prev: {
        git-init = self.packages.${final.system}.git-init;
        gloc = self.packages.${final.system}.gloc;
      };
    };
}

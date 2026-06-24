{
  description = "Dev shell with steam-run";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.steam-run
          ];

          shellHook = ''
            alias godot="steam-run ./Godot_v4.7-stable_linux.x86_64"
          '';
        };
      }
    );
}

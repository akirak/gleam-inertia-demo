{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-gleam = {
      url = "github:arnarg/nix-gleam";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "";
    };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      nixpkgs,
      treefmt-nix,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      beamVersion = "beam28Packages";
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        treefmt-nix.flakeModule
      ];

      systems = lib.systems.flakeExposed;

      perSystem =
        { system, ... }:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend (
            _: _: {
              inherit (inputs.nix-gleam.packages.${system}) buildGleamApplication;
            }
          );

          # Use only Chrome for E2E during local development
          playwright-browsers = pkgs.playwright-driver.browsers.override {
            withFirefox = false;
            withWebkit = false;
            withFfmpeg = false;
            # fontconfig_file = { fontDirectories = []; };
          };

          browserProgram = if pkgs.stdenv.targetPlatform.isLinux then "chrome" else "Chromium";
        in
        {
          packages = {
            server = pkgs.callPackage ./gleam.nix {
              inherit (pkgs.${beamVersion}) erlang rebar3;
              src = lib.cleanSourceWith {
                src = self.outPath;
                filter = path: _: path != "src-inertia" && path != "docs";
              };
            };

            client = pkgs.callPackage ./assets.nix {
              src = lib.cleanSourceWith {
                src = self.outPath;
                filter = path: _: path != "priv" && path != "src";
              };
            };
          };

          treefmt.programs = {
            deadnix.enable = true;
            nixfmt.enable = true;
            zizmor.enable = true;
          };

          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.gleam
              pkgs.${beamVersion}.erlang
              pkgs.${beamVersion}.rebar3
              pkgs.nodejs
              pkgs.corepack
              pkgs.typescript-go
              pkgs.just
              playwright-browsers
            ]
            ++ lib.optional pkgs.stdenv.isLinux pkgs.inotify-tools
            ++ (lib.optionals pkgs.stdenv.isDarwin (
              with pkgs.darwin.apple_sdk.frameworks;
              [
                CoreFoundation
                CoreServices
              ]
            ));

            shellHook = ''
              browser_executable="$(find -L '${playwright-browsers}' -name ${browserProgram} -type f)"
              export PLAYWRIGHT_BROWSER_EXECUTABLE_PATH="''${browser_executable}"
              export PLAYWRIGHT_ONLY_CHROMIUM=1
            '';
          };

          checks = self.packages.${system};
        };
    };
}

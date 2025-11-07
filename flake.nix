{
  description = "Miryoku layout for Kanata - All variants programmatically generated";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    mission-control.url = "github:Platonic-Systems/mission-control";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, flake-root, mission-control }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        flake-root.flakeModule
        mission-control.flakeModule
      ];

      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { config, pkgs, system, ... }:
      let

        # Python script for generating configs
        generateConfigs = pkgs.writeShellScriptBin "generate-miryoku-configs" ''
          ${pkgs.python3}/bin/python3 ${./generate_configs.py}
        '';

        # Validation script with glob support
        validateConfigs = pkgs.writeShellScriptBin "validate-miryoku-configs" ''
          set -e

          # Usage message
          usage() {
            echo "Usage: validate-miryoku-configs [PATTERN]"
            echo ""
            echo "Validate Miryoku Kanata configuration files."
            echo ""
            echo "Arguments:"
            echo "  PATTERN    Optional glob pattern (default: miryoku-kanata*.kbd)"
            echo ""
            echo "Examples:"
            echo "  validate-miryoku-configs                      # Validate all configs"
            echo "  validate-miryoku-configs miryoku-kanata--nix.kbd   # Validate single file"
            echo "  validate-miryoku-configs 'miryoku-kanata-qwerty*.kbd'  # Validate QWERTY variants"
            echo "  validate-miryoku-configs 'miryoku-kanata-*--mac.kbd'   # Validate all macOS configs"
            exit 0
          }

          if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
            usage
          fi

          pattern="''${1:-miryoku-kanata*.kbd}"

          echo "Validating configurations matching: $pattern"
          echo ""

          total=0
          passed=0
          failed=0
          failed_files=()

          for config in $pattern; do
            if [ -f "$config" ]; then
              total=$((total + 1))
              echo -n "  Checking $config... "

              if ${pkgs.kanata}/bin/kanata --check --cfg "$config" 2>&1 | grep -q "config file is valid"; then
                echo "✓"
                passed=$((passed + 1))
              else
                echo "✗"
                failed=$((failed + 1))
                failed_files+=("$config")
              fi
            fi
          done

          echo ""
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          echo "Results: $passed/$total passed, $failed failed"

          if [ ''${#failed_files[@]} -gt 0 ]; then
            echo ""
            echo "Failed files:"
            for f in "''${failed_files[@]}"; do
              echo "  • $f"
            done
            exit 1
          else
            echo "All configurations valid! ✓"
            exit 0
          fi
        '';

        # Quick test script
        testConfig = pkgs.writeShellScriptBin "test-miryoku-config" ''
          if [ -z "$1" ]; then
            echo "Usage: test-miryoku-config <config-file>"
            echo "Example: test-miryoku-config miryoku-kanata--nix.kbd"
            exit 1
          fi

          if [ ! -f "$1" ]; then
            echo "Error: Config file '$1' not found"
            exit 1
          fi

          echo "Testing configuration: $1"
          ${pkgs.kanata}/bin/kanata --check --cfg "$1"
        '';

      in
      {
        # Mission Control scripts configuration
        mission-control.scripts = {
          generate = {
            description = "Generate all 135 Miryoku configurations";
            exec = generateConfigs;
          };
          validate = {
            description = "Validate Miryoku configurations (supports glob patterns)";
            exec = validateConfigs;
          };
          test = {
            description = "Test a specific Miryoku configuration file";
            exec = testConfig;
          };
        };

        # Development shell
        devShells.default = pkgs.mkShell {
          inputsFrom = [ config.mission-control.devShell ];

          buildInputs = with pkgs; [
            # Core tools
            kanata
            python3

            # Utilities
            repomix
            git

            # Custom scripts
            generateConfigs
            validateConfigs
            testConfig
          ];

          shellHook = ''
            echo "🎹 Miryoku Kanata Development Environment"
            echo ""
            echo "Available commands:"
            echo "  generate-miryoku-configs    Generate all 135 Miryoku configurations"
            echo "  validate-miryoku-configs    Validate all generated configs with Kanata"
            echo "  test-miryoku-config <file>  Test a specific config file"
            echo "  mission-control             View all available tasks"
            echo ""
            echo "Quick start:"
            echo "  1. generate-miryoku-configs"
            echo "  2. validate-miryoku-configs"
            echo "  3. kanata --cfg miryoku-kanata--nix.kbd"
            echo ""
          '';
        };

        # Packages
        packages = {
          # Generator script as a package
          generator = generateConfigs;

          # Validator script as a package
          validator = validateConfigs;

          # All configs as a single derivation
          configs = pkgs.stdenv.mkDerivation {
            name = "miryoku-kanata-configs";
            src = ./.;

            buildInputs = [ pkgs.python3 ];

            buildPhase = ''
              python3 generate_configs.py
            '';

            installPhase = ''
              mkdir -p $out/configs
              cp miryoku-kanata*.kbd $out/configs/

              mkdir -p $out/bin
              cat > $out/bin/list-configs <<EOF
              #!/bin/sh
              ls $out/configs/
              EOF
              chmod +x $out/bin/list-configs
            '';

            meta = {
              description = "Miryoku keyboard layout for Kanata - all variants";
              homepage = "https://github.com/manna-harbour/miryoku";
              license = pkgs.lib.licenses.gpl3;
            };
          };
        };

        # Default package
        packages.default = config.packages.configs;

        # Apps
        apps = {
          generate = {
            type = "app";
            program = "${generateConfigs}/bin/generate-miryoku-configs";
          };

          validate = {
            type = "app";
            program = "${validateConfigs}/bin/validate-miryoku-configs";
          };
        };

        # Checks (run with `nix flake check`)
        checks = {
          configs-valid = pkgs.stdenv.mkDerivation {
            name = "miryoku-configs-validation";
            src = ./.;

            buildInputs = [ pkgs.python3 pkgs.kanata ];

            buildPhase = ''
              python3 generate_configs.py

              echo "Validating generated configurations..."
              for config in miryoku-kanata*.kbd; do
                echo "Checking $config..."
                if kanata --check --cfg "$config" 2>&1 | grep -q "config file is valid"; then
                  echo "  ✓ Valid"
                else
                  echo "  ✗ Failed validation"
                  exit 1
                fi
              done
              echo "All configurations validated successfully!"
            '';

            installPhase = ''
              mkdir -p $out
              echo "All configs validated successfully" > $out/result
            '';
          };
        };
      };
    };
}

# Miryoku for Kanata

Complete, programmatically generated [Miryoku](https://github.com/manna-harbour/miryoku) keyboard layout configurations for [Kanata](https://github.com/jtroo/kanata).

## Features

- **135 complete configurations** covering all Miryoku variants
- **9 alpha layouts**: Colemak Mod-DH (default), QWERTY, Dvorak, Colemak, Colemak Mod-DHk, AZERTY, QWERTZ, Halmak, Workman
- **3 navigation variants**: Standard, Vi-style, Inverted-T
- **2 layer configurations**: Standard and Flipped
- **3 platform clipboards**: Linux/Unix, Windows, macOS
- **All 8 Miryoku layers** included in each config

## Quick Start

### Using Nix Flake (Recommended)

```bash
# Enter development environment
nix develop

# Using Mission Control commands (recommended):
, generate     # Generate all configurations
, validate     # Validate all configs
,              # Show all available commands

# Or use direct commands:
generate-miryoku-configs
validate-miryoku-configs

# Test a specific config
kanata --cfg miryoku-kanata--nix.kbd
```

### Manual Usage

```bash
# Generate configs
python3 generate_configs.py

# Test with Kanata
kanata --cfg miryoku-kanata--nix.kbd
```

## Configuration Naming

Format: `miryoku-kanata-<alpha>-<modifiers>--<platform>.kbd`

Where:
- `<alpha>`: Only specified if not default (Colemak Mod-DH)
- `<modifiers>`: `flip`, `vi`, `invertedt` (in order of importance)
- `<platform>`: `nix`, `win`, or `mac`

### Examples

```
miryoku-kanata--nix.kbd                    # Default: Colemak-DH, standard nav, Linux
miryoku-kanata-qwerty--win.kbd             # QWERTY, standard nav, Windows
miryoku-kanata-dvorak--mac.kbd             # Dvorak, standard nav, macOS
miryoku-kanata-vi--nix.kbd                 # Colemak-DH, vi nav, Linux
miryoku-kanata-flip-invertedt--nix.kbd     # Colemak-DH, flipped+inverted-T, Linux
miryoku-kanata-qwerty-flip--win.kbd        # QWERTY, flipped, Windows
```

## Layers

All configurations include:

- **U_BASE** - Your chosen alpha layout with home row mods
- **U_EXTRA** - QWERTY alternative (switchable via tap-dance)
- **U_TAP** - No dual-function keys version
- **U_NAV** - Navigation layer (with your chosen variant)
- **U_MOUSE** - Mouse emulation layer
- **U_BUTTON** - Clipboard/modifiers layer
- **U_MEDIA** - Media controls layer
- **U_NUM** - Number/numpad layer
- **U_SYM** - Symbol layer
- **U_FUN** - Function keys layer

## Development

### Nix Flake Commands

```bash
# Enter dev shell
nix develop

# Generate configs
nix run .#generate

# Validate configs
nix run .#validate

# Build all configs as a package
nix build

# Run checks (generates and validates)
nix flake check
```

### Available Scripts

#### Mission Control Commands (via `,`)

Inside the dev shell, use Mission Control's shorthand commands:

- `, generate` - Generate all 135 configurations
- `, validate [PATTERN]` - Validate configs with optional glob pattern
  - `, validate` - Validate all configs
  - `, validate "miryoku-kanata--nix.kbd"` - Validate single file
  - `, validate "miryoku-kanata-qwerty*.kbd"` - Validate QWERTY variants
  - `, validate "miryoku-kanata-*--mac.kbd"` - Validate all macOS configs
- `, test <file>` - Test a specific configuration file

Run `,` alone to display the Mission Control menu.

#### Direct Commands

- `generate-miryoku-configs` - Generate all 135 configurations
- `validate-miryoku-configs [PATTERN]` - Validate configs with optional glob pattern
- `test-miryoku-config <file>` - Test a specific configuration file

### Development Tools

The devShell includes:
- **Kanata** - Keyboard remapping tool
- **Mission Control** - Task management and process monitoring
- **Python 3** - For running the generator
- **Repomix** - Repository packing tool
- **Git** - Version control

## Platform Differences

### Linux/Unix (`--nix`)
- Undo: `Ctrl+Z`
- Redo: `Ctrl+Shift+Z`
- Cut/Copy/Paste: `Shift+Del`, `Ctrl+Ins`, `Shift+Ins`

### Windows (`--win`)
- Undo: `Ctrl+Z`
- Redo: `Ctrl+Y`
- Cut/Copy/Paste: `Shift+Del`, `Ctrl+Ins`, `Shift+Ins`

### macOS (`--mac`)
- Undo: `Cmd+Z`
- Redo: `Cmd+Shift+Z`
- Cut/Copy/Paste: `Cmd+X`, `Cmd+C`, `Cmd+V`

## References

- [Miryoku Official](https://github.com/manna-harbour/miryoku)
- [Kanata](https://github.com/jtroo/kanata)
- Based on [dinaldoap's Miryoku port](https://github.com/manna-harbour/miryoku_kmonad)

## License

Follows Miryoku's licensing (GPL-3.0).

## Contributing

This project is generated programmatically. To modify configurations:

1. Edit `generate_configs.py`
2. Run `, generate` (or `generate-miryoku-configs`)
3. Validate with `, validate` (or `validate-miryoku-configs`)

Mission Control (`,` command) provides a convenient interface for running all project tasks.

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Godot 4.4.1 game project implementing a unique Snake variant called "Path Following Snake Game." The player must follow a colored plasma-gradient path from their snake's head to food, adding a pathfinding puzzle element to the classic Snake gameplay.

## Development Commands

### Running the Game
```bash
# Run with Godot engine
godot --path .

# Or with full path to Godot executable
/path/to/Godot_v4.4.1-stable_linux.x86_64 --path /home/flwi/Coding/snake
```

### Building Executables
```bash
# Export for different platforms (requires export templates)
godot --headless --export-release "Windows Desktop" builds/windows/SimonSnakeGame.exe
godot --headless --export-release "Linux" builds/linux/SimonSnakeGame.x86_64
godot --headless --export-release "Web" builds/web/index.html
```

### Testing
```bash
# Run Godot unit tests
godot --headless --script test_runner.gd
```

## Architecture

### Core Game Structure
- **Main Scene**: `scenes/Main.tscn` - Entry point and UI container
- **Game Logic**: `scripts/GameBoard.gd` - Central game controller with all mechanics
- **Test Framework**: `test_runner.gd` orchestrates test suites in `test/` directory

### Key Systems

**Path Generation**: A* pathfinding algorithm generates routes from snake head to food, with plasma colormap visualization (blue → purple → red → yellow gradient)

**Game States**: Menu system with obstacle/speed selection, 5-second countdown before path appears, enforced path-following mechanics

**Visual Rendering**: Dynamic ColorRect-based rendering system for snake, food, obstacles, and path visualization with thick (3-cell) path width

**Input Handling**: Arrow keys + WASD for movement, anti-reversal logic, debounced direction changes (100ms), R for restart, ESC to quit

### Project Structure
- `scripts/GameBoard.gd` - Main game logic (575 lines)
- `scenes/Main.tscn` - Scene composition 
- `test/` - Unit test suites for game mechanics and pathfinding
- `builds/` - Export targets for Windows/Linux/Web
- `.github/workflows/build-godot.yml` - Automated CI/CD builds

## Development Notes

The game uses Godot's node system with ColorRect children for visual elements. All game state is centralized in GameBoard.gd. The pathfinding enforces gameplay constraints where stepping off the generated path ends the game.

Export configuration creates single-file executables with embedded .pck files for distribution. CI/CD automatically builds releases for all platforms on push to main branch.
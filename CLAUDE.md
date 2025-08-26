# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a "Path Following Snake Game" - a unique twist on classic Snake where the player must follow a generated colored path to reach food. The game has been converted from Python/pygame to Godot 4.4.1 and implements A* pathfinding for path generation.

**Note:** This project has been fully converted from pygame to Godot 4.4.1. All pygame files have been removed - the original pygame version is available in git history if needed.

## Development Commands

### Running the Game
```bash
# Run with your local Godot installation
/path/to/Godot_v4.4.1-stable_linux.x86_64 --path /home/flwi/Coding/snake

# Or if Godot is in PATH
godot --path .

# To run in the background/headless for testing
godot --headless --path .
```

### Testing
```bash
# Run the GDScript unit test suite
godot --headless --script test_runner.gd

# Or run specific test suites individually:
godot --headless --script test/test_game_mechanics.gd
godot --headless --script test/test_pathfinding.gd

# Run tests with visual output (for debugging)
godot --path . test_scene.tscn
```

### Building Executables
```bash
# Export using Godot (requires export templates)
godot --headless --export-release "Windows Desktop" builds/windows/SimonSnakeGame.exe
godot --headless --export-release "Linux" builds/linux/SimonSnakeGame.x86_64
godot --headless --export-release "Web" builds/web/index.html
```

### GitHub Actions CI/CD
The repository includes automated multi-platform Godot builds:

- **Workflow File**: `.github/workflows/build-godot.yml`
- **Triggers**: Push to main, PRs, releases, manual dispatch
- **Permissions**: Requires `contents: write` for creating releases
- **Output**: Multi-platform builds:
  - Windows executable (`SimonSnakeGame.exe`)
  - Linux executable (`SimonSnakeGame.x86_64`)
  - Web version (`index.html` + assets)
- **Distribution**: 
  - Artifacts available in Actions tab for all builds
  - Automatic "latest" release created/updated on each push to main
  - Manual releases get executables attached when created properly

**Note**: The workflow automatically downloads Godot 4.4.1 and export templates for consistent builds.

## Code Architecture

### Main Game Scene (Godot)
- **Main.tscn**: Root scene containing all game components
- **GameBoard.gd**: Main game logic script (converted from SnakeGame class)
- **Scene Structure**:
  - GameBoard (Node2D) - core game logic
  - PathRenderer (Node2D) - path visualization with plasma gradients
  - Snake (Node2D) - snake body segments
  - Food (ColorRect) - food item
  - Obstacles (Node2D) - obstacle placement
  - UI (CanvasLayer) - score, timer, and menu systems

### Core Game Mechanics
- **Path Following**: Snake must stay on generated path or game ends
- **Path Generation**: Uses A* algorithm, regenerated after each food collection
- **Plasma Path Coloring**: Blue (start) → Purple → Red → Yellow (end)
- **Obstacles**: Optional randomly placed gray squares
- **Speed Settings**: Slow/Medium/Fast with frame-based movement timing

### Key Data Structures
- `self.snake`: List of (x, y) tuples representing snake segments
- `self.path`: List of (x, y) tuples representing the path from snake to food
- `self.obstacles`: Set of (x, y) tuples for obstacle positions
- `self.food`: Single (x, y) tuple for food position

### Game Flow
1. Initial setup with obstacle/speed selection
2. 5-second delay before path generation
3. Path appears with plasma coloring
4. Snake must follow path to food
5. Path regenerates after food collection

## Dependencies

- **Godot 4.4.1**: Game engine and runtime
- **GDScript**: Primary programming language (built into Godot)


## File Structure

- `project.godot`: Godot project configuration
- `scenes/Main.tscn`: Main game scene
- `scripts/GameBoard.gd`: Main game logic
- `icon.svg`: Project icon
- `test_runner.gd`: Main test runner script
- `test_scene.tscn`: Test runner scene
- `test/test_game_mechanics.gd`: Core game mechanics unit tests
- `test/test_pathfinding.gd`: A* pathfinding algorithm tests
- `.github/workflows/build-godot.yml`: Godot build pipeline

## Testing Architecture

The project uses GDScript-based unit tests that run directly in the Godot engine:

- **test_runner.gd**: Orchestrates all test suites and provides summary output
- **test_scene.tscn**: Scene file for running tests with visual feedback
- **test/test_game_mechanics.gd**: Tests core gameplay (movement, collision, food generation, etc.)
- **test/test_pathfinding.gd**: Tests A* algorithm implementation and path validation

Tests cover:
- Game initialization and state management
- Snake movement and collision detection
- Food and obstacle generation
- A* pathfinding algorithm correctness
- Path validation and plasma color generation
- Performance benchmarks for pathfinding
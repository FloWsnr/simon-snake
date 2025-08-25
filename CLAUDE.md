# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Python-based "Path Following Snake Game" - a unique twist on classic Snake where the player must follow a generated colored path to reach food. The game uses pygame for graphics and implements A* pathfinding for path generation.

## Development Commands

### Running the Game
```bash
# Activate the conda environment (if using conda)
conda activate simon-snake

# Run the main game
python snake_game.py
```

### Testing
```bash
# Run the basic game test (uses dummy video driver)
python test_game.py
```

### Building Executable
```bash
# Install pyinstaller if not already installed
pip install pyinstaller

# Create standalone executable
pyinstaller --onefile snake_game.py

# Create standalone executable without console window
pyinstaller --onefile --windowed snake_game.py

# Or use the existing spec file
pyinstaller snake_game.spec
```

### GitHub Actions CI/CD
The repository includes automated Windows executable builds:

- **Workflow File**: `.github/workflows/build-windows.yml`
- **Triggers**: Push to main, PRs, releases, manual dispatch
- **Permissions**: Requires `contents: write` for creating releases
- **Output**: Windows executable (`snake_game.exe`) 
- **Distribution**: 
  - Artifacts available in Actions tab for all builds
  - Automatic "latest" release created/updated on each push to main
  - Manual releases get executable attached when created properly

**Important**: To get executables in manual releases, create the release AFTER the workflow exists, or trigger the workflow after release creation.

## Code Architecture

### Main Game Class (`snake_game.py`)
- **SnakeGame**: Single monolithic class containing all game logic
- **Key Components**:
  - Game state management (obstacle choice, speed selection, game over)
  - A* pathfinding algorithm for path generation
  - Plasma gradient coloring for path visualization
  - Input handling with direction change debouncing
  - Game loop with variable speed control

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

- **pygame**: Core game engine and graphics
- **Python 3.x**: Base runtime
- **pyinstaller**: For creating standalone executables (optional)

## File Structure

- `snake_game.py`: Main game implementation
- `test_game.py`: Basic functionality test
- `snake_game.spec`: PyInstaller configuration
- `build/` and `dist/`: Build artifacts (gitignored)
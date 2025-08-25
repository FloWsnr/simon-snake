# Path Following Snake Game

A unique twist on the classic Snake game where you must follow a colored path to reach the food!
Coded with Claude, so expect some errors or weird choices...

## Features

- **Path Following Gameplay**: Instead of freely moving around, you must follow a generated path from your snake to the food
- **Plasma Gradient Path**: The path uses a beautiful plasma colormap - blue at the snake position transitioning to yellow at the food
- **Obstacles**: Random obstacles are placed throughout the game field
- **Moderate Speed**: Comfortable gameplay speed
- **Path Width**: The path is wide enough (3 cells) to make it easier to stay on track

## Requirements

- Python 3.x
- Pygame (`pip install pygame`)

## How to Play

1. **Activate the snake conda environment**:
   ```bash
   conda activate snake
   ```

2. **Run the game**:
   ```bash
   python snake_game.py
   ```

3. **Controls**:
   - **Arrow Keys**: Control the snake direction
   - **ESC**: Quit the game
   - **R**: Restart the game after a game over

## Game Rules

1. Use arrow keys to control your snake
2. **Stay on the colored path** - stepping off the path ends the game
3. Follow the path from your current position to the red food
4. The path always starts in your current direction of travel
5. Avoid obstacles (gray squares)
6. Don't hit the walls or your own body
7. Each food increases your score and snake length slightly

## Path System

- The path is generated using A* pathfinding algorithm
- Path starts at snake's head and goes to the food
- First segment always follows your current direction
- Path is colored with plasma gradient (blue → purple → red → yellow)
- Path width is 3 cells on each side for easier navigation

## Download Pre-built Executable (Windows)

### From GitHub Releases (Recommended)
1. Go to the [Releases page](../../releases)
2. Download `snake-game-windows.exe` from the latest release
3. Run the executable directly - no Python installation required!

### From GitHub Actions (Latest Build)
If no releases are available, you can download the latest build:
1. Go to the [Actions tab](../../actions)
2. Click on the latest "Build Windows Executable" workflow run
3. Download the `snake-game-windows` artifact
4. Extract and run `snake_game.exe`

## Windows Compatibility

The game is fully compatible with Windows and requires no complex installation - just Python and Pygame.

## Troubleshooting

- **ALSA warnings on Linux/WSL**: These audio warnings can be safely ignored
- **Module not found**: Make sure pygame is installed: `pip install pygame`
- **Game doesn't start**: Ensure you're in the correct conda environment: `conda activate snake`

## Development

- Use pyinstaller to create a standalone executable:
  ```bash
  pip install pyinstaller
  ```

  ```bash
  # Basic executable (with console window)
  pyinstaller --onefile snake_game.py
  
  # Executable without console window (recommended)
  pyinstaller --onefile --windowed snake_game.py
  ```
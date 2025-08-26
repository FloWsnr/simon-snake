# Path Following Snake Game

A unique twist on the classic Snake game where you must follow a colored path to reach the food!
Built with Godot 4.4.1 and coded with Claude, so expect some errors or weird choices...

## Features

- **Path Following Gameplay**: Instead of freely moving around, you must follow a generated path from your snake to the food
- **Plasma Gradient Path**: The path uses a beautiful plasma colormap - blue at the snake position transitioning to yellow at the food
- **Obstacles**: Optional randomly placed obstacles throughout the game field
- **Multiple Speed Settings**: Choose between Slow, Medium, and Fast gameplay speeds
- **Path Width**: The path is wide enough (3 cells) to make it easier to stay on track

## Requirements

- Godot 4.4.1 or compatible version

## How to Play

1. **Run the game**:
   ```bash
   godot --path .
   ```
   Or with full path to Godot executable:
   ```bash
   /path/to/Godot_v4.4.1-stable_linux.x86_64 --path /home/flwi/Coding/snake
   ```

2. **Controls**:
   - **Arrow Keys**: Control the snake direction
   - **ESC**: Quit the game
   - **R**: Restart the game after a game over
   - **S**: Change settings again

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

## Download Pre-built Executables

### From GitHub Releases (Recommended)
1. Go to the [Releases page](../../releases)
2. Download the appropriate executable for your platform:
   - **Windows**: `SimonSnakeGame.exe`
   - **Linux**: `SimonSnakeGame.x86_64`
   - **Web**: Download the web build folder
3. Run the executable directly - no Godot installation required!

### From GitHub Actions (Latest Build)
If no releases are available, you can download the latest build:
1. Go to the [Actions tab](../../actions)
2. Click on the latest "Build Godot Game" workflow run
3. Download the appropriate platform artifact:
   - `windows-build` - Contains `SimonSnakeGame.exe`
   - `linux-build` - Contains `SimonSnakeGame.x86_64`
   - `web-build` - Contains web version files
4. Extract and run the executable

## Cross-Platform Compatibility

The game is built with Godot and runs natively on Windows, Linux, and Web browsers with no additional dependencies.

## Web Version Setup

The web version requires serving files through a web server due to browser CORS restrictions.

### Running Web Version Locally
After downloading and extracting `web-build.tar.gz`:

**Option 1 - Python (recommended):**
```bash
cd web-build-folder
python3 -m http.server 8000
# Open http://localhost:8000 in your browser
```

**Option 2 - Node.js:**
```bash
cd web-build-folder
npx serve .
# Open the provided URL in your browser
```

**Option 3 - PHP:**
```bash
cd web-build-folder
php -S localhost:8000
# Open http://localhost:8000 in your browser
```

### Deploying to Web Server
Upload all files from the web build to your web server root or subdirectory. All files are required:
- `index.html` (main page)
- `index.js` (Godot engine)
- `index.wasm` (WebAssembly binary)
- `index.pck` (game data)
- `index.png` (splash screen)
- `index.icon.png` (favicon)
- `index.apple-touch-icon.png` (iOS icon)
- Audio worklet files

## Troubleshooting

- **Game doesn't start**: Make sure you have the correct executable permissions on Linux
- **Web version "NetworkError"**: Must serve through web server, not open HTML file directly
- **Web version blank/loading**: Ensure all files are uploaded and server supports WASM
- **Performance issues**: Try adjusting the game speed setting in the initial menu

## Development

### Building Executables
```bash
# Export using Godot (requires export templates)
godot --headless --export-release "Windows Desktop" builds/windows/SimonSnakeGame.exe
godot --headless --export-release "Linux" builds/linux/SimonSnakeGame.x86_64
godot --headless --export-release "Web" builds/web/index.html
```

**Note**: The build configuration creates single-file executables with embedded .pck files for easier distribution (no separate .pck file required).
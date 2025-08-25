#!/usr/bin/env python3

import os
os.environ['SDL_VIDEODRIVER'] = 'dummy'

try:
    import pygame
    pygame.init()
    
    print("Testing game initialization...")
    
    # Import and test the game class
    from snake_game import SnakeGame
    
    # Test game creation
    game = SnakeGame()
    print("✓ Game created successfully")
    print(f"✓ Snake position: {game.snake[0]}")
    print(f"✓ Food position: {game.food}")
    print(f"✓ Number of obstacles: {len(game.obstacles)}")
    print(f"✓ Path length: {len(game.path)}")
    print("✓ All components initialized successfully")
    
    pygame.quit()
    print("✓ Game test completed successfully!")
    
except Exception as e:
    print(f"✗ Error: {e}")
    import traceback
    traceback.print_exc()
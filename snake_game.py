import pygame
import random
import math
from collections import deque

pygame.init()

WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600
CELL_SIZE = 20
GRID_WIDTH = WINDOW_WIDTH // CELL_SIZE
GRID_HEIGHT = WINDOW_HEIGHT // CELL_SIZE

BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
GREEN = (0, 255, 0)
RED = (255, 0, 0)
GRAY = (128, 128, 128)

class SnakeGame:
    def __init__(self):
        self.screen = pygame.display.set_mode((WINDOW_WIDTH, WINDOW_HEIGHT))
        pygame.display.set_caption("Path Following Snake Game")
        self.clock = pygame.time.Clock()
        
        self.snake = [(GRID_WIDTH // 2, GRID_HEIGHT // 2)]
        self.direction = (1, 0)
        self.obstacles = self.generate_obstacles()
        self.food = self.generate_food()
        self.path = []
        self.path_width = 3
        self.game_over = False
        self.score = 0
        
        self.generate_path_to_food()
    
    def generate_obstacles(self):
        obstacles = set()
        num_obstacles = 15
        
        for _ in range(num_obstacles):
            while True:
                x = random.randint(0, GRID_WIDTH - 1)
                y = random.randint(0, GRID_HEIGHT - 1)
                if (x, y) not in self.snake:
                    obstacles.add((x, y))
                    break
        return obstacles
    
    def generate_food(self):
        while True:
            x = random.randint(0, GRID_WIDTH - 1)
            y = random.randint(0, GRID_HEIGHT - 1)
            if (x, y) not in self.snake and (x, y) not in self.obstacles:
                return (x, y)
    
    def generate_path_to_food(self):
        start = self.snake[0]
        target = self.food
        
        # Simple pathfinding with A* algorithm
        def heuristic(a, b):
            return abs(a[0] - b[0]) + abs(a[1] - b[1])
        
        open_set = [(0, start)]
        came_from = {}
        g_score = {start: 0}
        f_score = {start: heuristic(start, target)}
        
        # Ensure first step goes in current direction
        first_step = (start[0] + self.direction[0], start[1] + self.direction[1])
        if (0 <= first_step[0] < GRID_WIDTH and 0 <= first_step[1] < GRID_HEIGHT and 
            first_step not in self.obstacles):
            came_from[first_step] = start
            g_score[first_step] = 1
            f_score[first_step] = 1 + heuristic(first_step, target)
            open_set.append((f_score[first_step], first_step))
        
        while open_set:
            current = min(open_set, key=lambda x: x[0])[1]
            open_set = [(f, pos) for f, pos in open_set if pos != current]
            
            if current == target:
                # Reconstruct path
                path = []
                while current in came_from:
                    path.append(current)
                    current = came_from[current]
                path.append(start)
                self.path = path[::-1]
                return
            
            for dx, dy in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
                neighbor = (current[0] + dx, current[1] + dy)
                
                if (0 <= neighbor[0] < GRID_WIDTH and 0 <= neighbor[1] < GRID_HEIGHT and
                    neighbor not in self.obstacles):
                    
                    tentative_g = g_score.get(current, float('inf')) + 1
                    
                    if neighbor not in g_score or tentative_g < g_score[neighbor]:
                        came_from[neighbor] = current
                        g_score[neighbor] = tentative_g
                        f_score[neighbor] = tentative_g + heuristic(neighbor, target)
                        
                        if (f_score[neighbor], neighbor) not in open_set:
                            open_set.append((f_score[neighbor], neighbor))
        
        # Fallback: direct path if A* fails
        self.path = [start, target]
    
    def get_plasma_color(self, position):
        if not self.path:
            return (255, 255, 255)
        
        # Find position in path
        path_index = 0
        min_dist = float('inf')
        for i, path_pos in enumerate(self.path):
            dist = abs(path_pos[0] - position[0]) + abs(path_pos[1] - position[1])
            if dist < min_dist:
                min_dist = dist
                path_index = i
        
        # Normalize position along path (0 = start, 1 = end)
        t = path_index / max(1, len(self.path) - 1)
        
        # Plasma colormap approximation
        # Blue to purple to red to yellow
        if t < 0.25:
            # Blue to purple
            r = int(t * 4 * 128)
            g = 0
            b = 255
        elif t < 0.5:
            # Purple to red
            r = 128 + int((t - 0.25) * 4 * 127)
            g = 0
            b = 255 - int((t - 0.25) * 4 * 255)
        elif t < 0.75:
            # Red to orange
            r = 255
            g = int((t - 0.5) * 4 * 165)
            b = 0
        else:
            # Orange to yellow
            r = 255
            g = 165 + int((t - 0.75) * 4 * 90)
            b = 0
        
        return (min(255, r), min(255, g), min(255, b))
    
    def is_on_path(self, position):
        if not self.path:
            return True
        
        # Check if position is within path_width of any path segment
        for path_pos in self.path:
            if abs(position[0] - path_pos[0]) <= self.path_width and abs(position[1] - path_pos[1]) <= self.path_width:
                return True
        return False
    
    def handle_input(self):
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                return False
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_UP and self.direction != (0, 1):
                    self.direction = (0, -1)
                elif event.key == pygame.K_DOWN and self.direction != (0, -1):
                    self.direction = (0, 1)
                elif event.key == pygame.K_LEFT and self.direction != (1, 0):
                    self.direction = (-1, 0)
                elif event.key == pygame.K_RIGHT and self.direction != (-1, 0):
                    self.direction = (1, 0)
        return True
    
    def update(self):
        if self.game_over:
            return
        
        # Move snake
        head_x, head_y = self.snake[0]
        new_head = (head_x + self.direction[0], head_y + self.direction[1])
        
        # Check boundaries
        if (new_head[0] < 0 or new_head[0] >= GRID_WIDTH or 
            new_head[1] < 0 or new_head[1] >= GRID_HEIGHT):
            self.game_over = True
            return
        
        # Check self collision
        if new_head in self.snake:
            self.game_over = True
            return
        
        # Check obstacle collision
        if new_head in self.obstacles:
            self.game_over = True
            return
        
        # Check if off path
        if not self.is_on_path(new_head):
            self.game_over = True
            return
        
        self.snake.insert(0, new_head)
        
        # Check food collision
        if new_head == self.food:
            self.score += 10
            self.food = self.generate_food()
            self.generate_path_to_food()
            # Only grow by 1 segment (not by much as requested)
        else:
            self.snake.pop()
    
    def draw(self):
        self.screen.fill(BLACK)
        
        # Draw path with gradient
        for i, path_pos in enumerate(self.path):
            for dx in range(-self.path_width, self.path_width + 1):
                for dy in range(-self.path_width, self.path_width + 1):
                    draw_x = path_pos[0] + dx
                    draw_y = path_pos[1] + dy
                    if 0 <= draw_x < GRID_WIDTH and 0 <= draw_y < GRID_HEIGHT:
                        color = self.get_plasma_color((draw_x, draw_y))
                        pygame.draw.rect(self.screen, color,
                                       (draw_x * CELL_SIZE, draw_y * CELL_SIZE, CELL_SIZE, CELL_SIZE))
        
        # Draw obstacles
        for obstacle in self.obstacles:
            pygame.draw.rect(self.screen, GRAY,
                           (obstacle[0] * CELL_SIZE, obstacle[1] * CELL_SIZE, CELL_SIZE, CELL_SIZE))
        
        # Draw food
        pygame.draw.rect(self.screen, RED,
                        (self.food[0] * CELL_SIZE, self.food[1] * CELL_SIZE, CELL_SIZE, CELL_SIZE))
        
        # Draw snake
        for i, segment in enumerate(self.snake):
            color = GREEN if i == 0 else (0, 200, 0)
            pygame.draw.rect(self.screen, color,
                           (segment[0] * CELL_SIZE, segment[1] * CELL_SIZE, CELL_SIZE, CELL_SIZE))
        
        # Draw score
        font = pygame.font.Font(None, 36)
        score_text = font.render(f"Score: {self.score}", True, WHITE)
        self.screen.blit(score_text, (10, 10))
        
        # Draw game over message
        if self.game_over:
            game_over_text = font.render("Game Over! Press ESC to quit", True, WHITE)
            text_rect = game_over_text.get_rect(center=(WINDOW_WIDTH // 2, WINDOW_HEIGHT // 2))
            self.screen.blit(game_over_text, text_rect)
        
        pygame.display.flip()
    
    def run(self):
        running = True
        while running:
            running = self.handle_input()
            
            if pygame.key.get_pressed()[pygame.K_ESCAPE]:
                break
            
            self.update()
            self.draw()
            self.clock.tick(8)  # Moderate speed
        
        pygame.quit()

if __name__ == "__main__":
    game = SnakeGame()
    game.run()
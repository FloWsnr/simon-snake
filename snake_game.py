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

        self.obstacles_enabled = True
        self.waiting_for_obstacle_choice = True
        self.game_started = False
        self.snake = [(GRID_WIDTH // 2, GRID_HEIGHT // 2)]
        self.direction = (1, 0)
        self.obstacles = set()
        self.food = None
        self.path = []
        self.path_width = 3
        self.game_over = False
        self.score = 0
        self.start_time = pygame.time.get_ticks()
        self.path_delay = 5000  # 5 seconds in milliseconds
        self.path_generated = False  # Track if initial path has been generated
        self.obstacle_choice_made = False  # Track if obstacle choice has been made

    def generate_obstacles(self):
        if not self.obstacles_enabled:
            return set()

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
        # IMPORTANT: Always use the current head position when generating the path
        start = self.snake[0]
        target = self.food

        # Simple pathfinding with A* algorithm
        def heuristic(a, b):
            return abs(a[0] - b[0]) + abs(a[1] - b[1])

        # Fix: Initialize open_set with correct f_score
        initial_f = heuristic(start, target)
        open_set = [(initial_f, start)]
        came_from = {}
        g_score = {start: 0}
        f_score = {start: initial_f}
        visited = set()

        while open_set:
            current = min(open_set, key=lambda x: x[0])[1]
            open_set = [(f, pos) for f, pos in open_set if pos != current]

            if current == target:
                # Reconstruct path from start to target
                path = [current]  # Start with target
                while current in came_from:
                    current = came_from[current]
                    path.append(current)
                # No need to add start again - it's already in the path from backtracking
                self.path = path[::-1]  # Reverse to go from start to target
                print(
                    f"Path generated: from {self.snake[0]} to {self.food}, path length: {len(self.path)}"
                )
                return

            visited.add(current)

            for dx, dy in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
                neighbor = (current[0] + dx, current[1] + dy)

                # Check if neighbor is valid (not out of bounds, not an obstacle, not snake body)
                if (
                    0 <= neighbor[0] < GRID_WIDTH
                    and 0 <= neighbor[1] < GRID_HEIGHT
                    and neighbor not in self.obstacles
                    and neighbor not in self.snake[1:]
                    and neighbor not in visited
                ):
                    tentative_g = g_score.get(current, float("inf")) + 1

                    if neighbor not in g_score or tentative_g < g_score[neighbor]:
                        came_from[neighbor] = current
                        g_score[neighbor] = int(tentative_g)
                        f_score[neighbor] = int(tentative_g + heuristic(neighbor, target))

                        # Check if neighbor is not already in open_set before adding
                        if not any(pos == neighbor for _, pos in open_set):
                            open_set.append((f_score[neighbor], neighbor))

        # Fallback: If no path found, create direct path (for visualization)
        print(
            f"Warning: No valid path found from {start} to {target}, using direct path"
        )
        self.path = [start, target]

    def get_plasma_color(self, position):
        if not self.path:
            return (255, 255, 255)

        # Find position in path
        path_index = 0
        min_dist = float("inf")
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
        for i in range(len(self.path)):
            path_pos = self.path[i]
            # Check Manhattan distance for thick path
            if (
                abs(position[0] - path_pos[0]) <= self.path_width
                and abs(position[1] - path_pos[1]) <= self.path_width
            ):
                return True

            # Also check between consecutive path points for better coverage
            if i < len(self.path) - 1:
                next_pos = self.path[i + 1]
                # Simple check: if position is between two consecutive path points
                if (
                    min(path_pos[0], next_pos[0]) - self.path_width
                    <= position[0]
                    <= max(path_pos[0], next_pos[0]) + self.path_width
                    and min(path_pos[1], next_pos[1]) - self.path_width
                    <= position[1]
                    <= max(path_pos[1], next_pos[1]) + self.path_width
                ):
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
                elif event.key == pygame.K_r and self.game_over:
                    self.restart_game()
                elif event.key == pygame.K_y and self.waiting_for_obstacle_choice:
                    self.obstacles_enabled = True
                    self.obstacle_choice_made = True
                    if self.game_over:
                        self.restart_game()
                    else:
                        self.start_game()
                elif event.key == pygame.K_n and self.waiting_for_obstacle_choice:
                    self.obstacles_enabled = False
                    self.obstacle_choice_made = True
                    if self.game_over:
                        self.restart_game()
                    else:
                        self.start_game()
        return True

    def start_game(self):
        self.obstacles = self.generate_obstacles()
        self.food = self.generate_food()
        self.game_started = True
        self.waiting_for_obstacle_choice = False
        self.start_time = pygame.time.get_ticks()
        self.path_generated = False  # Track if initial path has been generated
        # Don't generate path here - wait for 5 seconds

    def restart_game(self):
        self.snake = [(GRID_WIDTH // 2, GRID_HEIGHT // 2)]
        self.direction = (1, 0)
        self.obstacles = self.generate_obstacles()  # Generate new random obstacles each restart
        self.food = self.generate_food()
        self.path = []
        self.game_over = False
        self.score = 0
        self.start_time = pygame.time.get_ticks()
        # Only show obstacle choice if it hasn't been made yet
        self.waiting_for_obstacle_choice = not self.obstacle_choice_made
        self.game_started = True
        self.path_generated = False  # Track if initial path has been generated
        # Don't generate path here - wait for 5 seconds

    def update(self):
        if self.game_over or not self.game_started:
            return

        current_time = pygame.time.get_ticks()

        # Generate the initial path exactly at the 5-second mark
        if (
            not self.path_generated
            and current_time - self.start_time >= self.path_delay
        ):
            self.generate_path_to_food()
            self.path_generated = True
            print(
                f"Initial path generated at 5-second mark from {self.snake[0]} to {self.food}"
            )

        # Move snake
        head_x, head_y = self.snake[0]
        new_head = (head_x + self.direction[0], head_y + self.direction[1])

        # Check boundaries
        if (
            new_head[0] < 0
            or new_head[0] >= GRID_WIDTH
            or new_head[1] < 0
            or new_head[1] >= GRID_HEIGHT
        ):
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

        # Check if off path (only after delay period and after path is generated)
        if self.path_generated and not self.is_on_path(new_head):
            self.game_over = True
            print(f"Game over: Snake at {new_head} is off path")
            return

        self.snake.insert(0, new_head)

        # Check food collision
        if new_head == self.food:
            self.score += 10
            self.food = self.generate_food()
            # IMPORTANT: Generate path after eating, from the NEW head position
            self.generate_path_to_food()
            # Snake grows by not popping tail
        else:
            self.snake.pop()

    def draw(self):
        self.screen.fill(BLACK)

        # Draw path with gradient (only after it's generated at the 5-second mark)
        if self.path_generated and self.path:
            # Draw the path
            for i, path_pos in enumerate(self.path):
                for dx in range(-self.path_width, self.path_width + 1):
                    for dy in range(-self.path_width, self.path_width + 1):
                        draw_x = path_pos[0] + dx
                        draw_y = path_pos[1] + dy
                        if 0 <= draw_x < GRID_WIDTH and 0 <= draw_y < GRID_HEIGHT:
                            color = self.get_plasma_color((draw_x, draw_y))
                            pygame.draw.rect(
                                self.screen,
                                color,
                                (
                                    draw_x * CELL_SIZE,
                                    draw_y * CELL_SIZE,
                                    CELL_SIZE,
                                    CELL_SIZE,
                                ),
                            )

            # Draw path start and end markers for debugging
            if self.path:
                # Start point (bright green circle)
                start_x, start_y = self.path[0]
                pygame.draw.circle(
                    self.screen,
                    (0, 255, 0),
                    (
                        start_x * CELL_SIZE + CELL_SIZE // 2,
                        start_y * CELL_SIZE + CELL_SIZE // 2,
                    ),
                    CELL_SIZE // 3,
                )

                # End point (bright red circle)
                end_x, end_y = self.path[-1]
                pygame.draw.circle(
                    self.screen,
                    (255, 0, 0),
                    (
                        end_x * CELL_SIZE + CELL_SIZE // 2,
                        end_y * CELL_SIZE + CELL_SIZE // 2,
                    ),
                    CELL_SIZE // 3,
                )

        # Draw obstacles
        for obstacle in self.obstacles:
            pygame.draw.rect(
                self.screen,
                GRAY,
                (
                    obstacle[0] * CELL_SIZE,
                    obstacle[1] * CELL_SIZE,
                    CELL_SIZE,
                    CELL_SIZE,
                ),
            )

        # Draw food
        if self.food:
            pygame.draw.rect(
                self.screen,
                RED,
                (
                    self.food[0] * CELL_SIZE,
                    self.food[1] * CELL_SIZE,
                    CELL_SIZE,
                    CELL_SIZE,
                ),
            )

        # Draw snake
        for i, segment in enumerate(self.snake):
            color = GREEN if i == 0 else (0, 200, 0)
            pygame.draw.rect(
                self.screen,
                color,
                (segment[0] * CELL_SIZE, segment[1] * CELL_SIZE, CELL_SIZE, CELL_SIZE),
            )

        # Draw score and timer
        font = pygame.font.Font(None, 36)
        score_text = font.render(f"Score: {self.score}", True, WHITE)
        self.screen.blit(score_text, (10, 10))

        # Draw countdown timer before path appears
        if not self.path_generated and self.game_started:
            current_time = pygame.time.get_ticks()
            time_left = max(0, self.path_delay - (current_time - self.start_time))
            seconds_left = time_left // 1000 + (1 if time_left % 1000 > 0 else 0)
            timer_font = pygame.font.Font(None, 28)
            timer_text = timer_font.render(
                f"Path appears in: {seconds_left}s", True, WHITE
            )
            self.screen.blit(timer_text, (10, 50))

        # Draw debug info
        if self.path_generated and self.path:
            debug_font = pygame.font.Font(None, 24)
            debug_text = debug_font.render(
                f"Path: {self.path[0]} → {self.path[-1]}", True, WHITE
            )
            self.screen.blit(debug_text, (10, 50))

        # Draw game over or initial choice message
        if self.waiting_for_obstacle_choice:
            if self.game_over:
                choice_text = font.render(
                    "Enable obstacles? Press Y for Yes, N for No", True, WHITE
                )
            else:
                choice_text = font.render(
                    "Welcome! Enable obstacles? Press Y for Yes, N for No", True, WHITE
                )
            text_rect = choice_text.get_rect(
                center=(WINDOW_WIDTH // 2, WINDOW_HEIGHT // 2)
            )
            self.screen.blit(choice_text, text_rect)
        elif self.game_over:
            game_over_text = font.render(
                "Game Over! Press R to restart or ESC to quit", True, WHITE
            )
            text_rect = game_over_text.get_rect(
                center=(WINDOW_WIDTH // 2, WINDOW_HEIGHT // 2)
            )
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

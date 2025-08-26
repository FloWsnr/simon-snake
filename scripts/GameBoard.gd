extends Node2D

# Constants (converted from pygame constants)
const WINDOW_WIDTH = 800
const WINDOW_HEIGHT = 600
const CELL_SIZE = 20
const GRID_WIDTH = WINDOW_WIDTH / CELL_SIZE
const GRID_HEIGHT = WINDOW_HEIGHT / CELL_SIZE

# Color constants
const BLACK = Color.BLACK
const WHITE = Color.WHITE
const GREEN = Color.GREEN
const RED = Color.RED
const GRAY = Color.GRAY

# Game state variables
var obstacles_enabled: bool = true
var waiting_for_obstacle_choice: bool = true
var waiting_for_speed_choice: bool = false
var game_started: bool = false
var obstacle_choice_made: bool = false

# Speed settings
var speed_options = ["Slow", "Medium", "Fast"]
var speed_delays = [8, 5, 3]  # frames between moves (higher = slower)
var selected_speed: int = 1  # Default to Medium
var move_counter: int = 0

# Game objects
var snake: Array[Vector2] = []
var direction: Vector2 = Vector2.RIGHT
var obstacles: Array[Vector2] = []
var food: Vector2 = Vector2.ZERO
var path: Array[Vector2] = []
var path_width: int = 3

# Game state
var game_over: bool = false
var score: int = 0
var start_time: float = 0.0
var path_delay: float = 5.0  # 5 seconds
var path_generated: bool = false

# Input handling
var last_direction_change: float = 0.0
var direction_change_delay: float = 0.1  # 100ms in seconds
var pending_direction: Vector2 = Vector2.ZERO

# Node references
@onready var path_renderer = $GameBoard/PathRenderer
@onready var obstacles_container = $GameBoard/Obstacles
@onready var food_rect = $GameBoard/Food
@onready var snake_container = $GameBoard/Snake
@onready var score_label = $UI/ScoreLabel
@onready var timer_label = $UI/TimerLabel
@onready var debug_label = $UI/DebugLabel
@onready var obstacle_menu = $UI/MenuContainer/ObstacleMenu
@onready var speed_menu = $UI/MenuContainer/SpeedMenu
@onready var game_over_menu = $UI/MenuContainer/GameOverMenu

func _ready():
	initialize_game()

func initialize_game():
	snake = [Vector2(GRID_WIDTH / 2, GRID_HEIGHT / 2)]
	direction = Vector2.RIGHT
	obstacles = []
	food = Vector2.ZERO
	path = []
	game_over = false
	score = 0
	start_time = 0.0
	path_generated = false
	move_counter = 0
	last_direction_change = 0.0
	
	# Show initial menu
	show_obstacle_menu()

func _process(delta):
	handle_input()
	if game_started and not game_over:
		update_game(delta)
	update_ui()

func handle_input():
	var current_time_ms = Time.get_ticks_msec()
	
	# Menu input handling
	if waiting_for_obstacle_choice:
		if Input.is_action_just_pressed("toggle_obstacles_yes"):
			obstacles_enabled = true
			obstacle_choice_made = true
			waiting_for_obstacle_choice = false
			waiting_for_speed_choice = true
			show_speed_menu()
		elif Input.is_action_just_pressed("toggle_obstacles_no"):
			obstacles_enabled = false
			obstacle_choice_made = true
			waiting_for_obstacle_choice = false
			waiting_for_speed_choice = true
			show_speed_menu()
	
	elif waiting_for_speed_choice:
		if Input.is_action_just_pressed("speed_1"):
			selected_speed = 0  # Slow
			waiting_for_speed_choice = false
			if game_over:
				restart_game()
			else:
				start_game()
		elif Input.is_action_just_pressed("speed_2"):
			selected_speed = 1  # Medium
			waiting_for_speed_choice = false
			if game_over:
				restart_game()
			else:
				start_game()
		elif Input.is_action_just_pressed("speed_3"):
			selected_speed = 2  # Fast
			waiting_for_speed_choice = false
			if game_over:
				restart_game()
			else:
				start_game()
	
	# Game input handling
	elif game_started and not game_over:
		var new_direction = Vector2.ZERO
		
		# Check for direction changes with anti-reversal logic
		if Input.is_action_pressed("ui_up") and direction != Vector2.DOWN:
			new_direction = Vector2.UP
		elif Input.is_action_pressed("ui_down") and direction != Vector2.UP:
			new_direction = Vector2.DOWN
		elif Input.is_action_pressed("ui_left") and direction != Vector2.RIGHT:
			new_direction = Vector2.LEFT
		elif Input.is_action_pressed("ui_right") and direction != Vector2.LEFT:
			new_direction = Vector2.RIGHT
		
		# Apply direction change with debouncing
		var current_time_sec = Time.get_ticks_msec() / 1000.0
		if new_direction != Vector2.ZERO and (current_time_sec - last_direction_change) > direction_change_delay:
			direction = new_direction
			last_direction_change = current_time_sec
			print("Direction changed to: ", direction)
	
	# Restart game
	if Input.is_action_just_pressed("restart_game") and game_over:
		restart_game()
	
	# Quit game
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func start_game():
	obstacles = generate_obstacles()
	food = generate_food()
	game_started = true
	waiting_for_obstacle_choice = false
	waiting_for_speed_choice = false
	start_time = Time.get_ticks_msec() / 1000.0
	path_generated = false
	
	# Hide menus and setup game objects
	hide_all_menus()
	setup_food_visual()
	print("Game started!")

func restart_game():
	snake = [Vector2(GRID_WIDTH / 2, GRID_HEIGHT / 2)]
	direction = Vector2.RIGHT
	obstacles = generate_obstacles()
	food = generate_food()
	path = []
	game_over = false
	score = 0
	start_time = Time.get_ticks_msec() / 1000.0
	waiting_for_obstacle_choice = not obstacle_choice_made
	waiting_for_speed_choice = false
	move_counter = 0
	game_started = true
	path_generated = false
	last_direction_change = 0.0
	
	# Clear visual elements
	clear_visual_elements()
	hide_all_menus()
	setup_food_visual()
	print("Game restarted!")

func update_game(delta):
	if game_over:
		return
	
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# Generate the initial path exactly at the 5-second mark
	if not path_generated and (current_time - start_time) >= path_delay:
		generate_path_to_food()
		path_generated = true
		print("Initial path generated at 5-second mark from ", snake[0], " to ", food)
	
	# Only move snake based on speed setting
	move_counter += 1
	if move_counter < speed_delays[selected_speed]:
		return
	move_counter = 0
	
	# Move snake
	var head_pos = snake[0]
	var new_head = head_pos + direction
	
	# Check boundaries
	if new_head.x < 0 or new_head.x >= GRID_WIDTH or new_head.y < 0 or new_head.y >= GRID_HEIGHT:
		game_over = true
		show_game_over_menu()
		return
	
	# Check self collision
	if new_head in snake:
		game_over = true
		show_game_over_menu()
		return
	
	# Check obstacle collision
	if new_head in obstacles:
		game_over = true
		show_game_over_menu()
		return
	
	# Check if off path (only after delay period and after path is generated)
	if path_generated and not is_on_path(new_head):
		game_over = true
		show_game_over_menu()
		print("Game over: Snake at ", new_head, " is off path")
		return
	
	snake.insert(0, new_head)
	
	# Check food collision
	if new_head == food:
		score += 10
		food = generate_food()
		generate_path_to_food()
		setup_food_visual()
		# Snake grows by not removing tail
	else:
		snake.pop_back()
	
	# Update visual snake
	update_snake_visual()

func generate_obstacles() -> Array[Vector2]:
	if not obstacles_enabled:
		return []
	
	var obs_array: Array[Vector2] = []
	var num_obstacles = 15
	
	for i in range(num_obstacles):
		var attempts = 0
		while attempts < 100:  # Prevent infinite loops
			var x = randi_range(0, GRID_WIDTH - 1)
			var y = randi_range(0, GRID_HEIGHT - 1)
			var pos = Vector2(x, y)
			if pos not in snake and pos not in obs_array:
				obs_array.append(pos)
				break
			attempts += 1
	
	# Update visual obstacles
	update_obstacles_visual(obs_array)
	return obs_array

func generate_food() -> Vector2:
	var attempts = 0
	while attempts < 1000:  # Prevent infinite loops
		var x = randi_range(0, GRID_WIDTH - 1)
		var y = randi_range(0, GRID_HEIGHT - 1)
		var pos = Vector2(x, y)
		if pos not in snake and pos not in obstacles:
			return pos
		attempts += 1
	
	# Fallback - return any empty position
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var pos = Vector2(x, y)
			if pos not in snake and pos not in obstacles:
				return pos
	
	# Last resort - return a position outside snake
	return Vector2(GRID_WIDTH - 1, GRID_HEIGHT - 1)

func generate_path_to_food():
	# A* pathfinding algorithm ported from Python
	var start = snake[0]
	var target = food
	
	# Heuristic function (Manhattan distance)
	var heuristic = func(a: Vector2, b: Vector2) -> float:
		return abs(a.x - b.x) + abs(a.y - b.y)
	
	# Initialize A* data structures
	var initial_f = heuristic.call(start, target)
	var open_set: Array = [[initial_f, start]]
	var came_from: Dictionary = {}
	var g_score: Dictionary = {start: 0}
	var f_score: Dictionary = {start: initial_f}
	var visited: Array[Vector2] = []
	
	while open_set.size() > 0:
		# Find node with lowest f_score
		var current_index = 0
		var current_f = open_set[0][0]
		for i in range(open_set.size()):
			if open_set[i][0] < current_f:
				current_f = open_set[i][0]
				current_index = i
		
		var current = open_set[current_index][1]
		open_set.remove_at(current_index)
		
		if current == target:
			# Reconstruct path
			var temp_path: Array[Vector2] = [current]
			while current in came_from:
				current = came_from[current]
				temp_path.append(current)
			path = temp_path
			path.reverse()
			print("Path generated: from ", snake[0], " to ", food, ", path length: ", path.size())
			update_path_visual()
			return
		
		visited.append(current)
		
		# Check neighbors
		var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
		for dir in directions:
			var neighbor = current + dir
			
			# Check if neighbor is valid
			if (neighbor.x >= 0 and neighbor.x < GRID_WIDTH and 
				neighbor.y >= 0 and neighbor.y < GRID_HEIGHT and
				neighbor not in obstacles and
				neighbor not in snake.slice(1) and  # Skip head
				neighbor not in visited):
				
				var tentative_g = g_score.get(current, INF) + 1
				
				if neighbor not in g_score or tentative_g < g_score[neighbor]:
					came_from[neighbor] = current
					g_score[neighbor] = tentative_g
					f_score[neighbor] = tentative_g + heuristic.call(neighbor, target)
					
					# Check if neighbor is not already in open_set
					var in_open_set = false
					for item in open_set:
						if item[1] == neighbor:
							in_open_set = true
							break
					
					if not in_open_set:
						open_set.append([f_score[neighbor], neighbor])
	
	# Fallback: direct path if no path found
	print("Warning: No valid path found from ", start, " to ", target, ", using direct path")
	path = [start, target]
	update_path_visual()

func get_plasma_color(position: Vector2) -> Color:
	if path.size() == 0:
		return Color.WHITE
	
	# Find position in path
	var path_index = 0
	var min_dist = INF
	for i in range(path.size()):
		var path_pos = path[i]
		var dist = abs(path_pos.x - position.x) + abs(path_pos.y - position.y)
		if dist < min_dist:
			min_dist = dist
			path_index = i
	
	# Normalize position along path (0 = start, 1 = end)
	var t = float(path_index) / max(1.0, float(path.size() - 1))
	
	# Plasma colormap approximation
	var r: float
	var g: float
	var b: float
	
	if t < 0.25:
		# Blue to purple
		r = t * 4.0 * 128.0 / 255.0
		g = 0.0
		b = 1.0
	elif t < 0.5:
		# Purple to red
		r = (128.0 + (t - 0.25) * 4.0 * 127.0) / 255.0
		g = 0.0
		b = (255.0 - (t - 0.25) * 4.0 * 255.0) / 255.0
	elif t < 0.75:
		# Red to orange
		r = 1.0
		g = (t - 0.5) * 4.0 * 165.0 / 255.0
		b = 0.0
	else:
		# Orange to yellow
		r = 1.0
		g = (165.0 + (t - 0.75) * 4.0 * 90.0) / 255.0
		b = 0.0
	
	return Color(r, g, b)

func is_on_path(position: Vector2) -> bool:
	if path.size() == 0:
		return true
	
	# Check if position is within path_width of any path segment
	for i in range(path.size()):
		var path_pos = path[i]
		# Check Manhattan distance for thick path
		if (abs(position.x - path_pos.x) <= path_width and 
			abs(position.y - path_pos.y) <= path_width):
			return true
		
		# Also check between consecutive path points for better coverage
		if i < path.size() - 1:
			var next_pos = path[i + 1]
			if (min(path_pos.x, next_pos.x) - path_width <= position.x and
				position.x <= max(path_pos.x, next_pos.x) + path_width and
				min(path_pos.y, next_pos.y) - path_width <= position.y and
				position.y <= max(path_pos.y, next_pos.y) + path_width):
				return true
	
	return false

# Visual update functions
func update_path_visual():
	# Clear existing path visuals
	for child in path_renderer.get_children():
		child.queue_free()
	
	# Draw path with gradient
	if path_generated and path.size() > 0:
		for i in range(path.size()):
			var path_pos = path[i]
			for dx in range(-path_width, path_width + 1):
				for dy in range(-path_width, path_width + 1):
					var draw_pos = path_pos + Vector2(dx, dy)
					if draw_pos.x >= 0 and draw_pos.x < GRID_WIDTH and draw_pos.y >= 0 and draw_pos.y < GRID_HEIGHT:
						var path_rect = ColorRect.new()
						path_rect.position = draw_pos * CELL_SIZE
						path_rect.size = Vector2(CELL_SIZE, CELL_SIZE)
						path_rect.color = get_plasma_color(draw_pos)
						path_renderer.add_child(path_rect)

func update_snake_visual():
	# Clear existing snake visuals
	for child in snake_container.get_children():
		child.queue_free()
	
	# Draw snake segments
	for i in range(snake.size()):
		var segment_pos = snake[i]
		var snake_rect = ColorRect.new()
		snake_rect.position = segment_pos * CELL_SIZE
		snake_rect.size = Vector2(CELL_SIZE, CELL_SIZE)
		snake_rect.color = GREEN if i == 0 else Color(0, 0.8, 0)
		snake_container.add_child(snake_rect)

func setup_food_visual():
	food_rect.position = food * CELL_SIZE
	food_rect.size = Vector2(CELL_SIZE, CELL_SIZE)
	food_rect.color = RED

func update_obstacles_visual(obs_array: Array[Vector2]):
	# Clear existing obstacle visuals
	for child in obstacles_container.get_children():
		child.queue_free()
	
	# Draw obstacles
	for obstacle_pos in obs_array:
		var obstacle_rect = ColorRect.new()
		obstacle_rect.position = obstacle_pos * CELL_SIZE
		obstacle_rect.size = Vector2(CELL_SIZE, CELL_SIZE)
		obstacle_rect.color = GRAY
		obstacles_container.add_child(obstacle_rect)

func clear_visual_elements():
	# Clear all visual elements
	for child in path_renderer.get_children():
		child.queue_free()
	for child in snake_container.get_children():
		child.queue_free()
	for child in obstacles_container.get_children():
		child.queue_free()

# UI functions
func update_ui():
	score_label.text = "Score: " + str(score)
	
	# Timer display
	if not path_generated and game_started:
		var current_time = Time.get_ticks_msec() / 1000.0
		var time_left = max(0, path_delay - (current_time - start_time))
		var seconds_left = int(time_left) + (1 if fmod(time_left, 1.0) > 0 else 0)
		timer_label.text = "Path appears in: " + str(seconds_left) + "s"
		timer_label.visible = true
	elif path_generated and path.size() > 0:
		debug_label.text = "Path: " + str(path[0]) + " → " + str(path[path.size() - 1])
		timer_label.visible = false
		debug_label.visible = true
	else:
		timer_label.visible = false
		debug_label.visible = false

func show_obstacle_menu():
	hide_all_menus()
	obstacle_menu.visible = true

func show_speed_menu():
	hide_all_menus()
	speed_menu.visible = true

func show_game_over_menu():
	hide_all_menus()
	game_over_menu.visible = true

func hide_all_menus():
	obstacle_menu.visible = false
	speed_menu.visible = false
	game_over_menu.visible = false
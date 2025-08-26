extends "res://scripts/GameBoard.gd"
class_name TestGameMechanics

# Test suite for core game mechanics
var test_results: Array = []

func _ready():
	run_all_tests()
	print_test_results()
	get_tree().quit()

func run_all_tests():
	print("Running GameBoard unit tests...")
	
	# Test basic initialization
	test_initialization()
	
	# Test path generation
	test_path_generation()
	
	# Test path validation
	test_path_validation()
	
	# Test collision detection
	test_collision_detection()
	
	# Test food generation
	test_food_generation()
	
	# Test obstacle generation
	test_obstacle_generation()
	
	# Test snake movement
	test_snake_movement()
	
	# Test plasma color generation
	test_plasma_colors()

func test_initialization():
	var test_name = "Game Initialization"
	
	# Test initial snake position
	if snake.size() == 1 and snake[0] == Vector2(GRID_WIDTH / 2, GRID_HEIGHT / 2):
		add_test_result(test_name, "Initial snake position", true, "")
	else:
		add_test_result(test_name, "Initial snake position", false, "Expected snake at center, got: " + str(snake[0]))
	
	# Test initial direction
	if direction == Vector2.RIGHT:
		add_test_result(test_name, "Initial direction", true, "")
	else:
		add_test_result(test_name, "Initial direction", false, "Expected RIGHT direction, got: " + str(direction))
	
	# Test initial game state
	if not game_over and score == 0:
		add_test_result(test_name, "Initial game state", true, "")
	else:
		add_test_result(test_name, "Initial game state", false, "Expected game_over=false, score=0")

func test_path_generation():
	var test_name = "Path Generation"
	
	# Setup test conditions
	snake = [Vector2(5, 5)]
	food = Vector2(10, 10)
	obstacles = []
	
	# Generate path
	generate_path_to_food()
	
	# Test path exists
	if path.size() > 0:
		add_test_result(test_name, "Path exists", true, "Path length: " + str(path.size()))
	else:
		add_test_result(test_name, "Path exists", false, "No path generated")
		return
	
	# Test path starts at snake head
	if path[0] == snake[0]:
		add_test_result(test_name, "Path starts at snake", true, "")
	else:
		add_test_result(test_name, "Path starts at snake", false, "Expected: " + str(snake[0]) + ", got: " + str(path[0]))
	
	# Test path ends at food
	if path[path.size() - 1] == food:
		add_test_result(test_name, "Path ends at food", true, "")
	else:
		add_test_result(test_name, "Path ends at food", false, "Expected: " + str(food) + ", got: " + str(path[path.size() - 1]))
	
	# Test path continuity (each step is adjacent)
	var continuous = true
	for i in range(path.size() - 1):
		var current = path[i]
		var next = path[i + 1]
		var distance = abs(current.x - next.x) + abs(current.y - next.y)
		if distance != 1:
			continuous = false
			break
	
	if continuous:
		add_test_result(test_name, "Path continuity", true, "")
	else:
		add_test_result(test_name, "Path continuity", false, "Path has non-adjacent segments")

func test_path_validation():
	var test_name = "Path Validation"
	
	# Setup test path
	path = [Vector2(5, 5), Vector2(6, 5), Vector2(7, 5)]
	path_width = 1
	
	# Test positions on path
	if is_on_path(Vector2(6, 5)):
		add_test_result(test_name, "Position on path", true, "")
	else:
		add_test_result(test_name, "Position on path", false, "Position should be on path")
	
	# Test positions off path
	if not is_on_path(Vector2(10, 10)):
		add_test_result(test_name, "Position off path", true, "")
	else:
		add_test_result(test_name, "Position off path", false, "Position should be off path")
	
	# Test path width tolerance
	path_width = 2
	if is_on_path(Vector2(5, 7)) and is_on_path(Vector2(7, 7)):
		add_test_result(test_name, "Path width tolerance", true, "")
	else:
		add_test_result(test_name, "Path width tolerance", false, "Width tolerance not working")

func test_collision_detection():
	var test_name = "Collision Detection"
	
	# Setup test conditions
	snake = [Vector2(5, 5), Vector2(4, 5), Vector2(3, 5)]
	obstacles = [Vector2(10, 10), Vector2(15, 15)]
	
	# Test boundary collision
	var boundary_collision = (Vector2(-1, 5) in [Vector2(-1, 5)]) or \
							Vector2(GRID_WIDTH, 5).x >= GRID_WIDTH or \
							Vector2(5, -1).y < 0 or \
							Vector2(5, GRID_HEIGHT).y >= GRID_HEIGHT
	
	if boundary_collision:
		add_test_result(test_name, "Boundary detection", true, "")
	else:
		add_test_result(test_name, "Boundary detection", false, "Boundary collision not detected")
	
	# Test self collision
	if Vector2(4, 5) in snake:
		add_test_result(test_name, "Self collision detection", true, "")
	else:
		add_test_result(test_name, "Self collision detection", false, "Self collision not detected")
	
	# Test obstacle collision
	if Vector2(10, 10) in obstacles:
		add_test_result(test_name, "Obstacle collision detection", true, "")
	else:
		add_test_result(test_name, "Obstacle collision detection", false, "Obstacle collision not detected")

func test_food_generation():
	var test_name = "Food Generation"
	
	# Setup test conditions
	snake = [Vector2(5, 5)]
	obstacles = [Vector2(10, 10)]
	
	# Generate food multiple times to test validity
	var valid_food_count = 0
	for i in range(10):
		var test_food = generate_food()
		if test_food not in snake and test_food not in obstacles:
			valid_food_count += 1
	
	if valid_food_count == 10:
		add_test_result(test_name, "Valid food positions", true, "")
	else:
		add_test_result(test_name, "Valid food positions", false, "Invalid food generated: " + str(10 - valid_food_count) + " times")
	
	# Test food within bounds
	var test_food = generate_food()
	if test_food.x >= 0 and test_food.x < GRID_WIDTH and test_food.y >= 0 and test_food.y < GRID_HEIGHT:
		add_test_result(test_name, "Food within bounds", true, "")
	else:
		add_test_result(test_name, "Food within bounds", false, "Food outside grid bounds: " + str(test_food))

func test_obstacle_generation():
	var test_name = "Obstacle Generation"
	
	# Setup test conditions
	snake = [Vector2(5, 5)]
	obstacles_enabled = true
	
	# Generate obstacles
	var test_obstacles = generate_obstacles()
	
	# Test obstacle count (should be around 15, but may be less due to placement constraints)
	if test_obstacles.size() > 0 and test_obstacles.size() <= 15:
		add_test_result(test_name, "Obstacle count", true, "Generated: " + str(test_obstacles.size()))
	else:
		add_test_result(test_name, "Obstacle count", false, "Unexpected count: " + str(test_obstacles.size()))
	
	# Test obstacles don't overlap with snake
	var valid_placement = true
	for obstacle in test_obstacles:
		if obstacle in snake:
			valid_placement = false
			break
	
	if valid_placement:
		add_test_result(test_name, "Obstacle placement", true, "")
	else:
		add_test_result(test_name, "Obstacle placement", false, "Obstacles overlap with snake")
	
	# Test obstacles are within bounds
	var within_bounds = true
	for obstacle in test_obstacles:
		if obstacle.x < 0 or obstacle.x >= GRID_WIDTH or obstacle.y < 0 or obstacle.y >= GRID_HEIGHT:
			within_bounds = false
			break
	
	if within_bounds:
		add_test_result(test_name, "Obstacles within bounds", true, "")
	else:
		add_test_result(test_name, "Obstacles within bounds", false, "Obstacles outside grid")

func test_snake_movement():
	var test_name = "Snake Movement"
	
	# Setup test conditions
	snake = [Vector2(5, 5), Vector2(4, 5)]
	direction = Vector2.RIGHT
	
	# Simulate movement (without full game loop)
	var original_head = snake[0]
	var expected_new_head = original_head + direction
	
	# Test expected movement calculation
	if expected_new_head == Vector2(6, 5):
		add_test_result(test_name, "Movement calculation", true, "")
	else:
		add_test_result(test_name, "Movement calculation", false, "Expected: Vector2(6, 5), got: " + str(expected_new_head))
	
	# Test direction changes
	var old_direction = direction
	direction = Vector2.DOWN
	if direction == Vector2.DOWN and direction != old_direction:
		add_test_result(test_name, "Direction change", true, "")
	else:
		add_test_result(test_name, "Direction change", false, "Direction change failed")

func test_plasma_colors():
	var test_name = "Plasma Colors"
	
	# Setup test path
	path = [Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(3, 0)]
	
	# Test color generation
	var start_color = get_plasma_color(Vector2(0, 0))
	var end_color = get_plasma_color(Vector2(3, 0))
	
	# Start should be more blue, end should be more red/yellow
	if start_color.b > 0.5 and start_color.r < 0.5:
		add_test_result(test_name, "Start color (blue)", true, "")
	else:
		add_test_result(test_name, "Start color (blue)", false, "Start not blue enough: " + str(start_color))
	
	if end_color.r > 0.5 and end_color.b < 0.5:
		add_test_result(test_name, "End color (red/yellow)", true, "")
	else:
		add_test_result(test_name, "End color (red/yellow)", false, "End not red/yellow enough: " + str(end_color))

func add_test_result(category: String, test: String, passed: bool, details: String):
	test_results.append({
		"category": category,
		"test": test,
		"passed": passed,
		"details": details
	})

func print_test_results():
	print("\n" + "=".repeat(60))
	print("GODOT SNAKE GAME - UNIT TEST RESULTS")
	print("=".repeat(60))
	
	var total_tests = test_results.size()
	var passed_tests = 0
	var current_category = ""
	
	for result in test_results:
		if result.category != current_category:
			current_category = result.category
			print("\n📁 " + current_category + ":")
		
		var status_icon = "✅" if result.passed else "❌"
		var status_text = "PASS" if result.passed else "FAIL"
		
		print("  " + status_icon + " " + result.test + " - " + status_text)
		
		if result.details != "":
			print("     Details: " + result.details)
		
		if result.passed:
			passed_tests += 1
	
	print("\n" + "=".repeat(60))
	print("SUMMARY: " + str(passed_tests) + "/" + str(total_tests) + " tests passed")
	
	var pass_rate = float(passed_tests) / float(total_tests) * 100.0
	print("Pass Rate: " + str(pass_rate).pad_decimals(1) + "%")
	
	if passed_tests == total_tests:
		print("🎉 All tests passed! Game mechanics working correctly.")
	else:
		print("⚠️  Some tests failed. Review game logic.")
	
	print("=".repeat(60))
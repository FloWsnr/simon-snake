extends "res://scripts/GameBoard.gd"
class_name TestPathfinding

# Specialized test suite for A* pathfinding algorithm
var test_results: Array = []

func _ready():
	run_pathfinding_tests()
	print_test_results()
	get_tree().quit()

func run_pathfinding_tests():
	print("Running A* Pathfinding tests...")
	
	# Test basic pathfinding
	test_simple_path()
	
	# Test pathfinding with obstacles
	test_path_with_obstacles()
	
	# Test pathfinding edge cases
	test_edge_cases()
	
	# Test path optimization
	test_path_optimization()
	
	# Test pathfinding performance
	test_pathfinding_performance()

func test_simple_path():
	var test_name = "Simple Pathfinding"
	
	# Test straight line path
	snake = [Vector2(0, 0)]
	food = Vector2(5, 0)
	obstacles = []
	
	generate_path_to_food()
	
	# Should find direct horizontal path
	if path.size() == 6:  # Start + 5 moves
		add_test_result(test_name, "Horizontal path length", true, "Length: " + str(path.size()))
	else:
		add_test_result(test_name, "Horizontal path length", false, "Expected 6, got: " + str(path.size()))
	
	# Test diagonal path
	snake = [Vector2(0, 0)]
	food = Vector2(3, 3)
	obstacles = []
	
	generate_path_to_food()
	
	# Should find Manhattan distance path (no diagonal movement in grid)
	var expected_length = 7  # 3 right + 3 down + start = 7
	if path.size() == expected_length:
		add_test_result(test_name, "Diagonal path length", true, "Length: " + str(path.size()))
	else:
		add_test_result(test_name, "Diagonal path length", false, "Expected " + str(expected_length) + ", got: " + str(path.size()))

func test_path_with_obstacles():
	var test_name = "Pathfinding with Obstacles"
	
	# Create a simple obstacle maze
	snake = [Vector2(0, 5)]
	food = Vector2(4, 5)
	obstacles = [Vector2(1, 5), Vector2(2, 5), Vector2(3, 5)]  # Block direct path
	
	generate_path_to_food()
	
	# Path should exist and avoid obstacles
	if path.size() > 0:
		add_test_result(test_name, "Path exists with obstacles", true, "Found path of length: " + str(path.size()))
	else:
		add_test_result(test_name, "Path exists with obstacles", false, "No path found")
		return
	
	# Verify path avoids obstacles
	var path_avoids_obstacles = true
	for pos in path:
		if pos in obstacles:
			path_avoids_obstacles = false
			break
	
	if path_avoids_obstacles:
		add_test_result(test_name, "Path avoids obstacles", true, "")
	else:
		add_test_result(test_name, "Path avoids obstacles", false, "Path goes through obstacles")
	
	# Test L-shaped obstacle pattern
	snake = [Vector2(0, 0)]
	food = Vector2(2, 2)
	obstacles = []
	# Create L-shaped wall
	for i in range(3):
		obstacles.append(Vector2(1, i))
		if i < 2:
			obstacles.append(Vector2(i, 1))
	
	generate_path_to_food()
	
	if path.size() > 0 and path[path.size() - 1] == food:
		add_test_result(test_name, "L-shaped obstacle navigation", true, "Path length: " + str(path.size()))
	else:
		add_test_result(test_name, "L-shaped obstacle navigation", false, "Failed to navigate L-shaped obstacles")

func test_edge_cases():
	var test_name = "Pathfinding Edge Cases"
	
	# Test same position (snake head on food)
	snake = [Vector2(5, 5)]
	food = Vector2(5, 5)
	obstacles = []
	
	generate_path_to_food()
	
	if path.size() >= 1 and path[0] == snake[0]:
		add_test_result(test_name, "Same position handling", true, "")
	else:
		add_test_result(test_name, "Same position handling", false, "Failed to handle same position")
	
	# Test completely blocked food
	snake = [Vector2(5, 5)]
	food = Vector2(10, 10)
	obstacles = []
	# Surround food completely
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx != 0 or dy != 0:  # Don't place obstacle on food itself
				obstacles.append(food + Vector2(dx, dy))
	
	generate_path_to_food()
	
	# Should still generate some path (fallback behavior)
	if path.size() > 0:
		add_test_result(test_name, "Blocked food fallback", true, "Fallback path generated")
	else:
		add_test_result(test_name, "Blocked food fallback", false, "No fallback path")
	
	# Test path near boundaries
	snake = [Vector2(0, 0)]
	food = Vector2(GRID_WIDTH - 1, GRID_HEIGHT - 1)
	obstacles = []
	
	generate_path_to_food()
	
	if path.size() > 0 and path[path.size() - 1] == food:
		add_test_result(test_name, "Corner-to-corner path", true, "Full grid traversal works")
	else:
		add_test_result(test_name, "Corner-to-corner path", false, "Corner-to-corner pathfinding failed")

func test_path_optimization():
	var test_name = "Path Optimization"
	
	# Test if A* finds reasonably optimal paths
	snake = [Vector2(0, 0)]
	food = Vector2(5, 0)
	obstacles = []
	
	generate_path_to_food()
	
	var manhattan_distance = abs(food.x - snake[0].x) + abs(food.y - snake[0].y)
	var optimal_length = manhattan_distance + 1  # +1 for start position
	
	if path.size() == optimal_length:
		add_test_result(test_name, "Optimal path length", true, "Perfect optimization")
	elif path.size() <= optimal_length + 2:  # Allow small suboptimality
		add_test_result(test_name, "Optimal path length", true, "Near-optimal path")
	else:
		add_test_result(test_name, "Optimal path length", false, "Path too long: " + str(path.size()) + " vs optimal " + str(optimal_length))
	
	# Test path with minimal turns
	var turns = 0
	var last_direction = Vector2.ZERO
	for i in range(1, path.size()):
		var current_direction = path[i] - path[i-1]
		if current_direction != last_direction and last_direction != Vector2.ZERO:
			turns += 1
		last_direction = current_direction
	
	# For straight line, should have 0 turns
	if turns == 0:
		add_test_result(test_name, "Minimal turns", true, "Straight path with no turns")
	else:
		add_test_result(test_name, "Minimal turns", false, "Unnecessary turns: " + str(turns))

func test_pathfinding_performance():
	var test_name = "Pathfinding Performance"
	
	# Test pathfinding speed with large distances
	var start_time = Time.get_ticks_msec()
	
	snake = [Vector2(0, 0)]
	food = Vector2(GRID_WIDTH - 1, GRID_HEIGHT - 1)
	obstacles = []
	
	# Add some obstacles to make it more challenging
	for i in range(10):
		obstacles.append(Vector2(randi_range(1, GRID_WIDTH - 2), randi_range(1, GRID_HEIGHT - 2)))
	
	generate_path_to_food()
	
	var end_time = Time.get_ticks_msec()
	var duration = end_time - start_time
	
	if duration < 100:  # Should complete within 100ms
		add_test_result(test_name, "Performance speed", true, "Completed in " + str(duration) + "ms")
	else:
		add_test_result(test_name, "Performance speed", false, "Too slow: " + str(duration) + "ms")
	
	# Test multiple pathfinding calls
	start_time = Time.get_ticks_msec()
	
	for i in range(5):
		food = Vector2(randi_range(0, GRID_WIDTH - 1), randi_range(0, GRID_HEIGHT - 1))
		generate_path_to_food()
	
	end_time = Time.get_ticks_msec()
	duration = end_time - start_time
	
	if duration < 500:  # 5 paths within 500ms
		add_test_result(test_name, "Multiple path performance", true, "5 paths in " + str(duration) + "ms")
	else:
		add_test_result(test_name, "Multiple path performance", false, "Too slow for multiple paths: " + str(duration) + "ms")

func add_test_result(category: String, test: String, passed: bool, details: String):
	test_results.append({
		"category": category,
		"test": test,
		"passed": passed,
		"details": details
	})

func print_test_results():
	print("\n" + "=".repeat(60))
	print("GODOT SNAKE GAME - A* PATHFINDING TEST RESULTS")
	print("=".repeat(60))
	
	var total_tests = test_results.size()
	var passed_tests = 0
	var current_category = ""
	
	for result in test_results:
		if result.category != current_category:
			current_category = result.category
			print("\n🧭 " + current_category + ":")
		
		var status_icon = "✅" if result.passed else "❌"
		var status_text = "PASS" if result.passed else "FAIL"
		
		print("  " + status_icon + " " + result.test + " - " + status_text)
		
		if result.details != "":
			print("     Details: " + result.details)
		
		if result.passed:
			passed_tests += 1
	
	print("\n" + "=".repeat(60))
	print("PATHFINDING SUMMARY: " + str(passed_tests) + "/" + str(total_tests) + " tests passed")
	
	var pass_rate = float(passed_tests) / float(total_tests) * 100.0
	print("Pass Rate: " + str(pass_rate).pad_decimals(1) + "%")
	
	if passed_tests == total_tests:
		print("🎉 All pathfinding tests passed! A* algorithm working correctly.")
	else:
		print("⚠️  Some pathfinding tests failed. Review A* implementation.")
	
	print("=".repeat(60))
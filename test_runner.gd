extends Node
class_name TestRunner

# Main test runner that orchestrates all test suites
var test_suites: Array = [
	"res://test/test_game_mechanics.gd",
	"res://test/test_pathfinding.gd"
]

func _ready():
	print("🧪 Starting Godot Snake Game Test Suite")
	print("=".repeat(50))
	run_all_test_suites()

func run_all_test_suites():
	var total_suites = test_suites.size()
	var completed_suites = 0
	
	print("Found " + str(total_suites) + " test suites to run\n")
	
	for suite_path in test_suites:
		print("Loading test suite: " + suite_path)
		var suite_scene = load(suite_path)
		
		if suite_scene == null:
			print("❌ Failed to load test suite: " + suite_path)
			continue
		
		# Create instance of test suite
		var suite_instance = suite_scene.new()
		add_child(suite_instance)
		
		# The test suite will run automatically in its _ready() function
		completed_suites += 1
	
	# Wait a moment for all tests to complete
	await get_tree().create_timer(0.5).timeout
	
	print("\n" + "=".repeat(50))
	print("🏁 Test execution completed!")
	print("Ran " + str(completed_suites) + "/" + str(total_suites) + " test suites")
	print("Check output above for detailed results.")
	print("=".repeat(50))
	
	# Exit after all tests complete
	get_tree().quit()
# res://esi/data_driver.gd
class_name DataDriver
extends Driver

const SAVE_FILE = "user://workout_data.json"

var workouts: Dictionary = {}  # Key: date string, Value: WorkoutStructure

func save_data() -> void:
	var save_data = {}
	for date in workouts:
		save_data[date] = workouts[date].to_dict()
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
	else:
		push_error("Failed to open save file for writing")

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_FILE):
		print("No save file found. Starting with empty data.")
		return

	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		file.close()

		if parse_result == OK:
			var data = json.get_data()
			if data is Dictionary:
				workouts.clear()  # Clear existing data before loading
				var workout_count = 0
				for date in data:
					var workout = WorkoutStructure.from_dict(data[date])
					if workout and not workout.exercises.is_empty():
						workouts[date] = workout
						workout_count += 1
				print("Loaded %d workouts." % workout_count)
			else:
				push_error("Loaded data is not a Dictionary")
		else:
			push_error("Failed to parse save file")
	else:
		push_error("Failed to open save file for reading")

func get_workout(date: Dictionary) -> WorkoutStructure:
	var date_string = "%04d-%02d-%02d" % [date.year, date.month, date.day]
	if not workouts.has(date_string):
		workouts[date_string] = WorkoutStructure.new(date)
	return workouts[date_string]

func add_set_and_save(date: Dictionary, exercise_name: String, weight: float, reps: int) -> void:
	var workout = get_workout(date)
	workout.add_set(exercise_name, weight, reps)
	save_data()  # Save after each modification

func get_all_workouts() -> Array:
	return workouts.values()

func clear_all_data() -> void:
	workouts.clear()
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string("{}")
		file.close()
	else:
		push_error("Failed to open save file for writing")

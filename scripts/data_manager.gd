extends Node

var exercises: Dictionary = {}
var recorded_workout_days = {}
var current_workout: Dictionary = {}

func _ready():
	_load_exercises()
	load_data()

func _load_exercises():
	# Cable exercises
	var cable_weights = [0.0, 2.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0]
	exercises["Cable Fly"] = Exercise.new("Cable Fly", "CHEST", "cable", cable_weights, true)
	exercises["Tricep Pulldown"] = Exercise.new("Tricep Pulldown", "ARM", "cable", cable_weights, true)
	exercises["Lat Pull: Cables"] = Exercise.new("Lat Pull: Cables", "BACK", "cable", cable_weights, true)

	# Pull Ups (assisted)
	var pullup_weights = range(20, -1, -1).map(func(x): return float(x))
	exercises["Pull-Ups"] = Exercise.new("Pull-Ups", "BACK", "bodyweight", pullup_weights, false, true, 20.0, 0.0)

	# Dumbbell exercises
	var dumbbell_weights = range(5, 101, 5).map(func(x): return float(x))
	exercises["Row-to-curl"] = Exercise.new("Row-to-curl", "ARM", "dumbbell", dumbbell_weights)
	exercises["Lateral Raises"] = Exercise.new("Lateral Raises", "SHOULDER", "dumbbell", dumbbell_weights)
	exercises["Front Raises"] = Exercise.new("Front Raises", "SHOULDER", "dumbbell", dumbbell_weights)
	exercises["Alternating L.F. Raises"] = Exercise.new("Alternating L.F. Raises", "SHOULDER", "dumbbell", dumbbell_weights)
	exercises["Tricep Extensions"] = Exercise.new("Tricep Extensions", "ARM", "dumbbell", dumbbell_weights)
	exercises["Bulgarian Splits"] = Exercise.new("Bulgarian Splits", "LEG", "dumbbell", dumbbell_weights)

	# Barbell exercises
	var barbell_plates = [2.5, 5.0, 10.0, 15.0, 25.0, 35.0, 45.0]
	exercises["BBB Squats"] = Exercise.new("BBB Squats", "LEG", "barbell", barbell_plates)
	exercises["Deadlift"] = Exercise.new("Deadlift", "LEG", "barbell", barbell_plates)
	exercises["M. Deadlift"] = Exercise.new("M. Deadlift", "LEG", "barbell", barbell_plates)

func get_exercise(name: String) -> Exercise:
	return exercises.get(name)

func get_exercises_for_muscle_group(muscle_group: String) -> Array:
	return exercises.values().filter(func(ex): return ex.primary_muscle_group == muscle_group)

func record_workout_day(date):
	var date_key = "%d-%02d-%02d" % [date.year, date.month, date.day]
	recorded_workout_days[date_key] = true
	save_data()

func is_workout_day_recorded(date):
	var date_key = "%d-%02d-%02d" % [date.year, date.month, date.day]
	return date_key in recorded_workout_days

func get_last_set(exercise_name: String):
	if current_workout.has("exercises") and current_workout["exercises"].has(exercise_name):
		var sets = current_workout["exercises"][exercise_name]
		if sets.size() > 0:
			return sets[-1]
	return null

func get_current_set_number(exercise_name: String) -> int:
	if current_workout.has("exercises") and current_workout["exercises"].has(exercise_name):
		return current_workout["exercises"][exercise_name].size() + 1
	return 1

func end_workout():
	if not current_workout.is_empty():
		var date_key = "%d-%02d-%02d" % [current_workout["date"].year, current_workout["date"].month, current_workout["date"].day]
		recorded_workout_days[date_key] = current_workout
		current_workout = {}
		save_data()

func save_data():
	var save_file = FileAccess.open("user://workout_data.save", FileAccess.WRITE)
	var save_data = {
		"recorded_workout_days": recorded_workout_days,
		"current_workout": current_workout
	}
	save_file.store_var(save_data)
	save_file.close()

func load_data():
	if FileAccess.file_exists("user://workout_data.save"):
		var save_file = FileAccess.open("user://workout_data.save", FileAccess.READ)
		var save_data = save_file.get_var()
		recorded_workout_days = save_data.get("recorded_workout_days", {})
		current_workout = save_data.get("current_workout", {})
		save_file.close()
	else:
		recorded_workout_days = {}
		current_workout = {}

func start_new_workout():
	var current_date = Time.get_date_dict_from_system()
	current_workout = {
		"date": current_date,
		"exercises": {}
	}

func record_set(exercise_name: String, weight: float, reps: int):
	if not current_workout.has("exercises"):
		current_workout["exercises"] = {}
	
	if not current_workout["exercises"].has(exercise_name):
		current_workout["exercises"][exercise_name] = []
	
	current_workout["exercises"][exercise_name].append({
		"weight": weight,
		"reps": reps,
		"timestamp": Time.get_unix_time_from_system()
	})

extends Node

var exercises: Dictionary = {}
var recorded_workout_days = {}

func _ready():
	_load_exercises()

func _load_exercises():
	# Cable exercises
	var cable_weights = [0, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
	exercises["Cable Fly"] = Exercise.new("Cable Fly", "CHEST", "cable", cable_weights, true)
	exercises["Tricep Pulldown"] = Exercise.new("Tricep Pulldown", "ARM", "cable", cable_weights, true)
	exercises["Lat Pull: Cables"] = Exercise.new("Lat Pull: Cables", "BACK", "cable", cable_weights, true)

	# Pull Ups (assisted)
	var pullup_weights = range(20, -1, -1)  # 20 to 0
	exercises["Pull-Ups"] = Exercise.new("Pull-Ups", "BACK", "bodyweight", pullup_weights, false, true, 20, 0)

	# Dumbbell exercises
	var dumbbell_weights = range(5, 101, 5)  # 5 to 100 by 5s
	exercises["Row-to-curl"] = Exercise.new("Row-to-curl", "ARM", "dumbbell", dumbbell_weights)
	exercises["Lateral Raises"] = Exercise.new("Lateral Raises", "SHOULDER", "dumbbell", dumbbell_weights)
	exercises["Front Raises"] = Exercise.new("Front Raises", "SHOULDER", "dumbbell", dumbbell_weights)
	exercises["Alternating L.F. Raises"] = Exercise.new("Alternating L.F. Raises", "SHOULDER", "dumbbell", dumbbell_weights)
	exercises["Tricep Extensions"] = Exercise.new("Tricep Extensions", "ARM", "dumbbell", dumbbell_weights)
	exercises["Bulgarian Splits"] = Exercise.new("Bulgarian Splits", "LEG", "dumbbell", dumbbell_weights)

	# Barbell exercises
	var barbell_plates = [2.5, 5, 10, 15, 25, 35, 45]
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

func save_data():
	var save_file = FileAccess.open("user://workout_data.save", FileAccess.WRITE)
	save_file.store_var(recorded_workout_days)
	save_file.close()

func load_data():
	if FileAccess.file_exists("user://workout_data.save"):
		var save_file = FileAccess.open("user://workout_data.save", FileAccess.READ)
		recorded_workout_days = save_file.get_var()
		save_file.close()
	else:
		recorded_workout_days = {}

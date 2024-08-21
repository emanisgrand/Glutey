extends Node

var current_date: Dictionary
var sessions: Dictionary = {}  # Key: date string, Value: Session object
var active_session: Session
var available_exercises: Dictionary = {}

class Session:
	var date: Dictionary
	var workout: Workout

	func _init(p_date: Dictionary):
		date = p_date
		workout = Workout.new()

class Workout:
	var exercises: Dictionary = {}  # Key: exercise name, Value: Array of Sets

	func add_set(exercise_name: String, weight: float, reps: int):
		if not exercises.has(exercise_name):
			exercises[exercise_name] = []
		exercises[exercise_name].append(Set.new(weight, reps))

class Set:
	var weight: float
	var reps: int
	var timestamp: int

	func _init(p_weight: float, p_reps: int):
		weight = p_weight
		reps = p_reps
		timestamp = Time.get_unix_time_from_system()

func _ready():
	_load_exercises()
	load_data()
	set_current_date(Time.get_date_dict_from_system())

func _load_exercises():
	# Cable exercises
	var cable_weights = [0.0, 2.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0]
	available_exercises["Cable Fly"] = Exercise.new("Cable Fly", "CHEST", "cable", cable_weights, true)
	available_exercises["Tricep Pulldown"] = Exercise.new("Tricep Pulldown", "ARM", "cable", cable_weights, true)
	available_exercises["Lat Pull: Cables"] = Exercise.new("Lat Pull: Cables", "BACK", "cable", cable_weights, true)

	# Pull Ups (assisted)
	var pullup_weights = range(20, -1, -1).map(func(x): return float(x))
	available_exercises["Pull-Ups"] = Exercise.new("Pull-Ups", "BACK", "bodyweight", pullup_weights, false, true, 20.0, 0.0)

	# Dumbbell exercises
	var dumbbell_weights = range(5, 101, 5).map(func(x): return float(x))
	available_exercises["Row-to-curl"] = Exercise.new("Row-to-curl", "ARM", "dumbbell", dumbbell_weights)
	available_exercises["Lateral Raises"] = Exercise.new("Lateral Raises", "SHOULDER", "dumbbell", dumbbell_weights)
	available_exercises["Front Raises"] = Exercise.new("Front Raises", "SHOULDER", "dumbbell", dumbbell_weights)
	available_exercises["Alternating L.F. Raises"] = Exercise.new("Alternating L.F. Raises", "SHOULDER", "dumbbell", dumbbell_weights)
	available_exercises["Tricep Extensions"] = Exercise.new("Tricep Extensions", "ARM", "dumbbell", dumbbell_weights)
	available_exercises["Bulgarian Splits"] = Exercise.new("Bulgarian Splits", "LEG", "dumbbell", dumbbell_weights)

	# Barbell exercises
	var barbell_plates = [2.5, 5.0, 10.0, 15.0, 25.0, 35.0, 45.0]
	available_exercises["BBB Squats"] = Exercise.new("BBB Squats", "LEG", "barbell", [], false, false, 45.0, 0, true, barbell_plates)
	available_exercises["Deadlift"] = Exercise.new("Deadlift", "LEG", "barbell", [], false, false, 45.0, 0, true, barbell_plates)
	available_exercises["M. Deadlift"] = Exercise.new("M. Deadlift", "LEG", "barbell", [], false, false, 45.0, 0, true, barbell_plates)

func get_exercise(exercise_name: String) -> Exercise:
	return available_exercises.get(exercise_name)

func get_exercises_for_muscle_group(muscle_group: String) -> Array:
	return available_exercises.values().filter(func(ex): return ex.primary_muscle_group == muscle_group)

func set_current_date(date: Dictionary):
	current_date = date
	var date_key = _get_date_key(date)
	if not sessions.has(date_key):
		sessions[date_key] = Session.new(date)
	active_session = sessions[date_key]

func get_workout_for_date(date: Dictionary):
	var date_key = _get_date_key(date)
	return sessions.get(date_key).workout if sessions.has(date_key) else null

func is_workout_day_recorded(date: Dictionary):
	var date_key = _get_date_key(date)
	return sessions.has(date_key) and not sessions[date_key].workout.exercises.is_empty()

func get_last_set(exercise_name: String):
	if active_session.workout.exercises.has(exercise_name):
		var sets = active_session.workout.exercises[exercise_name]
		if sets.size() > 0:
			return sets[-1]
	return null

func get_current_set_number(exercise_name: String) -> int:
	if active_session.workout.exercises.has(exercise_name):
		return active_session.workout.exercises[exercise_name].size() + 1
	return 1

func record_set(exercise_name: String, weight: float, reps: int):
	active_session.workout.add_set(exercise_name, weight, reps)

func clear_data():
	sessions.clear()
	set_current_date(Time.get_date_dict_from_system())
	save_data()

func save_data():
	var save_data = {}
	for date_key in sessions:
		save_data[date_key] = _session_to_dict(sessions[date_key])
	var file = FileAccess.open("user://workout_data.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "  ", true))  # Use 2 spaces for indentation and sort keys
	file.close()

func load_data():
	if FileAccess.file_exists("user://workout_data.json"):
		var file = FileAccess.open("user://workout_data.json", FileAccess.READ)
		var json_text = file.get_as_text()
		file.close()
		
		var json = JSON.parse_string(json_text)
		if json == null:
			print("Failed to parse JSON data")
			print("Raw JSON content: ", json_text)
			return
		
		if json is Dictionary:
			for date_key in json:
				if json[date_key] is Dictionary:
					sessions[date_key] = _dict_to_session(json[date_key])
				else:
					print("Warning: Invalid data format for date ", date_key)
		elif json is Array:
			for session_data in json:
				if session_data is Dictionary and "date" in session_data:
					var date_key = _get_date_key(session_data["date"])
					sessions[date_key] = _dict_to_session(session_data)
				else:
					print("Warning: Invalid session data format")
		else:
			print("Warning: Unexpected JSON root structure")
	else:
		print("No saved data found")
	
	# Ensure we have an active session
	if sessions.is_empty():
		set_current_date(Time.get_date_dict_from_system())
	else:
		var latest_date = sessions.keys().max()
		set_current_date(_date_key_to_dict(latest_date))

func _date_key_to_dict(date_key: String) -> Dictionary:
	var parts = date_key.split("-")
	var current_date = Time.get_date_dict_from_system()
	
	return {
		"year": int(parts[0]) if parts.size() > 0 else current_date.year,
		"month": int(parts[1]) if parts.size() > 1 else current_date.month,
		"day": int(parts[2]) if parts.size() > 2 else current_date.day
	}

func _get_date_key(date: Dictionary) -> String:
	return "%d-%02d-%02d" % [date.year, date.month, date.day]

func _session_to_dict(session: Session) -> Dictionary:
	var workout_dict = {}
	for exercise in session.workout.exercises:
		workout_dict[exercise] = session.workout.exercises[exercise].map(func(set): return {"weight": set.weight, "reps": set.reps, "timestamp": set.timestamp})
	return {
		"date": _get_date_key(session.date),  # Save date as a string
		"workout": workout_dict
	}

func _dict_to_session(data: Dictionary) -> Session:
	var date_dict: Dictionary
	if "date" in data:
		if data["date"] is String:
			date_dict = _date_key_to_dict(data["date"])
		elif data["date"] is Dictionary:
			date_dict = data["date"]
		else:
			date_dict = Time.get_date_dict_from_system()
	else:
		date_dict = Time.get_date_dict_from_system()
	
	var session = Session.new(date_dict)
	if "workout" in data and data["workout"] is Dictionary:
		for exercise in data["workout"]:
			if data["workout"][exercise] is Array:
				for set_data in data["workout"][exercise]:
					if set_data is Dictionary and "weight" in set_data and "reps" in set_data:
						session.workout.add_set(exercise, float(set_data["weight"]), int(set_data["reps"]))
						if "timestamp" in set_data:
							session.workout.exercises[exercise][-1].timestamp = int(set_data["timestamp"])
	return session

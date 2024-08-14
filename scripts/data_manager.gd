extends Node

var exercise_list = {
	"CHEST": ["Cable Fly", "Push Ups", "Pec Fly"],
	"BACK": ["Row-to-curl", "Pull-Ups", "Lat Pull: Cables"],
	"SHOULDER": ["Lateral Raises", "Front Raises", "Alternating L.F. Raises"],
	"ARM": ["Tricep Pulldown", "Tricep Extensions", "Row-to-curl"],
	"LEG": ["BBB Squats", "Bulgarian Splits", "Deadlift", "M. Deadlift"]
}

var recorded_workout_days = {}

func get_exercises_for_muscle_group(muscle_group: String) -> Array:
	return exercise_list.get(muscle_group, [])

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

func _ready():
	load_data()

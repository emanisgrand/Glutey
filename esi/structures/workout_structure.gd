# res://esi/structures/workout_structure.gd
class_name WorkoutStructure
extends Structure

var date: Dictionary
var exercises: Dictionary  # Key: exercise name, Value: Array of SetData

class SetData:
	var weight: float
	var reps: int

	func _init(p_weight: float, p_reps: int):
		weight = p_weight
		reps = p_reps

	func to_dict() -> Dictionary:
		return {
			"weight": weight,
			"reps": reps
		}

	static func from_dict(data: Dictionary) -> SetData:
		return SetData.new(float(data["weight"]), int(data["reps"]))

func _init(p_date: Dictionary):
	date = p_date

func add_set(exercise_name: String, weight: float, reps: int):
	if not exercises.has(exercise_name):
		exercises[exercise_name] = []
	exercises[exercise_name].append(SetData.new(weight, reps))

func to_dict() -> Dictionary:
	var exercise_dict = {}
	for exercise in exercises:
		exercise_dict[exercise] = exercises[exercise].map(func(set_data): return set_data.to_dict())
	
	return {
		"date": date,
		"exercises": exercise_dict
	}

static func from_dict(data: Dictionary) -> WorkoutStructure:
	var date_dict = {}
	if data["date"] is String:
		var date_parts = data["date"].split("-")
		if date_parts.size() == 3:
			date_dict = {
				"year": int(date_parts[0]),
				"month": int(date_parts[1]),
				"day": int(date_parts[2])
			}
	elif data["date"] is Dictionary:
		date_dict = data["date"]
	else:
		push_error("Invalid date format in workout data")
		return null

	var workout = WorkoutStructure.new(date_dict)
	if data.has("exercises") and data["exercises"] is Dictionary:
		for exercise in data["exercises"]:
			if data["exercises"][exercise] is Array:
				for set_data in data["exercises"][exercise]:
					if set_data is Dictionary and set_data.has("weight") and set_data.has("reps"):
						workout.add_set(exercise, float(set_data["weight"]), int(set_data["reps"]))
	return workout

extends Node

var exercise_list = {
	"CHEST": ["Cable Fly", "Push Ups", "Pec Fly"],
	"BACK": ["Row-to-curl", "Pull-Ups", "Lat Pull: Cables"],
	"SHOULDER": ["Lateral Raises", "Front Raises", "Alternating L.F. Raises"],
	"ARM": ["Tricep Pulldown", "Tricep Extensions", "Row-to-curl"],
	"LEG": ["BBB Squats", "Bulgarian Splits", "Deadlift", "M. Deadlift"]
}

func get_exercises_for_muscle_group(muscle_group: String) -> Array:
	return exercise_list.get(muscle_group, [])

# res://esi/structures/workout_constants.gd
class_name WorkoutConstants
extends Resource

enum MuscleGroup {
	ARMS,
	CHEST,
	BACK,
	SHOULDERS,
	LEGS,
	CORE
}

enum MuscleSubgroup {
	# Arms
	BICEPS,
	TRICEPS,
	FOREARMS,
	# Chest
	UPPER_CHEST,
	LOWER_CHEST,
	# Back
	LATS,
	TRAPS,
	LOWER_BACK,
	# Shoulders
	FRONT_DELTS,
	SIDE_DELTS,
	REAR_DELTS,
	# Legs
	QUADS,
	HAMSTRINGS,
	CALVES,
	# Core
	ABS,
	OBLIQUES
}

const MUSCLE_HIERARCHY = {
	MuscleGroup.ARMS: [MuscleSubgroup.BICEPS, MuscleSubgroup.TRICEPS, MuscleSubgroup.FOREARMS],
	MuscleGroup.CHEST: [MuscleSubgroup.UPPER_CHEST, MuscleSubgroup.LOWER_CHEST],
	MuscleGroup.BACK: [MuscleSubgroup.LATS, MuscleSubgroup.TRAPS, MuscleSubgroup.LOWER_BACK],
	MuscleGroup.SHOULDERS: [MuscleSubgroup.FRONT_DELTS, MuscleSubgroup.SIDE_DELTS, MuscleSubgroup.REAR_DELTS],
	MuscleGroup.LEGS: [MuscleSubgroup.QUADS, MuscleSubgroup.HAMSTRINGS, MuscleSubgroup.CALVES],
	MuscleGroup.CORE: [MuscleSubgroup.ABS, MuscleSubgroup.OBLIQUES]
}

enum EquipmentType {
	DUMBBELL,
	BARBELL,
	MACHINE,
	CABLE,
	BODYWEIGHT
}

const EXERCISES = {
	"Bench Press": {
		"muscle_group": MuscleGroup.CHEST,
		"equipment_type": EquipmentType.BARBELL,
		"increments": [45.0, 55.0, 65.0, 75.0, 85.0, 95.0, 105.0, 115.0, 125.0, 135.0],
		"starting_weight": 45.0
	},
	"Squat": {
		"muscle_group": MuscleGroup.LEGS,
		"equipment_type": EquipmentType.BARBELL,
		"increments": [45.0, 65.0, 85.0, 105.0, 125.0, 145.0, 165.0, 185.0, 205.0, 225.0],
		"starting_weight": 45.0
	},
	# Add more exercises as needed
}

static func get_muscle_group_name(group: MuscleGroup) -> String:
	return MuscleGroup.keys()[group]

static func get_muscle_subgroup_name(subgroup: MuscleSubgroup) -> String:
	return MuscleSubgroup.keys()[subgroup]

static func get_equipment_type_name(type: EquipmentType) -> String:
	return EquipmentType.keys()[type]

static func get_subgroups_for_group(group: MuscleGroup) -> Array[MuscleSubgroup]:
	return MUSCLE_HIERARCHY[group]

static func get_group_for_subgroup(subgroup: MuscleSubgroup) -> MuscleGroup:
	for group in MUSCLE_HIERARCHY:
		if subgroup in MUSCLE_HIERARCHY[group]:
			return group
	return MuscleGroup.ARMS  # Default to ARMS if not found

static func get_random_exercise() -> Dictionary:
	var exercise_names = EXERCISES.keys()
	var random_index = randi() % exercise_names.size()
	var exercise_name = exercise_names[random_index]
	return {
		"name": exercise_name,
		"data": EXERCISES[exercise_name]
	}

# You can add more static methods here for additional functionality

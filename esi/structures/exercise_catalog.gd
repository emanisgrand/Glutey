# res://esi/structures/exercise_catalog.gd
class_name ExerciseCatalog
extends Structure

var exercises: Dictionary = {}  # Key: exercise name (String), Value: ExerciseStructure

func add_exercise(exercise: ExerciseStructure):
	exercises[exercise.name] = exercise

func get_exercise_by_name(name: String) -> ExerciseStructure:
	return exercises.get(name)

func get_all_exercises() -> Array[ExerciseStructure]:
	return exercises.values()

func get_exercises_for_muscle_group(group: WorkoutConstants.MuscleGroup) -> Array[ExerciseStructure]:
	return exercises.values().filter(func(ex): return ex.primary_muscle_group == group)

func get_exercises_for_muscle_subgroup(subgroup: WorkoutConstants.MuscleSubgroup) -> Array[ExerciseStructure]:
	return exercises.values().filter(func(ex): 
		return ex.primary_muscle_subgroup == subgroup or subgroup in ex.secondary_muscle_subgroups
	)

func get_exercises_for_equipment_type(type: WorkoutConstants.EquipmentType) -> Array[ExerciseStructure]:
	return exercises.values().filter(func(ex): return ex.equipment.type == type)

# Add additional methods here as needed for querying or managing the exercise catalog

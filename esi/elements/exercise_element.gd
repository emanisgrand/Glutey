# res://esi/elements/exercise_element.gd
class_name ExerciseElement
extends Element

var exercise_structure: ExerciseStructure
var current_weight: float
var current_reps: int

func _init(p_id: int, p_exercise_structure: ExerciseStructure):
	super(p_id)
	exercise_structure = p_exercise_structure
	current_weight = p_exercise_structure.starting_weight
	current_reps = 0

func get_exercise_name() -> String:
	return exercise_structure.name

func get_primary_muscle_group() -> WorkoutConstants.MuscleGroup:
	return exercise_structure.primary_muscle_group

func get_primary_muscle_subgroup() -> WorkoutConstants.MuscleSubgroup:
	return exercise_structure.primary_muscle_subgroup

func get_equipment_type() -> WorkoutConstants.EquipmentType:
	return exercise_structure.equipment.type

func get_increments() -> Array[float]:
	return exercise_structure.equipment.increments

func has_mod_plate() -> bool:
	return exercise_structure.equipment.has_mod_plate

func is_reverse_progression() -> bool:
	return exercise_structure.is_reverse_progression

func has_max_weight() -> bool:
	return exercise_structure.has_max_weight()

func get_max_weight() -> float:
	return exercise_structure.max_weight

# res://esi/structures/exercise_structure.gd
class_name ExerciseStructure
extends Structure

const NO_MAX_WEIGHT = -1.0  # Special value to indicate no maximum weight

@export var name: String
@export var primary_muscle_group: WorkoutConstants.MuscleGroup
@export var primary_muscle_subgroup: WorkoutConstants.MuscleSubgroup
@export var secondary_muscle_groups: Array[WorkoutConstants.MuscleGroup]
@export var secondary_muscle_subgroups: Array[WorkoutConstants.MuscleSubgroup]
@export var equipment: EquipmentStructure
@export var is_reverse_progression: bool
@export var starting_weight: float
@export var max_weight: float  # Use NO_MAX_WEIGHT for exercises with no upper limit

func _init(p_name: String, p_primary_muscle_group: WorkoutConstants.MuscleGroup, 
		   p_primary_muscle_subgroup: WorkoutConstants.MuscleSubgroup, p_equipment: EquipmentStructure, 
		   p_is_reverse_progression: bool, p_starting_weight: float, p_max_weight: float = NO_MAX_WEIGHT,
		   p_secondary_muscle_groups: Array[WorkoutConstants.MuscleGroup] = [], 
		   p_secondary_muscle_subgroups: Array[WorkoutConstants.MuscleSubgroup] = []):
	name = p_name
	primary_muscle_group = p_primary_muscle_group
	primary_muscle_subgroup = p_primary_muscle_subgroup
	secondary_muscle_groups = p_secondary_muscle_groups
	secondary_muscle_subgroups = p_secondary_muscle_subgroups
	equipment = p_equipment
	is_reverse_progression = p_is_reverse_progression
	starting_weight = p_starting_weight
	max_weight = p_max_weight

func has_max_weight() -> bool:
	return max_weight != NO_MAX_WEIGHT

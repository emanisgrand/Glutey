class_name Exercise
extends RefCounted

var name: String
var primary_muscle_group: String
var equipment_type: String
var weight_increments: Array
var has_mod_plate: bool
var is_reverse_progression: bool
var starting_weight: float
var max_weight: float

func _init(p_name: String, p_muscle_group: String, p_equipment: String, 
		   p_increments: Array, p_has_mod: bool = false, 
		   p_reverse: bool = false, p_start: float = 0, p_max: float = 100):
	name = p_name
	primary_muscle_group = p_muscle_group
	equipment_type = p_equipment
	weight_increments = p_increments
	has_mod_plate = p_has_mod
	is_reverse_progression = p_reverse
	starting_weight = p_start
	max_weight = p_max

func get_next_weight(current_weight: float, increase: bool) -> float:
	var index = weight_increments.find(current_weight)
	if index == -1:
		# If the current weight is not in the increments, find the nearest value
		index = 0
		for i in range(weight_increments.size()):
			if abs(weight_increments[i] - current_weight) < abs(weight_increments[index] - current_weight):
				index = i
	
	if increase:
		return weight_increments[min(index + 1, weight_increments.size() - 1)]
	else:
		return weight_increments[max(index - 1, 0)]

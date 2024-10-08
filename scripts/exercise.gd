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
var is_barbell: bool
var barbell_plates: Array

func _init(p_name: String, p_muscle_group: String, p_equipment: String, 
		   p_increments: Array, p_has_mod: bool = false, 
		   p_reverse: bool = false, p_start: float = 0, p_max: float = 100,
		   p_is_barbell: bool = false, p_barbell_plates: Array = []):
	name = p_name
	primary_muscle_group = p_muscle_group
	equipment_type = p_equipment
	weight_increments = p_increments
	has_mod_plate = p_has_mod
	is_reverse_progression = p_reverse
	starting_weight = p_start
	max_weight = p_max
	is_barbell = p_is_barbell
	barbell_plates = p_barbell_plates

func get_next_weight(current_weight: float, increase: bool) -> float:
	if is_barbell:
		# For barbell exercises, we'll handle weight increases differently
		var base_weight = 45.0  # The weight of the barbell
		var added_weight = current_weight - base_weight
		var plate_weight = added_weight / 2  # Total weight added divided by 2 (for both sides)
		
		var next_plate_index = barbell_plates.find(plate_weight)
		if next_plate_index == -1:
			# If the current weight is not in the increments, find the nearest value
			next_plate_index = 0
			for i in range(barbell_plates.size()):
				if abs(barbell_plates[i] - plate_weight) < abs(barbell_plates[next_plate_index] - plate_weight):
					next_plate_index = i
		
		if increase:
			next_plate_index = min(next_plate_index + 1, barbell_plates.size() - 1)
		else:
			next_plate_index = max(next_plate_index - 1, 0)
		
		return base_weight + (barbell_plates[next_plate_index] * 2)
	else:
		# Original logic for non-barbell exercises
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

# res://esi/instructions/exercise_instructions.gd
class_name ExerciseInstructions
extends Instruction

static func update_weight(element: ExerciseElement, new_weight: float) -> void:
	if new_weight >= 0 and (not element.has_max_weight() or new_weight <= element.get_max_weight()):
		element.current_weight = new_weight
	else:
		push_error("Invalid weight for exercise: " + str(new_weight))

static func record_set(element: ExerciseElement, reps: int) -> void:
	if reps > 0:
		element.current_reps = reps
	else:
		push_error("Invalid number of reps: " + str(reps))

static func calculate_progression(element: ExerciseElement) -> float:
	var increments = element.get_increments()
	var current_index = increments.find(element.current_weight)
	
	if current_index == -1:
		# If the current weight is not in the increments, find the nearest value
		current_index = 0
		for i in range(increments.size()):
			if abs(increments[i] - element.current_weight) < abs(increments[current_index] - element.current_weight):
				current_index = i
	
	var next_index = current_index + (1 if not element.is_reverse_progression() else -1)
	next_index = clamp(next_index, 0, increments.size() - 1)
	
	return increments[next_index]

static func complete_exercise(element: ExerciseElement) -> void:
	element.current_reps = 0
	# Additional logic for exercise completion can be added here

static func reset_exercise(element: ExerciseElement) -> void:
	element.current_weight = element.exercise_structure.starting_weight
	element.current_reps = 0

static func adjust_weight_with_mod_plate(element: ExerciseElement, use_mod_plate: bool) -> float:
	if element.has_mod_plate():
		var adjusted_weight = element.current_weight + (0.5 if use_mod_plate else 0)
		return adjusted_weight
	else:
		return element.current_weight

# res://esi/exercise_driver.gd
class_name ExerciseDriver
extends Driver

var exercise_catalog: ExerciseCatalog
var exercise_elements: Dictionary = {}
var next_id: int = 0

func _init():
	exercise_catalog = ExerciseCatalog.new()

func add_exercise_structure(exercise: ExerciseStructure):
	exercise_catalog.add_exercise(exercise)

func create_exercise_element(exercise_name: String) -> ExerciseElement:
	var structure = exercise_catalog.get_exercise_by_name(exercise_name)
	if structure:
		var id = next_id
		next_id += 1
		var element = ExerciseElement.new(id, structure)
		exercise_elements[id] = element
		return element
	return null

func get_exercise_element(id: int) -> ExerciseElement:
	return exercise_elements.get(id)

func update_exercise_weight(element_id: int, new_weight: float) -> void:
	var element = get_exercise_element(element_id)
	if element:
		ExerciseInstructions.update_weight(element, new_weight)

func record_exercise_set(element_id: int, reps: int) -> void:
	var element = get_exercise_element(element_id)
	if element:
		ExerciseInstructions.record_set(element, reps)

func progress_exercise(element_id: int) -> void:
	var element = get_exercise_element(element_id)
	if element:
		var new_weight = ExerciseInstructions.calculate_progression(element)
		ExerciseInstructions.update_weight(element, new_weight)

func complete_exercise(element_id: int) -> void:
	var element = get_exercise_element(element_id)
	if element:
		ExerciseInstructions.complete_exercise(element)

func reset_exercise(element_id: int) -> void:
	var element = get_exercise_element(element_id)
	if element:
		ExerciseInstructions.reset_exercise(element)

func adjust_weight_with_mod_plate(element_id: int, use_mod_plate: bool) -> float:
	var element = get_exercise_element(element_id)
	if element:
		return ExerciseInstructions.adjust_weight_with_mod_plate(element, use_mod_plate)
	return 0.0

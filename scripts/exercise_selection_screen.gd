extends Control

signal exercise_selected(exercise_name: String)

@onready var grid_container = $ExerciseListGrid
@onready var exercise_card_scene = preload("res://scenes/exercise_cardV2.tscn")
@onready var header_label = $"SELECT EXERCISE"

var current_muscle_group: String = ""

func set_muscle_group(group: String):
	current_muscle_group = group
	header_label.text = group + " EXERCISES"
	_populate_exercise_grid()

func _populate_exercise_grid():
	for child in grid_container.get_children():
		child.queue_free()
	
	if not DataManager:
		print("DataManager not found. Check Autoloads")
		return
	
	var exercises = DataManager.get_exercises_for_muscle_group(current_muscle_group)
	if exercises.is_empty():
		print("No exercises found for muscle group: ", current_muscle_group)
		return
		
	for exercise in exercises:
		var card = exercise_card_scene.instantiate()
		card.set_exercise_name(exercise)
		card.connect("exercise_selected", _on_exercise_selected)
		grid_container.add_child(card)

func _on_exercise_selected(exercise_name: String):
	print("Selected exercise: ", exercise_name)
	emit_signal("exercise_selected", exercise_name)
	var ui_manager = get_node("/root/UIManager")
	if ui_manager:
		ui_manager.set_entry_screen.set_exercise(exercise_name)
		ui_manager.change_screen("set_entry")
	else:
		print("UI Manager not found")
	# For now, we'll just print the selected exercise name

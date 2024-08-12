extends Control

@onready var grid_container = $ExerciseListGrid
@onready var exercise_card_scene = preload("res://scenes/exercise_card.tscn")
@onready var header_label = $"SELECT EXERCISE"
@onready var ui_manager = $".."

var current_muscle_group: String = ""


func set_muscle_group(group: String):
	current_muscle_group = group
	header_label.text = group + " EXERCISES"
	_populate_exercise_grid()

func _populate_exercise_grid():
	for child in grid_container.get_children():
		child.queue_free()
	
	var exercises = DataManager.get_exercises_for_muscle_group(current_muscle_group)
	for exercise in exercises:
		var card = exercise_card_scene.instantiate()
		card.get_node("ExerciseLabel").text = exercise
		card.pressed.connect(_on_exercise_card_pressed.bind(exercise))
		grid_container.add_child(card)

func _on_exercise_card_pressed(exercise_name: String):
		# Direct screen change
	var ui_manager = get_node("/root/UIManager")  # Adjust this path if necessary
	if ui_manager:
		var set_entry_screen = ui_manager.get_node("SetEntryScreen")  # Adjust this path if necessary
		if set_entry_screen:
			set_entry_screen.set_exercise(exercise_name)
			ui_manager.change_screen(set_entry_screen)
		else:
			print("SetEntryScreen not found")
	else:
		print("UIManager not found")

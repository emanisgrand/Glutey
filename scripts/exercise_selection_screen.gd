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
	
	var exercises = DataManager.get_exercises_for_muscle_group(current_muscle_group)
	for exercise in exercises:
		var card = exercise_card_scene.instantiate()
		var label = card.get_node("ExerciseLabel")
		if label:
			label.text = exercise.name
		else:
			push_error("ExerciseLabel not found in card.")
		card.connect("pressed", _on_exercise_card_pressed.bind(exercise.name))
		grid_container.add_child(card)

func _on_exercise_card_pressed(exercise_name: String):
	emit_signal("exercise_selected", exercise_name)

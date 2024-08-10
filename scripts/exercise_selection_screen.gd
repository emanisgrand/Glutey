extends Control

@onready var grid_container = $ExerciseListGrid
@onready var exercise_card_scene = preload("res://scenes/exercise_card.tscn")
@onready var header_label = $"SELECT EXERCISE"
@onready var ui_manager = $".."

var current_muscle_group: String = ""

func _ready():
	if ui_manager:
		connect("exercise_selected", ui_manager._on_exercise_selected)
		print("Manually connected exercise_selected signal")
	else:
		print("Failed to find UI Manager node")

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
	emit_signal("exercise_selected", exercise_name)
	print("Exercise selected: ", exercise_name)

extends Control
@onready var completed_set_container = $CompletedSetContainer/VBoxContainer
@onready var completed_set_card_scene = preload("res://scenes/completed_set_card.tscn")

signal muscle_group_selected(group: String)

var current_exercise: String = ""
var sets_data: Array = []

func _ready():
	var muscle_group_buttons = $MuscleGroups/VBoxContainer.get_children()
	for button in muscle_group_buttons:
		if button is Button:
			button.pressed.connect(_on_muscle_group_button_pressed.bind(button.name))

func _on_muscle_group_button_pressed(button_name: String):
	var muscle_group = button_name.replace("Button", "").to_upper()
	emit_signal("muscle_group_selected", muscle_group)

func set_current_exercise(exercise_name: String):
	current_exercise = exercise_name
	sets_data.clear()

func add_set(exercise:String, weight: int, reps: int):
	var new_set_card = completed_set_card_scene.instantiate()
	new_set_card.set_set_data(exercise, weight, reps)
	completed_set_container.add_child(new_set_card)

func update_completed_sets_display():
	# Clear existing set cards
	for child in completed_set_container.get_children():
		child.queue_free()
	
	# Add new set cards
	for i in range(sets_data.size()):
		var set_data = sets_data[i]
		var set_card = completed_set_card_scene.instantiate()
		
		set_card.get_node("ExerciseLabel").text = current_exercise
		set_card.get_node("CompletedSetGrid/CompletedSetLabel").text = "%d\n%d\n%d" % [i + 1, set_data.weight, set_data.reps]
		
		completed_set_container.add_child(set_card)

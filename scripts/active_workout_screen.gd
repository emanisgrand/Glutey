extends Control

@onready var completed_set_container = $CompletedSetStack/VBoxContainer
@onready var completed_set_card_scene = preload("res://scenes/completed_set_card.tscn")

signal muscle_group_selected(group: String)
signal existing_set_selected(exercise: String, set_number: int, weight: int, reps: int)

var exercise_cards: Dictionary = {}

func _ready():
	var muscle_group_buttons = $MuscleGroups/VBoxContainer.get_children()
	for button in muscle_group_buttons:
		if button is Button:
			button.pressed.connect(_on_muscle_group_button_pressed.bind(button.name))

func _on_muscle_group_button_pressed(button_name: String):
	var muscle_group = button_name.replace("Button", "").to_upper()
	emit_signal("muscle_group_selected", muscle_group)

func set_current_exercise(exercise_name: String):
	if not exercise_cards.has(exercise_name):
		var new_card = completed_set_card_scene.instantiate()
		new_card.set_exercise(exercise_name)
		new_card.connect("set_selected", _on_set_selected)
		completed_set_container.add_child(new_card)
		exercise_cards[exercise_name] = new_card

func add_set(exercise:String, weight: int, reps: int):
	if not exercise_cards.has(exercise):
		set_current_exercise(exercise)
	
	var card = exercise_cards[exercise]
	var set_number = card.get_last_set_number() + 1
	card.add_set(set_number,weight,reps)

func _on_set_selected(exercise: String, set_number: int, weight: int, reps: int):
	emit_signal("existing_set_selected", exercise, set_number, weight, reps)

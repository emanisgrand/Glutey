extends Control

@onready var workout_mode_bg = $WorkoutModeBG
@onready var workout_complete_bg = $WorkoutCompleteBG
@onready var completed_set_container = $CompletedSetStack/VBoxContainer
@onready var muscle_group_buttons = $MuscleGroups/VBoxContainer.get_children()
@onready var completed_set_card_scene = preload("res://scenes/completed_set_card.tscn")

var is_view_only = false

signal muscle_group_selected(group: String)
signal existing_set_selected(exercise: String, set_number: int, weight: int, reps: int)

var exercise_cards: Dictionary = {}

func _ready():
	for button in muscle_group_buttons:
		if button is Button:
			button.pressed.connect(_on_muscle_group_button_pressed.bind(button.name))

func set_view_only_mode(enable:bool):
	is_view_only = enable
	workout_mode_bg.visible = !enable
	workout_complete_bg.visible = enable
	
	for button in muscle_group_buttons:
		if button is Button:
			button.disabled = enable
	
	for set_card in completed_set_container.get_children():
		if set_card.has_method("set_interactive"):
			set_card.set_interactive(!enable)

func _on_muscle_group_button_pressed(button_name: String):
	if not is_view_only:
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
	if not is_view_only:
		if not exercise_cards.has(exercise):
			set_current_exercise(exercise)
	
		var card = exercise_cards[exercise]
		var set_number = card.get_last_set_number() + 1
		card.add_set(set_number,weight,reps)
		pass

func _on_set_selected(exercise: String, set_number: int, weight: int, reps: int):
	if not is_view_only:
		emit_signal("existing_set_selected", exercise, set_number, weight, reps)

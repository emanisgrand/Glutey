extends Control

signal set_recorded(exercise: String, weight: int, reps: int)

@onready var rep_label = $RepControl/RepLabel
@onready var weight_label = $WeightControl/WeightLabel
@onready var exercise_label = $ScreenTitle/Label
@onready var enter_set_button = $EnterSetButton
@onready var mod_plate_checkbox: CheckBox = $ModPlateCheckbox

var rep_count = 1
var weight = 1
var current_exercise: Exercise = null

func _ready():
	update_rep_display()
	update_weight_display()
	enter_set_button.connect("pressed", _on_enter_set_button_pressed)
	if mod_plate_checkbox:
		mod_plate_checkbox.connect("toggled", _on_mod_plate_toggled)

func set_exercise(exercise_name: String, set_weight:float = 0.0, set_reps: int=1):
	current_exercise = DataManager.get_exercise(exercise_name)
	weight = set_weight if set_weight > 0 else current_exercise.starting_weight
	rep_count = set_reps
	
	if exercise_label:
		exercise_label.text = exercise_name
	else:
		push_error("Exercise label not found in SetEntryScreen")
	
	update_weight_display()
	update_rep_display()
	update_ui_for_exercise()

# Weights
func increase_weight():
	weight = current_exercise.get_next_weight(weight, true)
	update_weight_display()

func decrease_weight():
	weight = current_exercise.get_next_weight(weight, false)
	update_weight_display()

func update_weight_display():
	var display_weight = weight
	if current_exercise.has_mod_plate and mod_plate_checkbox and mod_plate_checkbox.button_pressed:
		display_weight += 0.5
	weight_label.text = str(display_weight)

func update_ui_for_exercise():
	if mod_plate_checkbox:
		mod_plate_checkbox.visible = current_exercise.has_mod_plate
	# Here you would update the weight image texture based on the exercise type
	# For example:
	# $WeightControl/WeightImage.texture = load("res://assets/textures/" + current_exercise.equipment_type + "_weight.png")

func _on_mod_plate_toggled(_button_pressed):
	update_weight_display()

# Reps 
func increase_reps():
	rep_count += 1
	update_rep_display()

func decrease_reps():
	if rep_count > 0:
		rep_count -= 1
		update_rep_display()

func update_rep_display():
	rep_label.text = str(rep_count)

# Set button
func _on_enter_set_button_pressed():
	emit_signal("set_recorded", current_exercise, weight, rep_count)
	rep_count = 1
	weight = 1
	update_rep_display()
	update_weight_display()

# Connected signals
func _on_more_weight_pressed():
	increase_weight()

func _on_less_weight_pressed():
	decrease_weight()

func _on_more_reps_pressed():
	increase_reps()

func _on_less_reps_pressed():
	decrease_reps()

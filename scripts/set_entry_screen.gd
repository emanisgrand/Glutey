extends Control

signal set_recorded(exercise: String, weight: float, reps: int)

@onready var rep_label = $RepControl/RepLabel
@onready var weight_label = $WeightControl/WeightLabel
@onready var exercise_label = $ScreenTitle/Label
@onready var enter_set_button = $EnterSetButton
@onready var mod_plate_checkbox: CheckBox = $ModPlateCheckbox
@onready var weight_image: TextureRect = $WeightControl/WeightImage


var rep_count = 1
var weight: float = 0.0
var current_exercise: Exercise = null
var previous_weight: float = 0.0
var previous_reps: int = 0
var is_first_set: bool = true

# Define color constants
const COLOR_DEFAULT = Color.WHITE
const COLOR_INCREASE = Color.GREEN
const COLOR_DECREASE = Color.BLUE

func _ready():
	weight_label.text = str(int(weight))
	rep_label.text = str(rep_count)
	enter_set_button.connect("pressed", _on_enter_set_button_pressed)
	if mod_plate_checkbox:
		mod_plate_checkbox.connect("toggled", _on_mod_plate_toggled)
		mod_plate_checkbox.visible = false

func set_exercise(exercise_name: String, set_weight: float = 0.0, set_reps: int = 1):
	current_exercise = DataManager.get_exercise(exercise_name)
	if current_exercise:
		weight = set_weight if set_weight > 0 else current_exercise.starting_weight
		rep_count = set_reps
		
		if exercise_label:
			exercise_label.text = exercise_name
		else:
			push_error("Exercise label not found in SetEntryScreen")
		
		update_weight_display()
		update_rep_display()
		update_ui_for_exercise()
		
		# Reset previous values and first set flag
		previous_weight = weight
		previous_reps = rep_count
		is_first_set = true
	else:
		push_error("Exercise not found: " + exercise_name)

func increase_weight():
	if current_exercise:
		weight = current_exercise.get_next_weight(weight, true)
		update_weight_display()
	else:
		push_error("Tried to increase weight with no exercise selected")

func decrease_weight():
	if current_exercise:
		weight = current_exercise.get_next_weight(weight, false)
		update_weight_display()
	else:
		push_error("Tried to decrease weight with no exercise selected")

func update_weight_display():
	if current_exercise == null:
		weight_label.text = "0"
		return
	
	var display_weight = weight
	if current_exercise.has_mod_plate and mod_plate_checkbox and mod_plate_checkbox.button_pressed:
		display_weight += 0.5
		weight_label.text = "%.1f" % display_weight
	else:
		weight_label.text = str(int(display_weight))
		
	update_label_color(weight_label, display_weight, previous_weight)

func update_ui_for_exercise():
	if mod_plate_checkbox:
		mod_plate_checkbox.visible = current_exercise.has_mod_plate
	
	var image_path = "res://assets/textures/ui/"
	match current_exercise.equipment_type:
		"dumbbell":
			image_path += "dumbell_weights.svg"
		"cable":
			image_path += "cable_weights.svg"
		_:
			# Default to dumbbell image if no specific image is available
			image_path += "dumbell_weights.svg"
	
	var texture = load(image_path)
	if texture:
		weight_image.texture = texture
	else:
		push_error("Failed to load texture: " + image_path)

func _on_mod_plate_toggled(_button_pressed):
	update_weight_display()

func increase_reps():
	rep_count += 1
	update_rep_display()

func decrease_reps():
	if rep_count > 1:
		rep_count -= 1
		update_rep_display()

func update_rep_display():
	rep_label.text = str(rep_count)
	update_label_color(rep_label, rep_count, previous_reps)

func update_label_color(label: Label, current_value, previous_value):
	if is_first_set:
		label.add_theme_color_override("font_color", COLOR_DEFAULT)
	elif current_value > previous_value:
		label.add_theme_color_override("font_color", COLOR_INCREASE)
	elif current_value < previous_value:
		label.add_theme_color_override("font_color", COLOR_DECREASE)
	else:
		label.add_theme_color_override("font_color", COLOR_DEFAULT)

func _on_enter_set_button_pressed():
	if current_exercise:
		var final_weight = weight
		if current_exercise.has_mod_plate and mod_plate_checkbox.button_pressed:
			final_weight += 0.5
		emit_signal("set_recorded", current_exercise.name, final_weight, rep_count)
		
		# Update previous values and set first_set flag to false
		previous_weight = final_weight
		previous_reps = rep_count
		is_first_set = false
		
		# Reset rep count and weight for the next set
		rep_count = 1
		weight = current_exercise.starting_weight
		update_rep_display()
		update_weight_display()
	else:
		push_error("No exercise selected when trying to record set")

func _on_more_weight_pressed():
	increase_weight()

func _on_less_weight_pressed():
	decrease_weight()

func _on_more_reps_pressed():
	increase_reps()

func _on_less_reps_pressed():
	decrease_reps()

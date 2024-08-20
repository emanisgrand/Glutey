extends Control

@warning_ignore("unused_signal")
signal set_recorded(exercise: String, weight: float, reps: int)

@onready var rep_label = $RepControl/RepLabel
@onready var weight_label = $WeightControl/WeightLabel
@onready var exercise_label = $ScreenTitle/Label
@onready var enter_set_button = $EnterSetButton
@onready var mod_plate_checkbox: CheckBox = $ModPlateCheckbox
@onready var weight_image = $WeightControl/WeightImage
@onready var bb_weight_mod = $WeightControl/BBWeightMod

# Data 
var rep_count = 1
var weight: float = 0.0
var current_exercise: Exercise = null
var last_recorded_weight: float = weight
var last_recorded_reps: int = rep_count
var initial_weight: float = 0.0
var initial_reps: int = 0
var current_barbell_plate: float = 0.0

# UI
var current_barbell_button: Button = null
var selected_style: StyleBoxFlat
var default_style: StyleBoxFlat

	# Load LabelSettings resources
var increase_color: LabelSettings = preload("res://assets/ui/styles_&_settings/increase_color.tres")
var decrease_color: LabelSettings = preload("res://assets/ui/styles_&_settings/decrease_color.tres")
var default_color: LabelSettings = preload("res://assets/ui/styles_&_settings/default_color.tres")

func _ready():
	weight_label.text = str(int(weight))
	rep_label.text = str(rep_count)
	enter_set_button.connect("pressed", _on_enter_set_button_pressed)
	if mod_plate_checkbox:
		mod_plate_checkbox.connect("toggled", _on_mod_plate_toggled)
		mod_plate_checkbox.visible = false

	# Set default label settings
	weight_label.label_settings = default_color
	rep_label.label_settings = default_color
	
	selected_style = load("res://assets/ui/styles_&_settings/selected_button_style.tres")
	
	# Store the default style
	if bb_weight_mod.get_child_count() > 0:
		default_style = bb_weight_mod.get_child(0).get_theme_stylebox("normal").duplicate()
	
	for button in bb_weight_mod.get_children():
		var bb_weight = float(button.text.strip_edges())
		button.connect("pressed", _on_barbell_plate_selected.bind(bb_weight, button))

func set_exercise(exercise_name: String, set_weight: float = 0.0, set_reps: int = 1):
	current_exercise = DataManager.get_exercise(exercise_name)
	if current_exercise:
		var last_set = DataManager.get_last_set(exercise_name)
		if last_set:
			weight = last_set["weight"]
			rep_count = last_set["reps"]
		else:
			weight = set_weight if set_weight > 0 else current_exercise.starting_weight
			rep_count = set_reps
		
		weight = set_weight if set_weight > 0 else current_exercise.starting_weight
		rep_count = set_reps
		last_recorded_weight = 0
		last_recorded_reps = 0
		initial_weight = weight
		initial_reps = rep_count
		
		if exercise_label:
			exercise_label.text = exercise_name
		else:
			push_error("Exercise label not found in SetEntryScreen")
		
		update_weight_display()
		update_rep_display()
		update_ui_for_exercise()
	else:
		push_error("Exercise not found: " + exercise_name)
	reset_barbell_buttons()

func reset_barbell_buttons():
	if current_barbell_button:
		current_barbell_button.add_theme_stylebox_override("normal", default_style)
	current_barbell_button = null

func adjust_value(current: float, is_increase: bool, get_next_func: Callable) -> float:
	current = get_next_func.call(current, is_increase)
	if DataManager.get_current_set_number(current_exercise.name) > 1:
		var label = weight_label if get_next_func == current_exercise.get_next_weight else rep_label
		var last_set = DataManager.get_last_set(current_exercise.name)
		if last_set:
			var last_value = last_set["weight"] if label == weight_label else last_set["reps"]
			update_label_color(label, current, last_value)
	return current
	
func increase_weight():
	if current_exercise:
		if current_exercise.is_barbell:
			weight += current_barbell_plate * 2
		else:
			weight = adjust_value(weight, true, current_exercise.get_next_weight)
		update_weight_display()
	else:
		push_error("Tried to increase weight with no exercise selected")

func decrease_weight():
	if current_exercise:
		if current_exercise.is_barbell:
			weight = max(45.0, weight - current_barbell_plate * 2)
		else:
			weight = adjust_value(weight, false, current_exercise.get_next_weight)
		update_weight_display()
	else:
		push_error("Tried to decrease weight with no exercise selected")

func update_weight_display():
	if current_exercise == null:
		weight_label.text = "0"
		return
	
	var display_weight = weight
	var last_set = DataManager.get_last_set(current_exercise.name)
	var last_weight = last_set.weight if last_set else 0

	if current_exercise.is_barbell:
		weight_label.text = str(int(display_weight))
	else:
		if current_exercise.has_mod_plate and mod_plate_checkbox and mod_plate_checkbox.button_pressed:
			display_weight += 0.5
			weight_label.text = "%.1f" % display_weight
		else:
			weight_label.text = str(int(display_weight))

	# Apply color changing rules
	if display_weight > last_weight:
		weight_label.label_settings = increase_color
	elif display_weight < last_weight:
		weight_label.label_settings = decrease_color
	else:
		weight_label.label_settings = default_color

func _on_mod_plate_toggled(_button_pressed):
	update_weight_display()

func increase_reps():
	rep_count = adjust_value(rep_count, true, func(current, _is_increase): return current + 1)
	update_rep_display()

func decrease_reps():
	if rep_count > 1:
		rep_count = adjust_value(rep_count, false, func(current, _is_increase): return max(1, current - 1))
		update_rep_display()

func update_rep_display():
	rep_label.text = str(rep_count)

func update_label_color(label: Label, current_value, last_recorded_value):
	if current_value > last_recorded_value:
		label.label_settings = increase_color
	elif current_value < last_recorded_value:
		label.label_settings = decrease_color
	else:
		label.label_settings = default_color

func update_ui_for_exercise():
	if mod_plate_checkbox:
		mod_plate_checkbox.visible = current_exercise.has_mod_plate
	
	bb_weight_mod.visible = current_exercise.is_barbell
	
	var image_path = "res://assets/ui/icons/"
	match current_exercise.equipment_type:
		"dumbbell":
			image_path += "dumbell_weights.svg"
		"cable":
			image_path += "cable_weights.svg"
		"barbell":
			image_path += "barbell_weights.svg"  # You'll need to create this asset
		_:
			image_path += "dumbell_weights.svg"
	
	var texture = load(image_path)
	if texture:
		weight_image.texture = texture
	else:
		push_error("Failed to load texture: " + image_path)

func _on_enter_set_button_pressed():
	if current_exercise:
		var final_weight = weight
		if current_exercise.has_mod_plate and mod_plate_checkbox.button_pressed:
			final_weight += 0.5
		DataManager.record_set(current_exercise.name, final_weight, rep_count)
		emit_signal("set_recorded", current_exercise.name, final_weight, rep_count)
		
		# Reset label colors to default for the next set
		weight_label.label_settings = default_color
		rep_label.label_settings = default_color
	else:
		push_error("No exercise selected when trying to record set")

# Add these new functions to handle barbell weight selection
func _on_barbell_plate_selected(plate_weight: float, button: Button):
	if current_barbell_button:
		current_barbell_button.add_theme_stylebox_override("normal", default_style)
	
	current_barbell_button = button
	current_barbell_button.add_theme_stylebox_override("normal", selected_style)
	
	current_barbell_plate = plate_weight
	if weight == 45.0:  # If it's the initial selection
		weight = 45.0 + (current_barbell_plate * 2)
	update_weight_display()
	weight_label.label_settings = default_color  # Reset color when new plate is selected


func _on_more_weight_pressed():
	increase_weight()

func _on_less_weight_pressed():
	decrease_weight()

func _on_more_reps_pressed():
	increase_reps()

func _on_less_reps_pressed():
	decrease_reps()

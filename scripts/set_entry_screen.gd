extends Control

signal set_recorded(exercise: String, weight: int, reps: int)

@onready var rep_label = $RepControl/RepLabel
@onready var weight_label = $WeightControl/WeightLabel
@onready var exercise_label = $ScreenTitle/Label
@onready var enter_set_button = $EnterSetButton

var rep_count = 1
var weight = 1
var current_exercise: String= ""

func _ready():
	update_rep_display()
	update_weight_display()
	enter_set_button.connect("pressed", _on_enter_set_button_pressed)

func set_exercise(exercise_name: String, set_weight:int =1, set_reps: int=1):
	current_exercise = exercise_name
	weight = set_weight
	rep_count = set_reps
	
	if exercise_label:
		exercise_label.text = exercise_name
	else:
		push_error("Exercise label not found in SetEntryScreen")
	
	update_weight_display()
	update_rep_display()

func _on_enter_set_button_pressed():
	emit_signal("set_recorded", current_exercise, weight, rep_count)
	rep_count = 1
	weight = 1
	update_rep_display()
	update_weight_display()

# Number buttons.
func increase_reps():
	rep_count += 1
	update_rep_display()

func decrease_reps():
	if rep_count > 0:
		rep_count -= 1
		update_rep_display()

func increase_weight():
	weight += 1
	update_weight_display()

func decrease_weight():
	if weight > 0:
		weight -= 1
		update_weight_display()

func update_rep_display():
	rep_label.text = str(rep_count)
	rep_label.force_update_transform()

func update_weight_display():
	weight_label.text = str(weight)
	weight_label.force_update_transform()

# Connected signals
func _on_more_weight_pressed():
	increase_weight()

func _on_less_weight_pressed():
	decrease_weight()

func _on_more_reps_pressed():
	increase_reps()

func _on_less_reps_pressed():
	decrease_reps()

extends Control

@onready var rep_label = $RepControl/RepLabel
@onready var weight_label = $WeightControl/WeightLabel

var rep_count = 1
var weight = 1

func _ready():
	update_rep_display()
	update_weight_display()

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

func update_weight_display():
	weight_label.text = str(weight)


# Connected signals
func _on_more_weight_pressed():
	increase_weight()

func _on_less_weight_pressed():
	decrease_weight()

func _on_more_reps_pressed():
	increase_reps()

func _on_less_reps_pressed():
	decrease_reps()
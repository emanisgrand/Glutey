extends TextureButton

@onready var exercise_label = $ExerciseLabel
@onready var weight_label = $WeightLabel
@onready var rep_label = $RepLabel
@onready var set_label = $SetLabel

func set_set_data(exercise: String, weight: int, reps: int):
	exercise_label.text = exercise
	weight_label.text = "⚖️" + str(weight)
	rep_label.text = "🦾" + str(reps)
	# You might want to implement set numbering logic here
	# set_label.text = "🧮" + str(set_number)

func _on_pressed():
	# Handle what happens when this completed set card is pressed
	# For example, you might want to edit this set
	pass

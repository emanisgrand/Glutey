extends TextureButton

@onready var exercise_label = $ExerciseLabel
@onready var completed_set_label = $CompletedSetContainer/CompletedSetLabel

func set_set_data(exercise: String, set_number: int, weight: int, reps: int):
	if exercise_label:
		exercise_label.text = exercise.to_upper()
	else:
		push_error("ExerciseLabel not found in CompletedSetCard")

	if completed_set_label:
		completed_set_label.text = "%d\n%d\n%d" % [set_number, weight, reps]
	else:
		push_error("Cannot set completed set data: CompletedSetLabel not found")

func _on_pressed():
	# Handle what happens when this completed set card is pressed
	pass

extends TextureButton

@warning_ignore("unused_signal")
signal exercise_selected(exercise_name: String)

@onready var exercise_label = $ExerciseLabel

func _ready():
	if not exercise_label:
		push_error("ExerciseLabel not found in ExerciseCard")
	
	# Connect the pressed signal to our custom function
	pressed.connect(_on_pressed)

func _on_pressed():
	if exercise_label:
		emit_signal("exercise_selected", exercise_label.text)
	else:
		push_error("Cannot emit exercise_selected signal: ExerciseLabel is null")

func set_exercise_name(exercise_name: String):
	if exercise_label:
		exercise_label.text = exercise_name
	else:
		push_error("Cannot set exercise name: ExerciseLabel not found in card")

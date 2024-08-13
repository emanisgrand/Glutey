extends TextureButton

signal exercise_selected(exercise_namee:String)

@onready var exercise_label = $ExerciseLabel

func _ready():
	connect("pressed", _on_pressed)
	if not exercise_label:
		print("ExerciseLabel not found in ExerciseCard")

func _on_pressed():
	emit_signal("exercise_selected", exercise_label.text)

func set_exercise_name(name: String):
	if exercise_label:
		exercise_label.text = name
	else:
		print("Label not found in card")

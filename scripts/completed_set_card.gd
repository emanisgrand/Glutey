extends TextureButton

signal set_selected(exercise: String, set_number: int, weight: int, reps: int)

@onready var exercise_label = $ExerciseLabel
@onready var completed_set_container = $CompletedSetContainer

var exercise: String
var sets: Array = []

# Create a LabelSettings resource
var label_settings: LabelSettings

func _ready():
	connect("pressed", _on_pressed)
	
	# Initialize LabelSettings
	label_settings = LabelSettings.new()
	label_settings.font_size = 16
	label_settings.font_color = Color.BLACK

func set_exercise(exercise_name: String):
	exercise = exercise_name
	# Use call_deferred to ensure the label is updated after the node is ready
	call_deferred("_update_exercise_label")

func _update_exercise_label():
	if exercise_label:
		exercise_label.text = exercise.to_upper()
	else:
		push_error("ExerciseLabel not found in CompletedSetCard")

func add_set(set_number: int, weight: int, reps: int):
	var set_label = Label.new()
	set_label.text = "%d\n%d\n%d" % [set_number, weight, reps]
	set_label.label_settings = label_settings
	completed_set_container.add_child(set_label)
	sets.append({"set": set_number, "weight": weight, "reps": reps})

func _on_pressed():
	if sets.size() > 0:
		var last_set = sets[-1]
		emit_signal("set_selected", exercise, last_set.set, last_set.weight, last_set.reps)

func get_last_set_number() -> int:
	return sets.size()

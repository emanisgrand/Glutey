extends CanvasLayer

@onready var console = $Debug/ConsoleLog
@onready var calendar_view = $CalendarView
@onready var exercise_selection_screen = $ExerciseSelectionScreen
@onready var active_workout_screen = $ActiveWorkoutScreen
@onready var set_entry_screen = $SetEntryScreen

var current_screen = null
var current_muscle_group = ""
var current_exercise = ""

func _ready():
	console.visible = false
	_connect_signals()
	_connect_end_day_button()
	change_screen("active_workout")

func _connect_end_day_button():
	var end_day_button = get_node("ActiveWorkoutScreen/EndDayButton")
	if end_day_button:
		end_day_button.connect("pressed", _on_end_day_button_pressed)
	else:
		print("EndDayButton not found")

func _on_end_day_button_pressed():
	change_screen("calendar")

func _connect_signals():
	active_workout_screen.connect("muscle_group_selected", _on_muscle_group_selected)
	set_entry_screen.connect("set_recorded", _on_set_recorded)
	exercise_selection_screen.connect("exercise_selected", _on_exercise_selected)
	active_workout_screen.connect("existing_set_selected", _on_existing_set_selected)
	# Connect other signals here

func _on_muscle_group_selected(group: String):
	current_muscle_group = group
	exercise_selection_screen.set_muscle_group(group)
	change_screen("exercise_selection")

func _on_set_recorded(exercise: String, weight: int, reps: int):
	active_workout_screen.add_set(exercise, weight, reps)
	change_screen("active_workout")

func _on_existing_set_selected(exercise: String, _set_number: int, weight: int, reps: int):
	set_entry_screen.set_exercise(exercise, weight, reps)
	change_screen("set_entry")

func _on_exercise_card_pressed(exercise_name: String):
	set_entry_screen.set_exercise(exercise_name)
	active_workout_screen.set_current_exercise(exercise_name)
	change_screen("set_entry")

func _on_exercise_selected(exercise_name: String):
	current_exercise = exercise_name
	set_entry_screen.set_exercise(exercise_name)
	active_workout_screen.set_current_exercise(exercise_name)
	change_screen("set_entry")

func change_screen(screen_name: String):
	if current_screen:
		current_screen.visible = false
	
	match screen_name:
		"calendar":
			current_screen = calendar_view
		"exercise_selection":
			current_screen = exercise_selection_screen
		"active_workout":
			current_screen = active_workout_screen
		"set_entry":
			current_screen = set_entry_screen
		_:
			print("Invalid screen name")
			return
	
	current_screen.visible = true

func _on_toggle_console_pressed():
	console.visible = !console.visible



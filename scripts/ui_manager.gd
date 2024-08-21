extends CanvasLayer

@warning_ignore("unused_signal")
signal day_ended(date: Dictionary)

@onready var calendar_view = $CalendarView
@onready var console = $Debug/ConsoleLog
@onready var exercise_selection_screen = $ExerciseSelectionScreen
@onready var active_workout_screen = $ActiveWorkoutScreen
@onready var set_entry_screen = $SetEntryScreen
@onready var debug_panel = $DebugPanel

var current_screen = null
var current_muscle_group = ""
var current_exercise = ""
var is_view_only_mode = false

func _ready():
	console.visible = false
	_connect_signals()
	_connect_end_day_button()
	_setup_debug_tools()
	DataManager.set_current_date(Time.get_date_dict_from_system())
	change_screen("active_workout")

func _connect_signals():
	active_workout_screen.connect("muscle_group_selected", _on_muscle_group_selected)
	set_entry_screen.connect("set_recorded", _on_set_recorded)
	exercise_selection_screen.connect("exercise_selected", _on_exercise_selected)
	active_workout_screen.connect("existing_set_selected", _on_existing_set_selected)
	calendar_view.connect("day_selected", _on_day_selected)

func _on_day_selected(date: Dictionary, is_recorded: bool):
	if is_recorded:
		is_view_only_mode = true
		DataManager.set_current_date(date)
		if active_workout_screen:
			active_workout_screen.set_view_only_mode(true)
			active_workout_screen.load_workout(DataManager.get_workout_for_date(date))
		change_screen("active_workout")
	else:
		is_view_only_mode = false
		print("No workout record for this day.")

func _setup_debug_tools():
	debug_panel.get_node("VBoxContainer/AdvanceDayButton").connect("pressed", _on_advance_day_pressed)
	debug_panel.get_node("VBoxContainer/RecordWorkoutButton").connect("pressed", _on_record_workout_pressed)

func _connect_end_day_button():
	var end_day_button = get_node("ActiveWorkoutScreen/EndDayButton")
	if end_day_button:
		end_day_button.connect("pressed", _on_end_day_button_pressed)
	else:
		print("EndDayButton not found")

func _on_end_day_button_pressed():
	var current_date = DataManager.current_date
	emit_signal("day_ended", current_date)
	DataManager.save_data()
	if calendar_view:
		calendar_view.update_calendar()
		change_screen("calendar")
	else:
		print("Calendar view not available")

func _on_advance_day_pressed():
	var next_day = Time.get_unix_time_from_datetime_dict(DataManager.current_date) + 86400
	var new_date = Time.get_date_dict_from_unix_time(next_day)
	DataManager.set_current_date(new_date)
	if calendar_view:
		calendar_view.set_date(new_date)
	print("Advanced to date: ", new_date)
	
func _on_record_workout_pressed():
	# This now just ensures there's a workout for the current day
	DataManager.set_current_date(DataManager.current_date)
	calendar_view.update_calendar()
	print("Ensured workout for date: ", DataManager.current_date)

func _on_muscle_group_selected(group: String):
	current_muscle_group = group
	exercise_selection_screen.set_muscle_group(group)
	change_screen("exercise_selection")

func _on_set_recorded(exercise: String, weight: float, reps: int):
	DataManager.record_set(exercise, weight, reps)
	active_workout_screen.add_set(exercise, weight, reps)
	change_screen("active_workout")

func _on_existing_set_selected(exercise: String, _set_number: int, weight: float, reps: int):
	set_entry_screen.set_exercise(exercise, weight, reps)
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
			print("Invalid screen name: ", screen_name)
			return

	if current_screen:
		current_screen.visible = true
	else: 
		print("Screen not found: ", screen_name)

func _on_toggle_console_pressed():
	console.visible = !console.visible

# Add this method for testing purposes
func set_calendar_view(calendar):
	calendar_view = calendar

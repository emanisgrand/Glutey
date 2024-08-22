extends CanvasLayer

@warning_ignore("unused_signal")
signal day_ended(date: Dictionary)

@onready var exercise_selection_screen = $ExerciseSelectionScreen
@onready var set_entry_screen = $SetEntryScreen
@onready var workout_screen = $WorkoutScreen
@onready var calendar_view = $CalendarView
@onready var console = $Debug/ConsoleLog
@onready var debug_panel = $DebugPanel

var current_screen = null
var current_muscle_group = ""
var current_exercise = ""
var is_view_only_mode = false
var has_active_workout = false

var today_date: Dictionary
var active_workout_date: Dictionary

func _ready():
	today_date = Time.get_date_dict_from_system()
	DataManager.set_current_date(today_date)
	console.visible = false
	_connect_signals()
	_connect_end_day_button()
	_setup_debug_tools()
	DataManager.set_current_date(Time.get_date_dict_from_system())
	change_screen("workout")

func _connect_signals():
	workout_screen.connect("muscle_group_selected", _on_muscle_group_selected)
	set_entry_screen.connect("set_recorded", _on_set_recorded)
	exercise_selection_screen.connect("exercise_selected", _on_exercise_selected)
	workout_screen.connect("existing_set_selected", _on_existing_set_selected)
	calendar_view.connect("day_selected", _on_day_selected)

func _on_day_selected(date: Dictionary, is_recorded: bool):
	if is_recorded:
		DataManager.set_current_date(date)
		workout_screen.load_workout(DataManager.get_workout_for_date(date))
		workout_screen.set_view_only_mode(true)
		change_screen("workout")

func _setup_debug_tools():
	debug_panel.get_node("VBoxContainer/AdvanceDayButton").connect("pressed", _on_advance_day_pressed)
	debug_panel.get_node("VBoxContainer/RecordWorkoutButton").connect("pressed", _on_record_workout_pressed)

func _connect_end_day_button():
	var end_day_button = get_node("WorkoutScreen/EndDayButton")
	if end_day_button:
		end_day_button.connect("pressed", _on_end_day_button_pressed)
	else:
		print("EndDayButton not found")

func _on_end_day_button_pressed():
	var current_date = DataManager.current_date
	emit_signal("day_ended", current_date)
	DataManager.save_data()
	has_active_workout = false
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
	has_active_workout = true
	exercise_selection_screen.set_muscle_group(group)
	change_screen("exercise_selection")

func _on_set_recorded(exercise: String, weight: float, reps: int):
	DataManager.record_set(exercise, weight, reps)
	workout_screen.add_set(exercise, weight, reps)
	calendar_view.update_calendar()  # Refresh the calendar
	change_screen("workout")

func _on_existing_set_selected(exercise: String, _set_number: int, weight: float, reps: int):
	set_entry_screen.set_exercise(exercise, weight, reps)
	change_screen("set_entry")

func _on_exercise_selected(exercise_name: String):
	current_exercise = exercise_name
	set_entry_screen.set_exercise(exercise_name)
	workout_screen.set_current_exercise(exercise_name)
	change_screen("set_entry")

func change_screen(screen_name: String):
	if current_screen:
		current_screen.visible = false

	match screen_name:
		"calendar":
			current_screen = calendar_view
			if calendar_view.has_method("set_return_to_active_workout_visible"):
				calendar_view.set_return_to_active_workout_visible(has_active_workout)
		"workout":
			current_screen = workout_screen
			workout_screen.update_ui()
		"exercise_selection":
			current_screen = exercise_selection_screen
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

func _is_same_date(date1: Dictionary, date2: Dictionary) -> bool:
	return date1.year == date2.year and date1.month == date2.month and date1.day == date2.day


# Add this method for testing purposes
func set_calendar_view(calendar):
	calendar_view = calendar

func switch_to_active_mode(date: Dictionary):
	var system_date = Time.get_date_dict_from_system()
	if _is_same_date(date, system_date):
		active_workout_date = date
		DataManager.set_current_date(date)
		workout_screen.set_view_only_mode(false)
		workout_screen.load_workout(DataManager.get_workout_for_date(date))
		change_screen("workout")
	else:
		print("Cannot switch to active mode for past dates")

func end_day():
	DataManager.save_data()
	calendar_view.update_calendar()
	change_screen("calendar")

func update_workout_state():
	var current_date = DataManager.current_date
	var is_today = _is_same_date(current_date, today_date)
	
	if is_today:
		if DataManager.is_workout_day_recorded(current_date):
			workout_screen.set_view_only_mode(true)
		else:
			workout_screen.set_view_only_mode(false)
	else:
		workout_screen.set_view_only_mode(true)
	
	workout_screen.load_workout(DataManager.get_workout_for_date(current_date))
	change_screen("workout")

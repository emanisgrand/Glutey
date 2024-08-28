extends CanvasLayer

@warning_ignore("unused_signal")
signal day_ended(date: Dictionary)

@onready var exercise_selection_screen = $ExerciseSelectionScreen
@onready var set_entry_screen = $SetEntryScreen
@onready var workout_screen = $WorkoutScreen
@onready var calendar_view = $CalendarView
@onready var console = $Debug/ConsoleLog
@onready var debug_panel = $DebugPanel

var screen_stack = []
var current_screen = null
var current_muscle_group = ""
var current_exercise = ""
var is_view_only_mode = false
var has_active_workout = false

var today_date: Dictionary
var active_workout_date: Dictionary

var temp_workout = null

func _ready():
	today_date = Time.get_date_dict_from_system()
	DataManager.set_current_date(today_date)
	console.visible = false
	_connect_signals()
	_connect_end_day_button()
	_setup_debug_tools()
	DataManager.set_current_date(Time.get_date_dict_from_system())
	change_screen("workout")
	get_tree().set_auto_accept_quit(false)

func _notification(what):
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			DataManager.save_data()
		NOTIFICATION_APPLICATION_FOCUS_IN:
			DataManager.load_data()
			update_ui()
		NOTIFICATION_WM_CLOSE_REQUEST:
			DataManager.save_data()
			get_tree().quit()
		NOTIFICATION_WM_GO_BACK_REQUEST:
			_handle_back_button()
			get_viewport().set_input_as_handled()

func _handle_back_button():
	if screen_stack.size() > 0:
		if go_back():
			return
	# We're at the root screen or couldn't go back, so let's show a confirmation dialog
	_show_exit_confirmation()

func _input(event):
	if (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE) or \
	   (event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_BACK):
		_handle_back_button()
		get_viewport().set_input_as_handled()

func _show_exit_confirmation():
	var dialog = ConfirmationDialog.new()
	dialog.dialog_text = "Do you want to exit 👽Glutey?"
	dialog.get_ok_button().text = "Exit"
	dialog.get_cancel_button().text = "Stay"
	dialog.confirmed.connect(_on_exit_confirmed)
	dialog.canceled.connect(_on_exit_canceled)
	add_child(dialog)
	dialog.popup_centered()

func _on_exit_confirmed():
	DataManager.save_data()
	get_tree().quit()

func _on_exit_canceled():
	get_tree().set_auto_accept_quit(true)

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
	calendar_view.update_calendar()
	change_screen("workout")

func _on_existing_set_selected(exercise: String, _set_number: int, weight: float, reps: int):
	set_entry_screen.set_exercise(exercise, weight, reps)
	change_screen("set_entry")

func _on_exercise_selected(exercise_name: String):
	current_exercise = exercise_name
	set_entry_screen.set_exercise(exercise_name)
	change_screen("set_entry")

func change_screen(screen_name: String):
	var new_screen = null
	
	# Use the switch statement to determine the new screen
	match screen_name:
		"calendar":
			new_screen = calendar_view
			if calendar_view.has_method("set_return_to_active_workout_visible"):
				calendar_view.set_return_to_active_workout_visible(has_active_workout)
		"workout":
			new_screen = workout_screen
			workout_screen.update_ui()
		"exercise_selection":
			new_screen = exercise_selection_screen
		"set_entry":
			new_screen = set_entry_screen
		_:
			print("Invalid screen name: ", screen_name)
			return
		
	if new_screen == null:
		print("Screen not found: ", screen_name)
		return
		
	if new_screen == current_screen:
		return  # We're already on this screen
		
	if current_screen:
		current_screen.visible = false
		# Only add to stack if we're not going back
		if not screen_stack.is_empty() and new_screen != screen_stack.back():
			screen_stack.push_back(current_screen)
		elif screen_stack.is_empty():
			screen_stack.push_back(current_screen)
		
	current_screen = new_screen
	current_screen.visible = true

func _on_toggle_console_pressed():
	console.visible = !console.visible

func _is_same_date(date1: Dictionary, date2: Dictionary) -> bool:
	return date1.year == date2.year and date1.month == date2.month and date1.day == date2.day

# Add this method for testing purposes
func set_calendar_view(calendar):
	calendar_view = calendar

func switch_to_active_mode(date: Dictionary):
	if !active_workout_date.is_empty():
		# Save the current active workout before switching
		DataManager.save_data()
	
	active_workout_date = date
	DataManager.set_current_date(date)
	workout_screen.set_view_only_mode(false)
	workout_screen.load_workout(DataManager.get_workout_for_date(date))
	change_screen("workout")

func end_day():
	DataManager.save_data()
	clear_temp_workout()
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

func store_temp_workout(workout: DataManager.Workout):
	temp_workout = workout
	has_active_workout = true

func clear_temp_workout():
	temp_workout = null
	has_active_workout = false

func go_back() -> bool:
	if screen_stack.size() > 0:
		current_screen.visible = false
		current_screen = screen_stack.pop_back()
		current_screen.visible = true
		return true
	else:
		print("No previous screen to go back to")
		return false

func restore_temp_workout():
	if temp_workout:
		workout_screen.load_workout(temp_workout)
		temp_workout = null

func update_ui():
	# Refresh the current screen's UI
	if current_screen and current_screen.has_method("update_ui"):
		current_screen.update_ui()

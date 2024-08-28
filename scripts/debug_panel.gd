extends Control

@onready var advance_day_button = $VBoxContainer/AdvanceDayButton
@onready var record_workout_button = $VBoxContainer/RecordWorkoutButton
@onready var clear_data_button = $VBoxContainer/ClearDataButton
@onready var current_date_label = $VBoxContainer/CurrentDateLabel
@onready var rewind_day_button: Button = $VBoxContainer/RewindDayButton

func _ready():
	advance_day_button.connect("pressed", _on_advance_day_pressed)
	record_workout_button.connect("pressed", _on_record_workout_pressed)
	clear_data_button.connect("pressed", _on_clear_data_pressed)
	rewind_day_button.connect("pressed", _on_rewind_day_pressed)
	update_current_date_label()

func _on_advance_day_pressed():
	var current_date = DataManager.current_date
	var new_date = {
		"year": current_date.year,
		"month": current_date.month,
		"day": current_date.day + 1
	}
	
	# Handle month/year transitions
	var days_in_month = get_days_in_month(new_date.month, new_date.year)
	if new_date.day > days_in_month:
		new_date.day = 1
		new_date.month += 1
		if new_date.month > 12:
			new_date.month = 1
			new_date.year += 1
	
	DataManager.set_current_date(new_date)
	update_current_date_label()
	print("Advanced to date: ", new_date)
	get_parent().update_workout_state()

func _on_rewind_day_pressed():
	var current_date = DataManager.current_date
	var new_date = {
		"year": current_date.year,
		"month": current_date.month,
		"day": current_date.day - 1
	}
	
	# Handle month/year transitions
	if new_date.day < 1:
		new_date.month -= 1
		if new_date.month < 1:
			new_date.month = 12
			new_date.year -= 1
		new_date.day = get_days_in_month(new_date.month, new_date.year)
	
	DataManager.set_current_date(new_date)
	update_current_date_label()
	print("Rewound to date: ", new_date)
	get_parent().update_workout_state()

func _on_record_workout_pressed():
	DataManager.set_current_date(DataManager.current_date)  # This ensures a session exists for the current date
	print("Ensured workout session for date: ", DataManager.current_date)

func _on_clear_data_pressed():
	var dialog = ConfirmationDialog.new()
	dialog.dialog_text = "Are you sure you want to clear all data? This action cannot be undone."
	dialog.get_ok_button().text = "Yes, Clear Data"
	dialog.get_cancel_button().text = "Cancel"
	add_child(dialog)
	dialog.popup_centered()
	dialog.connect("confirmed", _clear_data_confirmed)

func _clear_data_confirmed():
	DataManager.clear_data()
	update_current_date_label()
	print("All data has been cleared.")

func update_current_date_label():
	var date = DataManager.current_date
	current_date_label.text = "%d-%02d-%02d" % [date.year, date.month, date.day]

func get_days_in_month(month: int, year: int) -> int:
	var days_per_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	
	# Check for leap year
	if month == 2 and ((year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)):
		return 29
	
	return days_per_month[month - 1]
# You might want to add more debug functions here as needed

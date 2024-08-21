extends Control

@onready var advance_day_button = $VBoxContainer/AdvanceDayButton
@onready var record_workout_button = $VBoxContainer/RecordWorkoutButton
@onready var clear_data_button = $VBoxContainer/ClearDataButton
@onready var current_date_label = $VBoxContainer/CurrentDateLabel

func _ready():
	advance_day_button.connect("pressed", _on_advance_day_pressed)
	record_workout_button.connect("pressed", _on_record_workout_pressed)
	clear_data_button.connect("pressed", _on_clear_data_pressed)
	update_current_date_label()

func _on_advance_day_pressed():
	var next_day = Time.get_unix_time_from_datetime_dict(DataManager.current_date) + 86400
	var new_date = Time.get_date_dict_from_unix_time(next_day)
	DataManager.set_current_date(new_date)
	update_current_date_label()
	print("Advanced to date: ", new_date)

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

# You might want to add more debug functions here as needed

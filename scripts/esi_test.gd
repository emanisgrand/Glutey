extends CanvasLayer

var data_driver: DataDriver
var current_date: Dictionary

@onready var data_label = $VBoxContainer/DataLabel
@onready var load_button = $VBoxContainer/HBoxContainer/LoadButton
@onready var add_set_button = $VBoxContainer/HBoxContainer/AddSetButton
@onready var fw_day_button = $"VBoxContainer/HBoxContainer2/Fw-Day"
@onready var back_day_button = $"VBoxContainer/HBoxContainer2/Back-Day"
@onready var calendar_grid = $VBoxContainer/CalendarContainer/CalendarVBoxContainer/CalendarGrid
@onready var month_year_label = $VBoxContainer/CalendarContainer/CalendarVBoxContainer/CalendarHBoxContainer/MonthYear
@onready var clear_data_button = $VBoxContainer/HBoxContainer/ClearDataButton

const DAYS_IN_WEEK = 7
var days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

func _ready():
	data_driver = DataDriver.new()
	load_data()
	current_date = Time.get_date_dict_from_system()
	update_date_display()
	update_calendar()
	
	load_button.connect("pressed", _on_load_button_pressed)
	add_set_button.connect("pressed", _on_add_set_button_pressed)
	fw_day_button.connect("pressed", _on_fw_day_button_pressed)
	back_day_button.connect("pressed", _on_back_day_button_pressed)
	clear_data_button.connect("pressed", _on_clear_data_button_pressed)


func _on_load_button_pressed():
	data_driver.load_data()
	var workout_count = data_driver.workouts.size()
	data_label.text = "Data loaded successfully. Found %d workouts." % workout_count
	update_calendar()

func load_data():
	data_driver.load_data()
	var workouts = data_driver.get_all_workouts()
	if workouts.is_empty():
		data_label.text = "No data loaded or no workouts found"
	else:
		data_label.text = "Data loaded successfully. Found %d workouts." % workouts.size()

func _on_add_set_button_pressed():
	var exercise = WorkoutConstants.get_random_exercise()
	var exercise_name = exercise.name
	var exercise_data = exercise.data
	
	var weight_index = randi() % exercise_data.increments.size()
	var weight = exercise_data.increments[weight_index]
	var reps = randi() % 11 + 1  # Random reps between 1 and 10
	
	data_driver.add_set_and_save(current_date, exercise_name, weight, reps)
	data_label.text = "Added set for %s: %.1f lbs, %d reps" % [exercise_name, weight, reps]
	update_calendar()

func _on_day_button_pressed(date: Dictionary):
	var workout = data_driver.get_workout(date)
	var display_text = "Workout for %04d-%02d-%02d:\n" % [date.year, date.month, date.day]
	
	for exercise in workout.exercises:
		display_text += "\n%s:\n" % exercise
		for set_data in workout.exercises[exercise]:
			display_text += "  Weight: %.1f, Reps: %d\n" % [set_data.weight, set_data.reps]
	
	data_label.text = display_text

func _on_fw_day_button_pressed():
	current_date = Time.get_datetime_dict_from_unix_time(
		Time.get_unix_time_from_datetime_dict(current_date) + 86400
	)
	update_date_display()
	
func _on_back_day_button_pressed():
	current_date = Time.get_datetime_dict_from_unix_time(
		Time.get_unix_time_from_datetime_dict(current_date) - 86400
	)
	update_date_display()
	update_calendar()

func update_calendar():
	# Clear existing calendar
	for child in calendar_grid.get_children():
		child.queue_free()

	var year = current_date.year
	var month = current_date.month

	var calendar_data = CalendarData.get_calendar_data(year, month)
	month_year_label.text = "%s %d" % [calendar_data.month_name, year]
	
	# Add empty cells for days before the 1st
	for i in range(calendar_data.first_day):
		var empty_label = Label.new()
		empty_label.text = ""
		calendar_grid.add_child(empty_label)

	# Add cells for each day of the month
	for day in range(1, calendar_data.days_count + 1):
		var date = {"year": year, "month": month, "day": day}
		var has_workout = data_driver.get_workout(date).exercises.size() > 0

		var day_button = Button.new() if has_workout else Label.new()
		day_button.text = str(day)
		day_button.custom_minimum_size = Vector2(40, 40)

		if has_workout:
			day_button.connect("pressed", _on_day_button_pressed.bind(date))

		calendar_grid.add_child(day_button)

func update_date_display():
	data_label.text = "Current Date: %04d-%02d-%02d" % [current_date.year, current_date.month, current_date.day]

func _on_clear_data_button_pressed():
	data_driver.clear_all_data()
	data_label.text = "All workout data has been cleared."
	update_calendar()  # Refresh the calendar to remove workout indicators

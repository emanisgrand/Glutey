# calendar.gd
extends Control
@warning_ignore("unused_signal")
signal day_selected(date: Dictionary, is_recorded: bool)

const DAYS_IN_WEEK = 7
var current_date = Time.get_date_dict_from_system()
var days_in_month = 0
var first_day_of_month = 0

@onready var year_label = $YearLabel
@onready var month_label = $MonthLabel
@onready var grid_container = $GridContainer

var is_test_environment = false

func _ready():
	if not is_test_environment:
		update_calendar()

func set_test_environment(value: bool):
	is_test_environment = value

func set_date(new_date: Dictionary):
	current_date = new_date
	update_calendar()

func update_calendar():
	update_labels()
	if not is_test_environment:
		clear_grid()
		populate_grid()
	calculate_month_details()

func update_labels():
	if not is_test_environment:
		year_label.text = str(current_date.year)
		month_label.text = get_month_name(current_date.month)

func get_month_name(month):
	var months = [
		"January", "February", "March", "April", "May", "June",
		"July", "August", "September", "October", "November", "December"
	]
	return months[month - 1] if month >= 1 and month <= 12 else "Invalid Month"

func clear_grid():
	for child in grid_container.get_children():
		child.queue_free()

func calculate_month_details():
	var date_time = Time.get_datetime_dict_from_system()
	date_time.day = 1
	date_time.month = current_date.month
	date_time.year = current_date.year
	var first_of_month = Time.get_unix_time_from_datetime_dict(date_time)
	first_day_of_month = Time.get_datetime_dict_from_unix_time(first_of_month).weekday
	days_in_month = get_days_in_month(current_date.month, current_date.year)

func get_days_in_month(month, year):
	var days_per_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	
	# Check for leap year
	if month == 2 and ((year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)):
		return 29
	
	return days_per_month[month - 1]

func populate_grid():
	# Add empty cells for days before the 1st of the month
	for i in range(first_day_of_month):
		add_empty_cell()

	# Add cells for each day of the month
	for day in range(1, days_in_month + 1):
		add_day_cell(day)

func add_empty_cell():
	var empty_cell = Control.new()
	empty_cell.custom_minimum_size = Vector2(50, 50)  # Adjust size as needed
	grid_container.add_child(empty_cell)

func add_day_cell(day):
	var day_button = Button.new()
	day_button.text = str(day)
	day_button.custom_minimum_size = Vector2(50, 50)  # Adjust size as needed

	var is_recorded = is_day_recorded(day)
	if is_recorded:	
		day_button.add_theme_color_override("font_color", Color.GREEN)
		day_button.add_theme_color_override("font_hover_color", Color.DARK_GREEN)
	
	day_button.pressed.connect(_on_day_pressed.bind(day, is_recorded))
	grid_container.add_child(day_button)

func is_day_recorded(day):
	var check_date = {
		"year": current_date.year,
		"month": current_date.month,
		"day": day
	}
	return DataManager.is_workout_day_recorded(check_date)

func _on_day_pressed(day, is_recorded):
	var selected_date = {
		"year": current_date.year,
		"month": current_date.month,
		"day": day
	}
	emit_signal("day_selected", selected_date, is_recorded)

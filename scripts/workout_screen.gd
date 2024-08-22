extends Control

@onready var workout_mode_bg = $WorkoutModeBG
@onready var workout_complete_bg = $WorkoutCompleteBG
@onready var completed_set_container = $CompletedSetStack/VBoxContainer
@onready var muscle_group_buttons = $MuscleGroups/VBoxContainer.get_children()
@onready var calendar_view_button: TextureButton = $CalendarViewButton
@onready var end_day_button: TextureButton = $EndDayButton
@onready var completed_set_card_scene = preload("res://scenes/completed_set_card.tscn")


var long_press_timer: Timer
var is_view_only_mode:bool = false
var is_review_mode = false

@warning_ignore("unused_signal")
signal muscle_group_selected(group: String)
@warning_ignore("unused_signal")
signal existing_set_selected(exercise: String, set_number: int, weight: float, reps: int)

var exercise_cards: Dictionary = {}

func _ready():
	for button in muscle_group_buttons:
		if button is Button:
			button.pressed.connect(_on_muscle_group_button_pressed.bind(button.name))
	calendar_view_button.connect("pressed", _on_calendar_view_button_pressed)
	long_press_timer = Timer.new()
	long_press_timer.one_shot = true
	long_press_timer.timeout.connect(_on_long_press_timer_timeout)
	add_child(long_press_timer)
	
	end_day_button.button_down.connect(_on_end_day_button_down)
	end_day_button.button_up.connect(_on_end_day_button_up)

func set_view_only_mode(enable: bool):
	is_view_only_mode = enable
	update_ui()

func _on_muscle_group_button_pressed(button_name: String):
	if not is_view_only_mode:
		var muscle_group = button_name.replace("Button", "").to_upper()
		emit_signal("muscle_group_selected", muscle_group)

func set_current_exercise(exercise_name: String):
	if not exercise_cards.has(exercise_name):
		var new_card = completed_set_card_scene.instantiate()
		new_card.set_exercise(exercise_name)
		new_card.connect("set_selected", _on_set_selected)
		completed_set_container.add_child(new_card)
		exercise_cards[exercise_name] = new_card

func add_set(exercise: String, weight: float, reps: int):
	if not is_view_only_mode:
		if not exercise_cards.has(exercise):
			set_current_exercise(exercise)
	
		var card = exercise_cards[exercise]
		var set_number = card.get_last_set_number() + 1
		card.add_set(set_number, weight, reps)

func _on_set_selected(exercise: String, set_number: int, weight: float, reps: int):
	if not is_view_only_mode:
		emit_signal("existing_set_selected", exercise, set_number, weight, reps)

func load_workout(workout: DataManager.Workout):
	clear_workout_display()
	if workout:
		for exercise_name in workout.exercises:
			set_current_exercise(exercise_name)
			for set_data in workout.exercises[exercise_name]:
				add_set(exercise_name, set_data.weight, set_data.reps)
	update_ui()

func clear_workout_display():
	for card in exercise_cards.values():
		card.queue_free()
	exercise_cards.clear()

# Add this method to update the display when switching days
func update_display():
	var current_workout = DataManager.get_workout_for_date(DataManager.current_date)
	load_workout(current_workout)

func update_ui():
	workout_mode_bg.visible = !is_view_only_mode
	workout_complete_bg.visible = is_view_only_mode
	
	for button in muscle_group_buttons:
		if button is Button:
			button.disabled = is_view_only_mode
	
	for set_card in completed_set_container.get_children():
		if set_card.has_method("set_interactive"):
			set_card.set_interactive(!is_view_only_mode)
	
	end_day_button.visible = true
	calendar_view_button.visible = true

func _on_calendar_view_button_pressed():
	# Signal to UI manager to switch to calendar view
	get_parent().change_screen("calendar")

func _on_calendar_view_button_long_pressed():
	if is_review_mode:
		# Switch to active mode
		is_review_mode = false
		set_view_only_mode(false)
		# TODO: Implement logic to handle switching from review to active mode
		# This might involve saving the current active workout (if any) and loading the reviewed workout as active
	else:
		# Switch to review mode
		is_review_mode = true
		set_view_only_mode(true)
		
func _on_long_press_timer_timeout():
	# Long press detected
	if is_view_only_mode:
		# Signal to UI manager to switch to active mode
		get_parent().switch_to_active_mode(DataManager.current_date)
	else:
		# Maybe show a confirmation dialog for ending the day?
		get_parent().end_day()

func _on_end_day_button_up():
	if long_press_timer.is_stopped():
		# Short press
		if !is_view_only_mode:
			get_parent().end_day()
	else:
		long_press_timer.stop()

func _on_end_day_button_down():
	long_press_timer.start(0.5)  # Adjust this value to change the duration for a long press

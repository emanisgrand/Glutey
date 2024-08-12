extends CanvasLayer

@onready var console = $Debug/ConsoleLog
@onready var calendar_view = $CalendarView
@onready var exercise_selection_screen = $ExerciseSelectionScreen
@onready var active_workout_screen = $ActiveWorkoutScreen
@onready var set_entry_screen = $SetEntryScreen

var current_screen = null

func _ready():
	console.visible = false
	register_buttons()
	change_screen(active_workout_screen)
	active_workout_screen.connect("muscle_group_selected", _on_muscle_group_selected)
	set_entry_screen.connect("set_recorded", _on_set_recorded)

func _on_muscle_group_selected(group: String):
	exercise_selection_screen.set_muscle_group(group)
	change_screen(exercise_selection_screen)

func _on_set_recorded(exercise: String, weight: int, reps: int):
	active_workout_screen.add_set(weight, reps)
	change_screen(active_workout_screen)

func _on_exercise_selected(exercise_name: String):
	set_entry_screen.set_exercise(exercise_name)
	change_screen(set_entry_screen)

func register_buttons():
	var buttons = get_tree().get_nodes_in_group("buttons")
	if buttons.size() > 0:
		for button in buttons:
			if button is ScreenButton:
				button.clicked.connect(_on_button_pressed)

func _on_button_pressed(button):
	match button.name:
		"CompletedSetCard":
			print("Completed Set Card is pressed")
			change_screen(set_entry_screen)
		"EndDayButton":
			print("End Day button is pressed")
			change_screen(calendar_view)
		"CalendarDay":
			print("Calendar Day button is pressed")
			change_screen(active_workout_screen)
		"EnterSetButton":
			print("Enter Set button is pressed")
			change_screen(active_workout_screen)
		"ChestButton":
			print("Chest button is pressed")
			change_screen(exercise_selection_screen)

func change_screen(new_screen):
	if current_screen != null:
		current_screen.visible = false
	current_screen = new_screen
	if current_screen != null:
		current_screen.visible = true
		get_tree().call_group("buttons", "set_disabled", false)

func _on_exercise_card_pressed(exercise_name: String):
	set_entry_screen.set_exercise(exercise_name)
	active_workout_screen.set_current_exercise(exercise_name)
	change_screen(set_entry_screen)

func _on_toggle_console_pressed():
	console.visible = !console.visible

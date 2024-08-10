extends Control

signal muscle_group_selected(group: String)

func _ready():
	var muscle_group_buttons = $MuscleGroups/VBoxContainer.get_children()
	for button in muscle_group_buttons:
		if button is Button:
			button.pressed.connect(_on_muscle_group_button_pressed.bind(button.name))

func _on_muscle_group_button_pressed(button_name: String):
	var muscle_group = button_name.replace("Button", "").to_upper()
	emit_signal("muscle_group_selected", muscle_group)

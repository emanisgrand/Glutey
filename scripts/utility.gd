extends Node

var current_screen_name: String = ""

func add_log_msg(log_str: String):
	var console = get_tree().get_first_node_in_group("debug_console")
	if console:
		var log_label = console.find_child("LogLabel")
		if log_label:
			if !log_label.text.is_empty():
				log_label.text += "\n"
			log_label.text += log_str

func change_screen(new_screen_name: String):
	current_screen_name = new_screen_name
	emit_signal("screen_changed", new_screen_name)

extends Node

func add_log_msg(log_str: String):
	var console = get_tree().get_first_node_in_group("debug_console")
	if console:
		var log_label = console.find_child("LogLabel")
		if log_label:
			if !log_label.text.is_empty():
				log_label.text += "\n"
			log_label.text += log_str

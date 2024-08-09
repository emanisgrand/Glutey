extends Control

func _ready():	
	get_tree().call_group("buttons", "set_disabled", true)

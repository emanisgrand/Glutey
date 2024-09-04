# res://esi/element.gd
class_name Element
extends Resource

var id: int  # Unique identifier for the element
var structures: Dictionary  # Dictionary of Structure instances

func _init(p_id: int):
	id = p_id

func add_structure(name: String, structure: Structure):
	structures[name] = structure

func get_structure(name: String) -> Structure:
	return structures.get(name)

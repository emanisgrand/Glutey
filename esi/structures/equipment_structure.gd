# res://esi/structures/equipment_structure.gd
class_name EquipmentStructure
extends Structure

@export var type: WorkoutConstants.EquipmentType
@export var increments: Array[float]
@export var has_mod_plate: bool

func _init(p_type: WorkoutConstants.EquipmentType, p_increments: Array[float], p_has_mod_plate: bool = false):
	type = p_type
	increments = p_increments
	has_mod_plate = p_has_mod_plate

func get_type_name() -> String:
	return WorkoutConstants.get_equipment_type_name(type)

func is_barbell() -> bool:
	return type == WorkoutConstants.EquipmentType.BARBELL

func is_dumbbell() -> bool:
	return type == WorkoutConstants.EquipmentType.DUMBBELL

func is_machine() -> bool:
	return type == WorkoutConstants.EquipmentType.MACHINE

func is_cable() -> bool:
	return type == WorkoutConstants.EquipmentType.CABLE

func is_bodyweight() -> bool:
	return type == WorkoutConstants.EquipmentType.BODYWEIGHT

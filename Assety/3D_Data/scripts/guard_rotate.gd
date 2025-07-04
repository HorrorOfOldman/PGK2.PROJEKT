extends Node3D

@export var rotation_speed: float = 90.0  # stopnie na sekundę

func _process(delta: float) -> void:
	rotate_y(deg_to_rad(rotation_speed * delta))

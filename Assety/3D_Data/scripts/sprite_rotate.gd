extends Sprite3D

@export var rotation_speed := 90.0  # stopnie na sekundę



func _process(delta: float) -> void:
	rotation.y += deg_to_rad(rotation_speed) * delta

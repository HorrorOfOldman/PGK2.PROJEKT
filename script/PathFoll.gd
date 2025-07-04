extends PathFollow3D

@export var speed: float = 3.0

func _process(delta: float) -> void:
	progress += speed * delta

extends Node3D
#skrypt do obracania nieba o 1 stopień na sekundę
@export var rotation_speed : float = 1.0 # obrót w stopniach na sekundę

func _process(delta):
	rotate_y(deg_to_rad(-rotation_speed * delta))

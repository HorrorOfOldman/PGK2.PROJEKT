extends PathFollow3D

@export var speed := 2.0
@onready var music_player := $Kohorta/LEGIO  # AudioStreamPlayer3D

func _ready() -> void:
	if music_player and not music_player.playing:
		music_player.play()

func _process(delta: float) -> void:
	progress += speed * delta

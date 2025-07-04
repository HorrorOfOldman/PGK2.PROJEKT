extends Node3D

@export var detection_radius := 10.0 # w metrach

@onready var hero: Node3D = get_node("/root/TestEsk/MovementTest/Hero")
@onready var icon: Sprite3D = $klucz/Icon
@onready var sound_player: AudioStreamPlayer3D = $klucz/Sound

var player_was_close := false
var taken := false

func _ready():
	$klucz.hide()
	self.visible = false # <-- ukryj całość na starcie
	$AnimationPlayer.play("hide")

func _process(_delta):
	if not hero or taken:
		return

	# Tylko jeśli quest aktywny
	if Globalsy.Quest_key != 1:
		return
	
	if not self.visible:
		self.visible = true
		$klucz.show()
		$AnimationPlayer.play("show")

	var distance = global_position.distance_to(hero.global_position)

	if distance <= detection_radius:
		icon.show()

		if not player_was_close:
			player_was_close = true
			if not sound_player.playing:
				sound_player.play()
	else:
		icon.hide()
		player_was_close = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not taken and player_was_close and Globalsy.Quest_key == 1:
			taken = true
			icon.hide()
			print("Klucz zabrany!")
			Globalsy.Quest_key = 2

			#$AnimationPlayer.play("hide")
			#await $AnimationPlayer.animation_finished
			queue_free()

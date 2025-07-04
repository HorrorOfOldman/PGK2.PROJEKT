extends CharacterBody3D

@export var move_speed := 2.5
@export var chase_radius := 20.0 # promień, w którym przeciwnik może się poruszać od startu

@onready var icon: Sprite3D = $Icon
@onready var sound_player: AudioStreamPlayer3D = $Sound
@onready var player: Node3D = get_node("/root/TestKat/KatakumbyTest/Hero")
@onready var chase_area: Area3D = $ChaseArea
@onready var touch_area: Area3D = $TouchArea
@onready var walka : Node2D = $walka

var chasing_player := false
var start_position: Vector3

func _ready():
	icon.hide()
	walka.hide()
	start_position = global_transform.origin
	
	chase_area.connect("body_entered", Callable(self, "_on_chase_area_body_entered"))
	chase_area.connect("body_exited", Callable(self, "_on_chase_area_body_exited"))

	touch_area.connect("body_entered", Callable(self, "_on_touch_area_body_entered"))

func _process(delta):
	if Globalsy.dialogue_active:
		# Jeśli trwa dialog, przeciwnik się nie rusza
		return

	var distance_to_start = global_position.distance_to(start_position)

	if chasing_player:
		# Ścigaj gracza tylko, jeśli w zasięgu i w chase_radius od startu
		if distance_to_start <= chase_radius:
			move_toward_position(player.global_transform.origin, delta)
		else:
			# Za daleko od startu? Przestań gonić i wróć
			chasing_player = false
			icon.hide()

	if not chasing_player and distance_to_start > 0.1:
		# Wracaj do startu
		move_toward_position(start_position, delta)


func move_toward_position(target_position: Vector3, delta):
	var enemy_pos = global_transform.origin
	target_position.y = enemy_pos.y

	var direction = (target_position - enemy_pos).normalized()
	var new_pos = enemy_pos + direction * move_speed * delta
	global_transform.origin = new_pos

	var look_dir = direction
	look_dir.y = 0
	if look_dir.length() > 0.01:
		look_at(enemy_pos + look_dir, Vector3.UP)

func _on_chase_area_body_entered(body):
	if body == player:
		print("Gracz wszedł w zasięg pościgu!")
		chasing_player = true
		icon.show()
		if not sound_player.playing:
			sound_player.play()

func _on_chase_area_body_exited(body):
	if body == player:
		print("Gracz opuścił zasięg pościgu!")
		chasing_player = false
		icon.hide()
		if sound_player.playing:
			sound_player.stop()

func _on_touch_area_body_entered(body):
	if body == player:
		print("Przeciwnik wszedł do obszaru walki!")

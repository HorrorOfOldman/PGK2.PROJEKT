extends CharacterBody3D

@export var detection_radius := 5.0 # w metrach
@export var move_speed := 2.0 # prędkość poruszania się NPC po ścieżce

@onready var hero: Node3D = get_node("/root/TestEsk/MovementTest/Hero")
@onready var icon: Sprite3D = $Icon
@onready var textbox: Control = $textbox
@onready var sound_player: AudioStreamPlayer3D = $Sound
@onready var label: Label = textbox.get_node("Label")
@onready var path_follow: PathFollow3D = get_node("/root/TestEsk/MovementTest/Path3D_npc/PathFollow3D")

signal textbox_closed

var player_was_close := false
var dialog_completed := false
var moving_on_path := false

func _ready() -> void:
	textbox.hide()
	if path_follow:
		path_follow.progress_ratio = 0.0
	hide_dialog()

func _process(delta):
	if not hero:
		return

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

	if moving_on_path:
		move_along_path(delta)

func move_along_path(delta):
	Globalsy.Quest_key=3
	if not path_follow or not moving_on_path:
		return

	path_follow.progress_ratio += delta * move_speed * 0.1

	if path_follow.progress_ratio >= 1.0:
		path_follow.progress_ratio = 1.0
		global_position = path_follow.global_position
		moving_on_path = false
		Globalsy.Gate = true
	else:
		global_position = path_follow.global_position

func run_dialog_sequence() -> void:
	Globalsy.dialogue_active = true

	# Gdy klucz został już oddany
	if Globalsy.Quest_key == 3:
		await show_dialog("Nareszcie można opuścić tę dziurę!")

	# Gdy klucz został przyniesiony, a NPC jeszcze nie ruszył
	elif Globalsy.Quest_key == 2 and not moving_on_path:
		await show_dialog("Dziękuję, teraz możemy spróbować opuścić tę dziurę.")
		start_path_movement()

	# Początkowy dialog przed daniem klucza
	elif not dialog_completed:
		await show_dialog("Witaj w Łupinkach Łużyckich!")
		await show_dialog("Potrzebna jest nam twoja pomoc.")
		await show_dialog("Udaj się za karczmę i przynieś mi klucz, który tam się znajduje.")
		await show_dialog("Nie martw się, jest duży, znajdziesz go z palcem w nosie.")
		Globalsy.Quest_key = 1
		dialog_completed = true

	# Po rozpoczęciu questa, ale przed jego wykonaniem
	else:
		await show_dialog("No, już już, idź po klucz.")

	Globalsy.dialogue_active = false

func start_path_movement():
	moving_on_path = true
	if path_follow:
		path_follow.progress_ratio = 0.0
		path_follow.loop = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not event.is_echo():
		if textbox.visible:
			textbox.hide()
			emit_signal("textbox_closed")
		elif player_was_close and not Globalsy.dialogue_active:
			run_dialog_sequence()

func show_dialog(text: String) -> void:
	label.text = text
	textbox.show()
	await self.textbox_closed

func hide_dialog() -> void:
	textbox.hide()
	Globalsy.dialogue_active = false

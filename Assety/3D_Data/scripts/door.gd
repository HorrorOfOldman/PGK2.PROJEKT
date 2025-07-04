extends Node3D

@export var detection_radius := 5.0 # w metrach

@onready var hero: Node3D = get_node("/root/TestEsk/MovementTest/Hero")
@onready var icon: Sprite3D = $Icon
@onready var sound_player: AudioStreamPlayer3D = $Sound
@onready var textbox: Control = $textbox
@onready var label: Label = textbox.get_node("Label")

var player_was_close := false
var dialogue_visible := false

func _ready():
	textbox.hide()

func _process(_delta):
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

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not event.is_echo():
		if player_was_close:
			if dialogue_visible:
				textbox.hide()
				dialogue_visible = false
				Globalsy.dialogue_active = false  # 👉 odblokuj sterowanie
			else:
				label.text = "Zamknięte"
				textbox.show()
				dialogue_visible = true
				Globalsy.dialogue_active = true  # 👉 zablokuj sterowanie

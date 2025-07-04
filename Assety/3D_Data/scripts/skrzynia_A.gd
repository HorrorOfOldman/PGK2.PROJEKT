extends Node3D

@export var detection_radius := 6.0 
@onready var hero: Node3D = get_node("/root/TestKat/KatakumbyTest/Hero")
@onready var key: Sprite2D = get_node("/root/TestKat/Interface/klucz")
@onready var icon: Sprite3D = $Icon
@onready var textbox: Control = $textbox
@onready var sound_player: AudioStreamPlayer3D = $Sound
@onready var sound_player2: AudioStreamPlayer3D = $Sound2
@onready var label: Label = textbox.get_node("Label")

signal textbox_closed

var player_was_close := false
var dialog_shown := false
var dialog_finished := false
var interaction_disabled := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	textbox.hide()
	icon.hide()

func _process(delta):
	if interaction_disabled:
		return

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
	if interaction_disabled:
		return  # <--- ignoruj kliknięcia

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not event.is_echo():
		if textbox.visible:
			textbox.hide()
			emit_signal("textbox_closed")
		elif player_was_close and not dialog_shown:
			dialog_shown = true
			run_intro_dialog()

func run_intro_dialog() -> void:
	await show_dialog("Wybrałeś właściwą skrzynię, otrzymujesz klucz.")
	dialog_finished = true
	sound_player2.play()
	key.show()
	Globalsy.Quest_kat_key_1 = 3
	interaction_disabled = true 
	icon.hide()
	sound_player.stop()

func show_dialog(text: String) -> void:
	Globalsy.dialogue_active = true
	label.text = text
	textbox.show()
	await self.textbox_closed
	Globalsy.dialogue_active = false

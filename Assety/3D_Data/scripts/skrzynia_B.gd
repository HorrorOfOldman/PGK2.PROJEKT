extends Node3D

@export var detection_radius := 6.0 # w metrach
@onready var hero: Node3D = get_node("/root/TestKat/KatakumbyTest/Hero")
@onready var icon: Sprite3D = $Icon
@onready var textbox: Control = $textbox
@onready var sound: AudioStreamPlayer3D = $Sound
@onready var label: Label = textbox.get_node("Label")
@onready var walka : Node2D = $walka

signal textbox_closed

var player_was_close := false
var dialog_shown := false
var dialog_finished := false
var interaction_disabled := false
var walka_stan := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	textbox.hide()
	icon.hide()
	walka.hide()

func _process(delta):
	# Sprawdź, czy trzeba wyłączyć interakcję
	if Globalsy.Quest_kat_key_1 == 3:
		interaction_disabled = true
		icon.hide()
		sound.stop()

	if interaction_disabled:
		return

	if not hero:
		return

	var distance = global_position.distance_to(hero.global_position)

	if distance <= detection_radius:
		icon.show()
		if not player_was_close:
			player_was_close = true
			if not sound.playing:
				sound.play()
	else:
		icon.hide()
		player_was_close = false

func _input(event):
	if interaction_disabled:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not event.is_echo():
		if textbox.visible:
			textbox.hide()
			emit_signal("textbox_closed")
		elif player_was_close and not dialog_shown:
			dialog_shown = true
			run_intro_dialog()

func run_intro_dialog() -> void:
	await show_dialog("Bardzo się starałeś, ale nie tą skrzynię wybrałeś.")
	dialog_finished = true
	interaction_disabled = true
	icon.hide()
	sound.stop()
	Globalsy.dialogue_active = true
	walka.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Globalsy.fight = true
	Globalsy.f1 = true
	

func show_dialog(text: String) -> void:
	Globalsy.dialogue_active = true
	label.text = text
	textbox.show()
	await self.textbox_closed
	Globalsy.dialogue_active = false

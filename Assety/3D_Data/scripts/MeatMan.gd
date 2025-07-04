extends Node3D

@export var detection_radius := 6.0 # w metrach
@onready var hero: Node3D = get_node("/root/TestKat/KatakumbyTest/Hero")
@onready var icon: Sprite3D = $Icon
@onready var textbox: Control = $textbox
@onready var sound_player: AudioStreamPlayer3D = $Sound
@onready var label: Label = textbox.get_node("Label")
@onready var walka : Node2D = $walka

signal textbox_closed

var player_was_close := false
var sound_played := false
var dialog_finished := false
var interaction_disabled := false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	textbox.hide()
	icon.hide()
	walka.hide()

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
			sound_player.play() # gra zawsze gdy gracz wchodzi w zasięg
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
		elif player_was_close:
			run_intro_dialog()

func run_intro_dialog() -> void:
	sound_player.play()
	await show_dialog("Leeeeellleeeeee!")
	sound_player.play()
	await show_dialog("Wllelelelelelllle!")
	sound_player.play()
	await show_dialog("Walea La La!")

	dialog_finished = true
	interaction_disabled = true  # ZABLOKUJ PONOWNĄ INTERAKCJĘ

	Globalsy.dialogue_active = true
	walka.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Globalsy.fight = true
	Globalsy.fightMM = true
	Globalsy.fMM=true

func show_dialog(text: String) -> void:
	Globalsy.dialogue_active = true
	label.text = text
	textbox.show()
	await self.textbox_closed
	Globalsy.dialogue_active = false

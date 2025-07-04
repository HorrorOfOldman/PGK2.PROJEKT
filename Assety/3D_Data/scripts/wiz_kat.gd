extends Node3D

@export var detection_radius := 10.0 # w metrach
@onready var hero: Node3D = get_node("/root/TestKat/KatakumbyTest/Hero")
@onready var icon: Sprite3D = $Icon
@onready var textbox: Control = $textbox
@onready var sound_player: AudioStreamPlayer3D = $Sound
@onready var label: Label = textbox.get_node("Label")

signal textbox_closed

var player_was_close := false
var sound_played := false
var dialog_shown := false
var dialog_finished := false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	textbox.hide()
	icon.hide()

func _process(delta):
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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not event.is_echo():
		if textbox.visible:
			textbox.hide()
			emit_signal("textbox_closed")
		elif player_was_close:
			if not dialog_shown:
				dialog_shown = true
				run_intro_dialog()
			elif dialog_finished:
				run_repeat_dialog()

func run_intro_dialog() -> void:
	await show_dialog("Dobra, trafiliśmy do katakumb.")
	await show_dialog("Udaj się do sali z czaszką i pokonaj złą wiedźmę")
	await show_dialog("Jest na drugim końcu sali, zobaczysz po świecących oczach.")
	await show_dialog("Jak widzisz, pomyliłem się w zaklęciu teleportacyjnym,")
	await show_dialog("I trafiłem do celi, musisz dać sobie sam radę.")
	await show_dialog("Powodzenia!")
	dialog_finished = true

func run_repeat_dialog() -> void:
	await show_dialog("Wierzę w ciebie, o Zbysławie.")

func show_dialog(text: String) -> void:
	Globalsy.dialogue_active = true
	label.text = text
	textbox.show()
	await self.textbox_closed
	Globalsy.dialogue_active = false

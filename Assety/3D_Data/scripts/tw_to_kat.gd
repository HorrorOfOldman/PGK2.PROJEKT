extends Node3D

@export var detection_radius := 5.0 # w metrach
@onready var hero: Node3D = get_node("/root/TestEsk/MovementTest/Hero")
@onready var anim_player: AnimationPlayer = get_node("/root/TestEsk/Interface/AnimationPlayer")
@onready var transition_node = get_node("/root/TestEsk/Interface/Przejscie")
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
			if not sound_played:
				
				sound_player.play()
				sound_played = true
	else:
		icon.hide()
		player_was_close = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not event.is_echo():
		if textbox.visible:
			textbox.hide()
			emit_signal("textbox_closed")
			if dialog_finished:
				transition_node.show()
				anim_player.play("fight_in")
				await anim_player.animation_finished
				get_tree().change_scene_to_file("res://Assety/scenes/exploration/TestKat.tscn")
		elif player_was_close and not dialog_shown:
			dialog_shown = true
			run_intro_dialog()

func run_intro_dialog() -> void:
	#Globalsy.dialogue_active = true
	await show_dialog("Nareszcie, wybraniec który spadł mnie z nieba!")
	await show_dialog("Ruszajmy pokonać złą wiedźmę i uratować świat!")
	await show_dialog("Dla bezpieczeństwa nałożę na ciebie zaklęcie,")
	await show_dialog("aby teleportacja ci kich nie wykręciła.")
	await show_dialog("SILURUS REX AQUARUM!")
	await show_dialog("A teraz teleportacja do złej wiedźmy!")
	await show_dialog("HOKUS POKUS!")
	await show_dialog("SZURUM BURUM!")
	await show_dialog("MYCOŃ TAŃCUJE W BÓLU!")
	dialog_finished = true
	# Kliknięcie zamykające drugi dialog odpali scenę

func show_dialog(text: String) -> void:
	Globalsy.dialogue_active = true
	label.text = text
	textbox.show()
	await self.textbox_closed
	Globalsy.dialogue_active = false

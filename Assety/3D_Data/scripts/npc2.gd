extends CharacterBody3D

@export var detection_radius := 5.0
@export var move_speed := 2.0
@onready var hero: Node3D = get_node("/root/TestKat/KatakumbyTest/Hero")
@onready var icon: Sprite3D = $Icon
@onready var textbox: Control = $textbox
@onready var sound_player: AudioStreamPlayer3D = $Sound
@onready var label: Label = textbox.get_node("Label")
@onready var path_follow: PathFollow3D = get_node("/root/TestKat/KatakumbyTest/droga/PathFollow3D")
@onready var key: Sprite2D = get_node("/root/TestKat/Interface/klucz")

signal textbox_closed

var player_was_close := false
var dialog_completed := false
var moving_on_path := false
var has_walked_path := false
var go_to_end_after_quest := false
var reward_given := false # 🆕 Dodatkowa flaga, by dać nagrodę tylko raz
var interaction_disabled := false # 🆕 Blokowanie interakcji po nagrodzie

func _ready() -> void:
	textbox.hide()
	if path_follow:
		path_follow.progress_ratio = 0.0
	hide_dialog()

func _process(delta):
	if not hero or interaction_disabled:
		icon.hide()
		player_was_close = false
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
	if not path_follow or not moving_on_path:
		return

	path_follow.progress_ratio += delta * move_speed * 0.07

	if go_to_end_after_quest:
		if path_follow.progress_ratio >= 1.0:
			#key.hide()
			path_follow.progress_ratio = 1.0
			global_position = path_follow.global_position
			moving_on_path = false
			go_to_end_after_quest = false
			Globalsy.Quest_kat_key_1 = 4
			#key.hide()
		else:
			global_position = path_follow.global_position
	else:
		if path_follow.progress_ratio >= 0.3725:
			path_follow.progress_ratio = 0.3725
			global_position = path_follow.global_position
			moving_on_path = false
			has_walked_path = true
			Globalsy.Quest_kat_key_1 = 2
		else:
			global_position = path_follow.global_position

func run_dialog_sequence() -> void:
	if interaction_disabled:
		return

	Globalsy.dialogue_active = true

	if Globalsy.MM_ded and not reward_given:
		await show_dialog("Nareszcie, mityczne nieskończone mięso jest moje!")
		await show_dialog("Masz to co ci obiecałem, klucz do dziwnych drzwi.")
		Globalsy.Quest_kat_key_1 = 5
		Globalsy.MM_ded = false
		reward_given = true
		interaction_disabled = true

		icon.hide()
		sound_player.stop()

		Globalsy.dialogue_active = false
		return

	if Globalsy.Quest_kat_key_1 == 3:
		await show_dialog("Tak, przynieś mięska papusiowi...")
		key.hide()
		go_to_end_after_quest = true
		start_path_movement()

	elif Globalsy.Quest_kat_key_1 == 2 and not moving_on_path and not has_walked_path:
		await show_dialog("Leć po klucz!")

	elif not dialog_completed:
		await show_dialog("Yyyyy!")
		await show_dialog("Dobra, nie wiem kim jesteś, ale sie nam przydasz.")
		await show_dialog("Zapewne zauważyłeś tych cieci w klatce za mną.")
		await show_dialog("Chce się nam jeść, przynieś nam nieskończonego Mięso Ludzia.")
		await show_dialog("Jest w sali na lewo, ale klucz do sali jest w sali na prawo.")
		await show_dialog("Jest on w jednej ze skrzyń na górze sali.")
		await show_dialog("Wybierz właściwą!")
		await show_dialog("Żeby się tam dostać, będziesz musiał skakać po stolikach.")
		await show_dialog("Jedyne co mogę ci zalecić, to unikaj niepotrzybnych walek.")
		await show_dialog("Jak ci się uda, to dam ci klucz do sali z tą śmieszną czaszką u góry.")
		dialog_completed = true
		start_path_movement()
	else:
		await show_dialog("Ruszaj się!")

	Globalsy.dialogue_active = false

func start_path_movement():
	moving_on_path = true
	if path_follow:
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

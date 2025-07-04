extends Node3D

@export var detection_radius := 5.0

@onready var hero: Node3D = get_node("/root/TestKat/KatakumbyTest/Hero")
@onready var icon: Sprite3D = $Icon
@onready var sound_player: AudioStreamPlayer3D = $Brama_op
@onready var textbox: Control = $textbox
@onready var label: Label = textbox.get_node("Label")
@onready var anim: AnimationPlayer = get_node("/root/TestKat/KatakumbyTest/Animacje")

var player_was_close := false
var dialogue_visible := false
var anim_triggered := false
var interaction_finished := false # << Zabezpieczenie po użyciu klucza

func _ready():
	textbox.hide()
	print("Textbox hidden in _ready()")

func _process(_delta):
	if interaction_finished: # Jeśli zakończona interakcja — wyjdź
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

func _on_anim_finished(name):
	if name == "B_B_MV":
		Globalsy.Quest_kat_key_1 = 6
		interaction_finished = true # << Zablokuj dalsze interakcje
		queue_free()

func _input(event):
	if interaction_finished:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not event.is_echo():
		if player_was_close:
			if dialogue_visible:
				textbox.hide()
				dialogue_visible = false
				Globalsy.dialogue_active = false
			else:
				if Globalsy.Quest_kat_key_1 == 5 and not anim_triggered:
					anim_triggered = true
					interaction_finished = true # ⬅️ Interakcja zakończona NATYCHMIAST
					if anim.has_animation("B_B_MV"):
						anim.play("B_B_MV")
						anim.animation_finished.connect(_on_anim_finished)
				else:
					label.text = "Potrzebujesz klucza!"
					textbox.show()
					dialogue_visible = true
					Globalsy.dialogue_active = true

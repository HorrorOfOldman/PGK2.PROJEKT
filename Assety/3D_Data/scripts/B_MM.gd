extends Node3D

@onready var anim_player: AnimationPlayer = get_node("/root/TestKat/KatakumbyTest/Animacje")
@onready var sound_player: AudioStreamPlayer3D = $Brama_op

var quest_triggered := false

func _process(delta: float) -> void:
	if Globalsy.Quest_kat_key_1 == 4 and not quest_triggered:
		quest_triggered = true
		play_quest_animation_and_sound()

func play_quest_animation_and_sound():
	if anim_player.has_animation("B_MM_MV"):
		anim_player.play("B_MM_MV")

	if sound_player.stream:
		sound_player.play()

extends Node

signal textbox_closed
@onready var ambient: AudioStreamPlayer = get_node("/root/TestKat/KatakumbyTest/Ambient")
@onready var ambient1: AudioStreamPlayer = get_node("/root/TestKat/KatakumbyTest/Ambient2")


func _ready():
	ambient.play()
	ambient1.stop()
	set_health($Interface/Avatar8BitFrame/HeroInfo/Hp,State.current_health, State.max_health)
	set_mana($Interface/Avatar8BitFrame/HeroInfo/Mp,State.current_mana, State.max_mana)
	$Interface/klucz.hide()
	$Interface/klucz_boss.hide()
	$Interface/miecho.hide()
	$Interface/QuestInfo.hide()
	$Interface/textbox.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Interface/Przejscie.show()
	$Interface/AnimationPlayer.play("fight_out")
	await $Interface/AnimationPlayer.animation_finished
	$Interface/Przejscie.hide()
	$Interface/Avatar8BitFrame.show

func _process(delta: float):
	if !Globalsy.fight:
		$Interface.show()
		if not ambient.playing:
			ambient.play()
	else:
		$Interface.hide()
		if ambient.playing:
			ambient.stop()
		if ambient1.playing:
			ambient1.stop()
			
	if Globalsy.MM_ded:
		$Interface/miecho.show()
	else:
		$Interface/miecho.hide()

	if Globalsy.Quest_kat_key_1==5:
		$Interface/klucz_boss.show()
		ambient.stop()
	else:
		$Interface/klucz_boss.hide()
		ambient1.play()
		
	set_health($Interface/Avatar8BitFrame/HeroInfo/Hp,State.current_health, State.max_health)
	set_mana($Interface/Avatar8BitFrame/HeroInfo/Mp,State.current_mana, State.max_mana)
	
	
func display_text(text):
	Globalsy.dialogue_active = true  # zablokuj sterowanie
	if $Interface/textbox.has_node("Label"):
		$Interface/textbox.show()
		$Interface/textbox/Label.text = text
	await self.textbox_closed
	Globalsy.dialogue_active = false  # odblokuj sterowanie

func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP: %d/%d" % [health, max_health]

func set_mana(progress_bar, mana, max_mana):
	progress_bar.value = mana
	progress_bar.max_value = max_mana	
	progress_bar.get_node("Label").text = "MP: %d/%d" % [mana, max_mana]

func _input(event):
	if event.is_action_pressed("tett"):
		print("State - hp - %d, mp - %d" % [State.current_health, State.current_mana])

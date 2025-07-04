extends Node

signal textbox_closed


var startup := true

func _ready():
	
	set_health($Interface/Avatar8BitFrame/HeroInfo/Hp,State.current_health, State.max_health)
	set_mana($Interface/Avatar8BitFrame/HeroInfo/Mp,State.current_mana, State.max_mana)
	$Interface/klucz.hide()
	$Interface/QuestInfo.hide()
	$Interface/Przejscie.hide()
	
	display_text("Rozpocząłeś swoją przygodę, Zbysławie!")
	await self.textbox_closed
	display_text("Więc miej się na baczności.")
	await self.textbox_closed
	display_text("Może uratowanie świata nie jest twoim celem,")
	await self.textbox_closed
	display_text("ale za to możesz spróbować uciec z tej przeklętej twierdzy.")
	await self.textbox_closed

func _process(delta):
	if Globalsy.Quest_key == 2:
		if not $Interface/klucz.visible:
			$Interface/klucz.show()
	else:
		if $Interface/klucz.visible:
			$Interface/klucz.hide()

func _input(event):
	if $Interface/textbox.visible and (
		(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not event.is_echo())
		or Input.is_action_just_pressed("ui_accept")
	):
		$Interface/textbox.hide()
		emit_signal("textbox_closed")

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

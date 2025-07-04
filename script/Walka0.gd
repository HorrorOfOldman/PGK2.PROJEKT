extends Node2D

signal textbox_closed

@export var enemy :Resource = null

var current_player_health = 0
var current_player_mana = 0
var current_enemy_health = 0
var is_defending = false

var czar_id=0
var czar_ch=false
var czar_ef=0

var item_id=0
var item_il = []
var item_ch=false

var efekt_czaru_aktywny = false
var tury_efektu_czaru = 0

var czekaj_na_textbox_zamkniecie = false#flaga upewniajaca sie z zamknięciem okna tekstowego

func _ready():
	State.spell_init()
	State.item_init()
	#$dzwieki.stream.loop = true
	#$dzwieki.play()#granie muzyczki
	choose_music()
	set_health($EnemyContainer/ProgressBar,enemy.health, enemy.health)
	set_health($PlayerPanel/PlayerData/Label/Health,State.current_health, State.max_health)
	set_mana($PlayerPanel/PlayerData/Label/Mana,State.current_mana, State.max_mana)
	$EnemyContainer/EnemyjegoWrogość.texture = enemy.texture
	
	current_player_health = State.current_health
	current_player_mana = State.current_mana
	current_enemy_health = enemy.health
	
	$zaklecia/Spell1.text = State.spell[0]
	$zaklecia/Spell2.text = State.spell[1]
	$zaklecia/Spell3.text = State.spell[2]
	
	$ekwipunek/it_1/Item_1.text = State.item[0]
	$ekwipunek/it_2/Item_2.text = State.item[1]
	$ekwipunek/it_3/Item_3.text = State.item[2]
	
	$ekwipunek/it_1/it_1_il.text = str(State.item_amount[0])
	$ekwipunek/it_2/it_2_il.text = str(State.item_amount[1])
	$ekwipunek/it_3/it_3_il.text = str(State.item_amount[2])
	
	for i in range(3):
		item_il.append(State.item_amount[i])
		print("Przedmiot %d w ilości = %d"%[i,item_il[i]])
	
	$tło/lv_1.hide()
	$tło/lv_2.hide()
	$tło/lv_3.hide()
	$tło.show()
	choose_background()
	$textbox.hide()
	$ActionPanel.hide()
	$EnemyContainer.hide()
	$zaklecia.hide()
	$ekwipunek.hide()
	$PlayerPanel.hide()
	$back.hide()
	$GameOver.hide()
	
	display_text("Dziki %s Atakuje!"%enemy.name.to_upper())
	await self.textbox_closed
	$ActionPanel.show()
	$EnemyContainer.show()#bez tej linijki nei widać ciosmaka
	$EnemyContainer/ProgressBar.show()
	$PlayerPanel.show()

#-------------------------------------------------------------------

#ustawienie HP i MP
func set_health(progress_bar, health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP: %d/%d" % [health, max_health]
func set_mana(progress_bar, mana, max_mana):
	progress_bar.value = mana
	progress_bar.max_value = max_mana	
	progress_bar.get_node("Label").text = "MP: %d/%d" % [mana, max_mana]

#wykrywa kliknięcie myszką i zamyka okno tekstowe
func _input(_event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and $textbox.visible:
		$textbox.hide()
		emit_signal("textbox_closed")

#wyswietla naszą "chmurkę" z tekstem
func display_text(text):
	if $textbox.has_node("Label"):
		$ActionPanel.hide()
		$zaklecia.hide()
		$textbox.show()
		$textbox/Label.text = text

#wybieranie tła na podstawie poziomu przeciwnika
func choose_background():
	if enemy.level==1:
		$"tło/lv_1".show()
	if enemy.level==2:
		$"tło/lv_2".show()
	if enemy.level==3:
		$"tło/lv_3".show()

#granie muzyki na podstawie poziomu przeciwnika
func choose_music():
	if enemy.level==1:
		$dzwieki/e_lv1.stream.loop = true
		$dzwieki/e_lv1.play()
	if enemy.level==2:
		$dzwieki/e_lv2.stream.loop = true
		$dzwieki/e_lv2.play()
	if enemy.level==3:
		$dzwieki/e_lv3.stream.loop = true
		$dzwieki/e_lv3.play()

#tura przeciwnika
func enemy_turn():
	$dzwieki/enemy_turn.play()

	if efekt_czaru_aktywny:
		current_enemy_health -= 5
		tury_efektu_czaru -= 1
		set_health($EnemyContainer/ProgressBar, current_enemy_health, enemy.health)
		display_text("Przeciwnik dostaje 5 obrażeń od efektu zaklęcia!")
		$AnimationPlayer.play("enemy_fire_effect")
		await $AnimationPlayer.animation_finished
		await self.textbox_closed

		if current_enemy_health <= 0:
			display_text("Przeciwnik %s padł od powikłań zaklęcia!" % enemy.name)
			await self.textbox_closed
			$dzwieki/dead.play()
			$dzwieki/win.play()
			$AnimationPlayer.play("enemy_died")
			await $AnimationPlayer.animation_finished
			await get_tree().create_timer(4.5).timeout
			get_tree().change_scene_to_file("res://Assety/scenes/menu/start_menu.tscn")

		if tury_efektu_czaru <= 0:
			efekt_czaru_aktywny = false

	# Tylko jeśli przeżył — atakuje
	display_text("%s atakuje!" % enemy.name.to_upper())
	await self.textbox_closed

	if is_defending:
		is_defending = false
		$AnimationPlayer.play("mini_shake")
		await $AnimationPlayer.animation_finished
		display_text("Jakimś cudem się udało wybronić!")
		await self.textbox_closed
	else:
		current_player_health -= enemy.damage
		set_health($PlayerPanel/PlayerData/Label/Health, current_player_health, State.max_health)
		$AnimationPlayer.play("shake")
		await $AnimationPlayer.animation_finished
		display_text("Jesteś bliższy do grobowej deski\n o %d HP!" % enemy.damage)
		await self.textbox_closed

		if current_player_health <= 0:
			display_text("Misja twa ukończona nie tak jak chciałeś!")
			await self.textbox_closed
			$dzwieki/player_dead.play()
			$AnimationPlayer.play("GameOver")
			$GameOver.show()
			await $AnimationPlayer.animation_finished
			await get_tree().create_timer(2.0).timeout
			get_tree().change_scene_to_file("res://Assety/scenes/menu/start_menu.tscn")

	$ActionPanel.show()

#ucieczka przed przeciwnikiem
func _on_RUN_pressed():
	if enemy.level==1:#prosty/podstawowy przeciwnik
		display_text("Ucieczka ukończona powodzeniem!")
		await self.textbox_closed
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://Assety/scenes/menu/start_menu.tscn")
	
	if enemy.level==2:#przeciwnik przed którym można zwiać, ale to ależy od szczęścia(losowanie)
		var los = randi_range(1, 21)  # Losowanie liczby od 1 do 21
		print("Wylosowano:", los)  # Debug, aby zobaczyć wynik losowania
		if los<16:
			display_text("Nie udało się zwiać!")
			await self.textbox_closed
			enemy_turn()
			
		elif los>15:
			display_text("Udało się zwiać!")
			await self.textbox_closed
			await get_tree().create_timer(0.5).timeout
			get_tree().change_scene_to_file("res://Assety/scenes/menu/start_menu.tscn")

	if enemy.level==3:#przeciwnik bardzo trudny, boss, przed nim nie uciekniesz
		display_text("Nie da się uciec! Oczekuj śmierci!")
		await self.textbox_closed
		enemy_turn()

#prosty atak
func _on_ATTACK_pressed():
	display_text("Uderzyłeś swym potężnym mieczem!")
	await self.textbox_closed
	
	current_enemy_health -= State.damage
	set_health($EnemyContainer/ProgressBar,current_enemy_health,enemy.health)
	$AnimationPlayer.play("enemy_damaged")
	await $AnimationPlayer.animation_finished
	
	display_text("Uderzyłeś z siłą %d punktów!"%State.damage)
	await self.textbox_closed
	
	if current_enemy_health <= 0:
		display_text("Przeciwnik %s został pokonany!"%enemy.name)
		await self.textbox_closed
		$dzwieki/dead.play()
		$dzwieki/win.play()
		$AnimationPlayer.play("enemy_died")
		await $AnimationPlayer.animation_finished
		await get_tree().create_timer(4.5).timeout
		get_tree().change_scene_to_file("res://Assety/scenes/menu/start_menu.tscn")
	enemy_turn()

#atak zaklęciem
func _on_MAGIC_pressed():
	$ActionPanel.hide()
	$zaklecia.show()
	$back.show()

#wybór przedmiotu
func _on_ITEMS_pressed():
	$ActionPanel.hide()
	$ekwipunek.show()
	$back.show()

#wykonanie zaklęcia
func wykonaj_czar():
	$zaklecia.hide()
	$back.hide()
	
	if current_player_mana - State.spell_cost[czar_id] < 0:
		display_text("Masz za mało many na użycie czaru!")
		await self.textbox_closed
		$ActionPanel.show()
		return

	display_text("Użyłeś zaklęcia %s!" % State.spell[czar_id])
	await self.textbox_closed

	current_enemy_health -= State.spell_dmg[czar_id]
	current_player_mana -= State.spell_cost[czar_id]
	if State.spell_effect[czar_id] == 1:
		efekt_czaru_aktywny = true
		tury_efektu_czaru = 3

	set_health($EnemyContainer/ProgressBar, current_enemy_health, enemy.health)
	set_mana($PlayerPanel/PlayerData/Label/Mana, current_player_mana, State.max_mana)

	$AnimationPlayer.play("enemy_damaged")
	await $AnimationPlayer.animation_finished

	display_text("Wyczarowałeś z siłą %d punktów !\nUżyłeś %d punktów many!" %
		[State.spell_dmg[czar_id], State.spell_cost[czar_id]])
	await self.textbox_closed

	if current_enemy_health <= 0:
		display_text("Przeciwnik %s został pokonany!" % enemy.name)
		await self.textbox_closed
		$dzwieki/dead.play()
		$dzwieki/win.play()
		$AnimationPlayer.play("enemy_died")
		await $AnimationPlayer.animation_finished
		await get_tree().create_timer(4.5).timeout
		get_tree().change_scene_to_file("res://Assety/scenes/menu/start_menu.tscn")
	else:
		enemy_turn()

#wykonanie użycia przedmiotu
func uzyj_przedmiot():
	$ekwipunek.hide()
	$back.hide()

	if item_il[item_id] <= 0:
		display_text("Nie masz więcej sztuk przedmiotu!")
		await self.textbox_closed
		$ActionPanel.show()
		return

	display_text("Użyłeś %s!" % State.item[item_id])
	await self.textbox_closed

	match State.item_effect[item_id]:
		0:
			current_player_health = min(current_player_health + 20, State.max_health)#zabezpieczenie by nie wyjść poza zakres, czyli mieć 50/30 HP
			display_text("Odzyskałeś 20 punktów zdrowia!")
		1:
			current_player_mana = min(current_player_mana + 20, State.max_mana)
			display_text("Odzyskałeś 20 punktów many!")
		2:
			current_player_health = min(current_player_health + 10, State.max_health)
			current_player_mana = min(current_player_mana + 10, State.max_mana)
			display_text("Odzyskałeś 10 punktów zdrowia i 10 many!")
	await self.textbox_closed

	item_il[item_id] -= 1
	State.item_amount[item_id] = item_il[item_id]  # synchronizacja stanu z zewnętrznym stanem gry

	# Odśwież etykietkę ilości przedmiotu
	match item_id:
		0:
			$ekwipunek/it_1/it_1_il.text = str(item_il[item_id])
		1:
			$ekwipunek/it_2/it_2_il.text = str(item_il[item_id])
		2:
			$ekwipunek/it_3/it_3_il.text = str(item_il[item_id])

	# Odśwież HP i MP na panelu
	set_health($PlayerPanel/PlayerData/Label/Health, current_player_health, State.max_health)
	set_mana($PlayerPanel/PlayerData/Label/Mana, current_player_mana, State.max_mana)

	enemy_turn()

#1 czar gdy wybrny
func _on_spell_1_pressed():
	czar_id = 0
	print("Wybrano zaklęcie 1")
	wykonaj_czar()

#2 czar gdy wybrny
func _on_spell_2_pressed():
	czar_id = 1
	print("Wybrano zaklęcie 2")
	wykonaj_czar()

#3 czar gdy wybrny
func _on_spell_3_pressed():
	czar_id = 2
	print("Wybrano zaklęcie 3")
	wykonaj_czar()

#1 przedmiot gdy wybrny
func _on_item_1_pressed():
	item_id = 0
	print("Wybrano przedmiot 1")
	uzyj_przedmiot()

#2 przedmiot gdy wybrny
func _on_item_2_pressed():
	item_id = 1
	print("Wybrano przedmiot 2")
	uzyj_przedmiot()

#3 przedmiot gdy wybrny
func _on_item_3_pressed():
	item_id = 2
	print("Wybrano przedmiot 3")
	uzyj_przedmiot()

#powórt do głównego menu gdy gdy jednak nie chcemy czarować/użyć przedmiotu
func _on_back_pressed():
	$zaklecia.hide()
	$ekwipunek.hide()
	$back.hide()
	$ActionPanel.show()

extends Node
#flagi opcji i animacji
var choose := true	#flaga informująca że można zapętlać animację
var m1Ch := true	#flaga  pozwalajaca na uzycie menu1
var m2Ch := false	#flaga  pozwalajaca na uzycie menu2

#ukazuje potrzebny nam interfejs w chwili uruchomienia gry, oraz uruchamia zapętloną animację kamery
func _ready():
	$inter.show()
	$inter/inter_1.show()
	$inter/inter_2.hide()
	$music.play()
	cam_anim_loop()

#zapętlona animacja kamery
func cam_anim_loop():
	if not choose:
		return
	$animki.play("camera_move")
	await $animki.animation_finished
	cam_anim_loop()

#kliknięcei start w menu1, przejścei do menu2
func _on_start_pressed():
	print("START clicked, m1Ch:", m1Ch)
	print("				, m2Ch:", m2Ch)
	if m1Ch:
		choose = false
		$animki.stop()
		$animki.play("inter_1_hide")
		await $animki.animation_finished

		$inter/inter_1.hide()
		$animki.play("camera_chPos")
		await $animki.animation_finished

		$inter/inter_2.show()
		$animki.play("inter_2_show")
		await $animki.animation_finished

		m1Ch = false
		m2Ch = true

#cofnięcie do menu1
func _on_back_pressed():
	print("BACK clicked, m2Ch:", m2Ch)
	print("			, m1Ch:", m1Ch)
	if m2Ch:
		choose = true
		$animki.stop()
		$animki.play("inter_2_hide")
		await $animki.animation_finished

		$inter/inter_2.hide()
		$animki.play("camera_chPos_back")
		await $animki.animation_finished

		$inter/inter_1.show()
		$animki.play("inter_1_show")
		await $animki.animation_finished

		m1Ch = true
		m2Ch = false
		cam_anim_loop()

#opuszczenie dema
func _on_quit_pressed():
	if m1Ch:
		choose = false
		m1Ch = false
		get_tree().quit(0)

#przejście do sceney z przeciwnikiem na poziomie 1
func _on_lv_1_pressed():
	get_tree().change_scene_to_file("res://Assety/scenes/fight/l1_fight.tscn")

#przejście do sceney z przeciwnikiem na poziomie 2
func _on_lv_2_pressed():
	get_tree().change_scene_to_file("res://Assety/scenes/fight/l2_fight.tscn")

#przejście do sceney z przeciwnikiem na poziomie 3
func _on_lv_3_pressed():
	get_tree().change_scene_to_file("res://Assety/scenes/fight/l3_fight.tscn")


func _on_world_map_pressed() -> void:
	get_tree().change_scene_to_file("res://Assety/scenes/exploration/TEST_esk.tscn")

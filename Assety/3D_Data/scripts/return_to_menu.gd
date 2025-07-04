extends CanvasLayer

var anim_enf :=false

func _ready() -> void:
	$Node3D/StaticBody3D.hide()
	$Node3D/Label3D.hide()
	$Node3D/napisy.show()
	$Node3D/AnimationPlayer.play("napisy")
	await $Node3D/AnimationPlayer.animation_finished
	$Node3D/napisy.hide()
	anim_enf=true
	$Node3D/StaticBody3D.show()
	$Node3D/Label3D.show()

func _input(event):
	if anim_enf:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_tree().quit()
		#get_tree().change_scene_to_file("res://Assety/scenes/menu/start_menu.tscn")

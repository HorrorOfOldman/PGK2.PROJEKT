extends Node3D

var gate_opened := false

func _ready():
	$AnimationPlayer.play("gate_down")

func _process(delta):
	if Globalsy.Gate and not gate_opened:
		$AnimationPlayer.play("gate_up")
		gate_opened = true

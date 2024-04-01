extends Node2D

signal trigger_chkpt
@export var next_level: PackedScene

func _on_ending_area_2d_body_entered(body):
	AudioPlayer.stop_all()
	AudioPlayer.play("ending")
	get_tree().change_scene_to_packed(next_level)

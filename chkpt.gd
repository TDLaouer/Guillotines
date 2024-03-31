extends Node2D

@onready var shape = $rope/chkpt_rope_Area2D/chkpt_rope_CollisionShape2D
@onready var rope = $rope

signal trigger_chkpt

func _on_area_2d_body_entered(body):
	trigger_chkpt.emit(rope.global_position)
	shape.set_deferred("disabled", true)
	rope.visible = false
	
	
	


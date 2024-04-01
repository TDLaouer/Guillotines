extends CharacterBody2D

var SPEED = 150.0
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_joy_button_pressed(0,JOY_BUTTON_Y) or Input.is_action_pressed("corde_jaune"):
		velocity.y = 1 + SPEED
		timer.start()
	elif timer.is_stopped():
		velocity.y = 1 + -SPEED
	else:
		velocity.y = 0
	move_and_slide()


func _on_timer_timeout():
	pass # Replace with function body.

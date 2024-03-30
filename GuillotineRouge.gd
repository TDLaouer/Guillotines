extends CharacterBody2D

var SPEED = 400.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_joy_button_pressed(0,JOY_BUTTON_B) :
		velocity.y = 1 + SPEED
	else :
		velocity.y = 1 + -SPEED
		
	move_and_slide()

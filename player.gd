extends CharacterBody2D

@export var move_speed = 400 # Vitesse du player en pixels/sec
@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float

var screen_size

# Methode appelee lorsque l'objet "entre dans le scene tree" pour la premiere fois
func _ready():
	velocity = Vector2.ZERO
	screen_size = get_viewport_rect().size

# Methode appelee à chaque frame calculee
func _physics_process(delta):
	velocity.y += get_gravity() * delta
	velocity.x = get_input_velocity() * move_speed

	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	if $AnimatedSprite2D.animation == "jump" and $AnimatedSprite2D.frame == 3 :
		$AnimatedSprite2D.animation = "float"
		
	if is_on_floor() and $AnimatedSprite2D.animation == "float":
		$AnimatedSprite2D.animation = "land"
		
	if velocity.x != 0:
		$AnimatedSprite2D.flip_v = false
		# See the note below about boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
		if is_on_floor():
			if $AnimatedSprite2D.animation != "land" or $AnimatedSprite2D.frame == 1:
				$AnimatedSprite2D.animation = "walk"
	elif is_on_floor():
		if $AnimatedSprite2D.animation != "land" or $AnimatedSprite2D.frame == 1:
			$AnimatedSprite2D.animation = "idle"
		
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		$AnimatedSprite2D.animation = "jump"
		$jump_AudioStreamPlayer2D.play()
		jump()
	
	if !is_on_floor() :
		if $AnimatedSprite2D.animation == "walk" or $AnimatedSprite2D.animation == "idle":
			$AnimatedSprite2D.animation = "jump"

	move_and_slide()

func jump():
	velocity.y = ((2.0 * jump_height)  / jump_time_to_peak) * -1.0

func get_gravity():
	if velocity.y < 0:
		return ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1
	else: 
		return ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1

func get_input_velocity():
	var horizontalVelocity := 0
	
	if Input.is_action_pressed("move_left"):
		horizontalVelocity -= 1
	if Input.is_action_pressed("move_right"):
		horizontalVelocity += 1
		
	return horizontalVelocity

# Methode appelee au demarrage/reset de la partie
func start(pos):
	position = pos
	show()
	$CollisionShape2D.set_deferred("disabled", false)

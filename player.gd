extends CharacterBody2D
signal game_over

@export var move_speed = 400 # Vitesse du player en pixels/sec
@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float

var grabbing_wall_jump_time_to_descent
var initial_jump_time_to_descent
var last_velocity_x

var is_grabbing_wall = false
var is_jumping = false
var is_floating = false

var screen_size

# Methode appelee lorsque l'objet "entre dans le scene tree" pour la premiere fois
func _ready():
	velocity = Vector2.ZERO
	screen_size = get_viewport_rect().size
	initial_jump_time_to_descent = jump_time_to_descent
	grabbing_wall_jump_time_to_descent = 200

# Methode appelee à chaque frame calculee
func _physics_process(delta):
	if is_on_floor():
		set_is_landing()

	velocity.y += get_gravity() * delta
	
	if !is_jumping:
		velocity.x = get_input_velocity() * move_speed

	sprite_animation()

	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "Guillotine3" and collision.get_collider_shape_index() == 1:
			hide()
			game_over.emit()
		var collision_tilemap_layer = PhysicsServer2D.body_get_collision_layer(collision.get_collider_rid())
		if collision_tilemap_layer == 1 and !is_on_floor():
			last_velocity_x = velocity.x
			set_is_grabbing_wall_func()
			

func set_is_jumping_func():
	is_jumping = true
	is_floating = false
	is_grabbing_wall = false

func set_is_landing():
	is_jumping = false
	is_floating = false
	is_grabbing_wall = false

func set_is_floating_func():
	is_jumping = false
	is_floating = true
	is_grabbing_wall = false

func set_is_grabbing_wall_func():
	is_jumping = false
	is_floating = false 
	is_grabbing_wall = true

# Fonction retournant la velocite verticale en se basant sur la hauteur et le temps de saut voulu
func jump():
	print("Velocity X : ", velocity.x)
	print("Is player fliped : ", $AnimatedSprite2D.flip_h)
	velocity.y = ((2.0 * jump_height)  / jump_time_to_peak) * -1.0

func jump_from_wall():
	if($AnimatedSprite2D.flip_h):
		velocity.x = -150
	else:
		velocity.x = 150
	jump()

# Fonction retournant la velocite verticale en prenant en compte la gravite
func get_gravity():
	if velocity.y < 0:
		return ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1
	else: 
		return ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1

# Methode de gestion de l'animation
func sprite_animation():
	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	if $AnimatedSprite2D.animation == "jump" and $AnimatedSprite2D.frame == 3 :
		$AnimatedSprite2D.animation = "float"

	if $AnimatedSprite2D.animation == "float" and $AnimatedSprite2D.frame == 1 :
		set_is_floating_func()

	if is_on_floor() and $AnimatedSprite2D.animation == "float":
		$AnimatedSprite2D.animation = "land"
		set_is_landing()

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

	if (Input.is_action_just_pressed("move_up") or Input.is_joy_button_pressed(0,JOY_BUTTON_DPAD_UP) or Input.is_joy_button_pressed(0,JOY_BUTTON_RIGHT_SHOULDER)) and (is_on_floor() or is_grabbing_wall == true):
		$AnimatedSprite2D.animation = "jump"
		$jump_AudioStreamPlayer2D.play()
		last_velocity_x = velocity.x
		if is_grabbing_wall == false:
			set_is_jumping_func()
			jump()
		else:
			set_is_jumping_func()
			jump_from_wall()
	
	if !is_on_floor() :
		if $AnimatedSprite2D.animation == "walk" or $AnimatedSprite2D.animation == "idle":
			$AnimatedSprite2D.animation = "jump"
	
	if is_grabbing_wall == true:
		$AnimatedSprite2D.flip_h = last_velocity_x > 0
		$AnimatedSprite2D.animation = "grab"
		jump_time_to_descent = grabbing_wall_jump_time_to_descent
	else:
		jump_time_to_descent = initial_jump_time_to_descent
		if !is_on_floor():
			$AnimatedSprite2D.animation = "float"

# Fonction retournant la velocite horizontale du personnage a la pression d'une touche
func get_input_velocity():
	var horizontalVelocity := 0
	
	if Input.is_action_pressed("move_left") or Input.is_joy_button_pressed(0,JOY_BUTTON_DPAD_LEFT):
		horizontalVelocity -= 1
	if Input.is_action_pressed("move_right") or Input.is_joy_button_pressed(0,JOY_BUTTON_DPAD_RIGHT):
		horizontalVelocity += 1
	if Input.get_joy_axis(0, JOY_AXIS_LEFT_X) > 0.5:
		horizontalVelocity += 1
	if Input.get_joy_axis(0, JOY_AXIS_LEFT_X) < -0.5:
		horizontalVelocity -= 1
		
	return horizontalVelocity

# Methode appelee au demarrage/reset de la partie
func start(pos):
	position = pos
	show()
	$CollisionShape2D.set_deferred("disabled", false)

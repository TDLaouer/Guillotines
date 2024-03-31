extends CharacterBody2D
signal game_over

@export var move_speed = 400 # Vitesse du player en pixels/sec
@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float

var grabbing_wall_jump_time_to_descent : float
var initial_jump_time_to_descent : float
var last_velocity_x : float
var just_grabbing : float

var is_grabbing_wall : bool
var is_jumping : bool
var already_jumped : bool
var is_floating : bool
var is_fast_falling := true
var is_looking_right : bool
var is_looking_left : bool

var screen_size

# Methode appelee lorsque l'objet "entre dans le scene tree" pour la premiere fois
func _ready():
	velocity = Vector2.ZERO
	screen_size = get_viewport_rect().size
	initial_jump_time_to_descent = jump_time_to_descent
	grabbing_wall_jump_time_to_descent = 200

# Methode appelee à chaque frame calculee
func _physics_process(delta):
	
	if Input.is_action_just_pressed("reset"):
		hide()
		game_over.emit()
	
	if velocity.x < 0:
		set_is_looking_left()
	elif velocity.x > 0:
		set_is_looking_right()
	
	if is_on_floor():
		set_is_landing()
		save_velocity_x()
	
	if Input.is_action_just_pressed("move_down") or Input.is_joy_button_pressed(0,JOY_BUTTON_DPAD_DOWN):
		set_is_fast_falling_func()
		jump_time_to_descent = initial_jump_time_to_descent
		$AnimatedSprite2D.animation = "fast_fall"
		print("Je descends maintenant !")
	
	if is_fast_falling:
		$AnimatedSprite2D.animation = "fast_fall"
		print("Je descends toujours !")
	
	if !is_jumping:
		velocity.x = get_input_velocity() * move_speed

	if !is_fast_falling:
		if is_grabbing_wall == true:
			just_grabbing += 1.0
			if just_grabbing == 1.0:
				is_looking_left = !is_looking_left
				is_looking_right = !is_looking_right
			$AnimatedSprite2D.animation = "grab"
			jump_time_to_descent = grabbing_wall_jump_time_to_descent
		else:
			just_grabbing = 0.0
			jump_time_to_descent = initial_jump_time_to_descent
			if !is_on_floor():
				$AnimatedSprite2D.animation = "float"

	sprite_animation()
	velocity.y += get_gravity() * delta
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		#if collision.get_collider().name == "Guillotine3" and collision.get_collider_shape_index() == 1:
			#hide()
			#game_over.emit()
		var collision_tilemap_layer = PhysicsServer2D.body_get_collision_layer(collision.get_collider_rid())
		if collision_tilemap_layer == 1 and !is_on_floor() and !is_fast_falling:
			set_is_grabbing_wall_func()
		if collision_tilemap_layer == 16:
			game_over.emit()

func save_velocity_x():
	last_velocity_x = velocity.x

func set_is_looking_right():
	is_looking_right = true
	is_looking_left = false

func set_is_looking_left():
	is_looking_right = false
	is_looking_left = true

func set_is_landing():
	is_jumping = false
	is_floating = false
	is_grabbing_wall = false
	is_fast_falling = false

func set_is_jumping_func():
	is_jumping = true
	is_floating = false
	is_grabbing_wall = false
	is_fast_falling = false

func set_is_floating_func():
	is_jumping = false
	is_floating = true
	is_grabbing_wall = false
	is_fast_falling = false

func set_is_grabbing_wall_func():
	is_jumping = false
	is_floating = false 
	is_grabbing_wall = true
	is_fast_falling = false

func set_is_fast_falling_func():
	is_jumping = false
	is_floating = false 
	is_grabbing_wall = false
	is_fast_falling = true

# Fonction retournant la velocite verticale en se basant sur la hauteur et le temps de saut voulu
func jump():
	velocity.y = ((2.0 * jump_height)  / jump_time_to_peak) * -1.0

func jump_from_wall():
	if(is_looking_left):
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

	# Pure animation & changement d'état simple
	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	if $AnimatedSprite2D.animation == "float" and $AnimatedSprite2D.frame == 1 :
		set_is_floating_func()
	if $AnimatedSprite2D.animation == "grab" and $AnimatedSprite2D.frame == 1 and !is_fast_falling:
		set_is_grabbing_wall_func()
	if is_on_floor() and $AnimatedSprite2D.animation == "float":
		$AnimatedSprite2D.animation = "land"
		set_is_landing()
	if $AnimatedSprite2D.animation == "jump" and $AnimatedSprite2D.frame == 3 :
		$AnimatedSprite2D.animation = "float"
	if is_on_floor() and velocity.x != 0 and ($AnimatedSprite2D.animation != "land" or $AnimatedSprite2D.frame == 1):
		$AnimatedSprite2D.animation = "walk"
	elif is_on_floor() and ($AnimatedSprite2D.animation != "land" or $AnimatedSprite2D.frame == 1):
		$AnimatedSprite2D.animation = "idle"
	if (Input.is_action_just_pressed("move_up") or Input.is_joy_button_pressed(0,JOY_BUTTON_DPAD_UP) or Input.is_joy_button_pressed(0,JOY_BUTTON_RIGHT_SHOULDER)) and (is_on_floor() or is_grabbing_wall):
		$AnimatedSprite2D.animation = "jump"
		$jump_AudioStreamPlayer2D.play()
		if is_grabbing_wall:
			set_is_jumping_func()
			jump_from_wall()
		else:
			set_is_jumping_func()
			jump()
	if !is_on_floor() and ($AnimatedSprite2D.animation == "walk" or $AnimatedSprite2D.animation == "idle"):
		$AnimatedSprite2D.animation = "jump"
	
	$AnimatedSprite2D.flip_v = false
	$AnimatedSprite2D.flip_h = is_looking_left

# Fonction retournant la velocite horizontale du personnage a la pression d'une touche
func get_input_velocity():
	var horizontalVelocity := 0
	if !is_grabbing_wall:
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

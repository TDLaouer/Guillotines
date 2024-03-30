extends Area2D
signal hit

@export var speed = 400 # Vitesse du player en pixels/sec
var screen_size

# Methode appelee lorsque l'objet "entre dans le scene tree" pour la premiere fois
func _ready():
	screen_size = get_viewport_rect().size


# Methode appelee à chaque frame calculee
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if (Input.is_anything_pressed()==false):
		$AnimatedSprite2D.animation = "idle"

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		# See the note below about boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0


# Methode appelee au demarrage/reset de la partie
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

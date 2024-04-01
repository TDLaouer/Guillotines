extends Node

var is_music_playing := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_music_playing == 0:
		AudioPlayer.play("level_one")
	is_music_playing += 1.0

func new_game():
	$Player.start($PlayerStartPosition.position)
	$Guillotine.start($GuillotineStartPosition.position)

func _on_player_game_over():
	$Player/death_AudioStreamPlayer.play()
	print("Game Over !")
	new_game()

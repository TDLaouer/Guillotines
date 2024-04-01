extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()
	AudioPlayer.play("level_two")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func new_game():
	$Player.start($PlayerStartPosition.position)
	$Guillotine.start($GuillotineStartPosition.position)


func _on_player_game_over():
	$Player/death_AudioStreamPlayer.play()
	print("Game Over !")
	new_game()

extends Control

var is_music_playing := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer2/Menu.grab_focus()
	if is_music_playing == 0:
		AudioPlayer.play("credits_song")
	is_music_playing += 1.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	AudioPlayer.stop("credits_song")
	get_tree().change_scene_to_file("res://Menu.tscn")
	pass # Replace with function body.

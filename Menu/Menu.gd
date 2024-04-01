extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Start.grab_focus()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_pressed():
	get_tree().change_scene_to_file("res://Main.tscn")
	AudioPlayer.play("clic")

func _on_credit_pressed():
	get_tree().change_scene_to_file("res://Menu/credit.tscn")
	AudioPlayer.play("clic")
	

func _on_quit_pressed():
	get_tree().quit()
	


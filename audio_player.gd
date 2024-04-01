extends Node

func play(sound):
	for node in get_children():
		if node.name == sound:
			node.play()

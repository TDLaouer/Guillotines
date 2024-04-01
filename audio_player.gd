extends Node

func play(sound):
	for node in get_children():
		if node.name == sound:
			node.play()

func stop(sound):
	for node in get_children():
		if node.name == sound:
			node.stop()

func stop_all():
	for node in get_children():
		node.stop()

extends Node

func play(sound):
	print("Joue ", sound, " stp !")
	for node in get_children():
		if node.name == sound:
			print("Tu trouves le child, pourquoi tu veux pas joueeeer")
			node.play()

func stop(sound):
	for node in get_children():
		if node.name == sound:
			node.stop()

func stop_all():
	for node in get_children():
		node.stop()

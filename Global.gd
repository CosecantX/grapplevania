extends Node

var player = null
var hook = null
var gui = null

func set_player(p):
	if p:
		player = p
		print("player set")

func get_player():
	if player:
		return player
	else:
		print("player == null")

func set_hook(h):
	if h:
		hook = h
		print("hook set")

func get_hook():
	if hook:
		return hook
	else:
		print("hook == null")

func set_gui(g):
	if g:
		gui = g
		print("gui set")

func get_gui():
	if gui:
		return gui
	else:
		print("gui == null")

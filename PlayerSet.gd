extends Node2D

onready var hook = $Hook
onready var player = $Player
onready var line = $Line

func _ready():
	hook.connect("hook_locked", player, "_on_hook_locked")
	hook.connect("hook_unlocked", player, "_on_hook_unlocked")
	player.emit_signal("set_max_hp", player.max_health)
	player.emit_signal("set_hp", player.current_health)

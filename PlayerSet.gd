extends Node2D

onready var hook = $Hook
onready var player = $Player
onready var line = $Line

func _ready():
	hook.connect("hook_locked", player, "_on_hook_locked")
	hook.connect("hook_unlocked", player, "_on_hook_unlocked")

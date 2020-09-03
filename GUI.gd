extends CanvasLayer

onready var hp_bar = $HPBar

func _ready():
	Global.set_gui(self)
	Global.get_player().connect("set_max_hp", self, "_on_set_max_hp")
	Global.get_player().connect("set_hp", self, "_on_set_hp")

func _on_set_max_hp(hp):
	hp_bar.max_value = hp
	print("max hp set")

func _on_set_hp(hp):
	hp_bar.value = hp
	print("hp set")

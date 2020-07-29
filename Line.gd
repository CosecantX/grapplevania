extends Line2D

onready var hook = Global.get_hook()
onready var player = Global.get_player()

func _physics_process(delta):
	clear_points()
	if hook.visible:
		add_point(hook.global_position)
		add_point(player.global_position)

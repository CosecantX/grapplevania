extends Line2D

onready var hook = Global.get_hook()
onready var player = Global.get_player()

func _physics_process(delta):
	clear_points()
	if hook.visible:
		add_point(to_local(hook.global_position))
		add_point(to_local(player.global_position))

extends KinematicBody2D

const SHOT_FORCE = 20
const GRAVITY = 50

var velocity = Vector2.ZERO
var hooked = false

func _enter_tree():
	Global.set_hook(self)

func _physics_process(delta):
	if visible:
		if not hooked:
			velocity.y += GRAVITY * delta
			rotation = velocity.angle()
		var collision = move_and_collide(velocity)
		if collision:
			velocity = Vector2.ZERO
			hooked = true
	else:
		hooked = false

func shoot(angle):
	hooked = false
	set_visible(true)
	global_position = Global.get_player().global_position
	velocity = Vector2.RIGHT.rotated(angle) * SHOT_FORCE
	

func retract():
	hooked = false
	set_visible(false)
	

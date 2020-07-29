extends KinematicBody2D

onready var reticle = $Reticle

export var walk_force = 600
export var max_walk_speed = 200
export var stop_force = 1300
export var jump_force = 250
export var gravity = 500
export var climb_speed = 5

onready var hook = Global.get_hook()

var velocity = Vector2()
var hook_out = false
var climbing = false
var climb_dist = 0

func _enter_tree():
	Global.set_player(self)

func _physics_process(delta):
	# Horizontal movement code. First, get the player's input.
	var walk = walk_force * (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	# Slow down the player if they're not trying to move.
	if abs(walk) < walk_force * 0.2:
		# The velocity, slowed down a bit, and then reassigned.
		velocity.x = move_toward(velocity.x, 0, stop_force * delta)
	else:
		velocity.x += walk * delta
	# Clamp to the maximum horizontal movement speed.
	velocity.x = clamp(velocity.x, -max_walk_speed, max_walk_speed)

	# Vertical movement code. Apply gravity.
	velocity.y += gravity * delta

	# Move based on the velocity and snap to the ground.
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

	# Check for jumping. is_on_floor() must be called after movement code.
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump_force
	
	# Stop moving upwards if player lets go of jump button.
	if velocity.y < 0 and Input.is_action_just_released("jump"):
		velocity.y = 0
	
	# Aim reticle towards mouse pointer
	reticle.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("shoot_hook"):
		if not hook_out:
			hook.shoot(reticle.rotation)
			hook_out = true
		else:
			hook.retract()
			hook_out = false
			climbing = false
	
	if Input.is_action_pressed("move_up") and hook.hooked:
		if not climbing:
			var dist = global_position.distance_to(hook.global_position)
			climb_dist = dist
			climbing = true
		else:
			climb_dist -= climb_speed
	
	if Input.is_action_pressed("move_down") and hook.hooked:
		if not climbing:
			var dist = global_position.distance_to(hook.global_position)
			climb_dist = dist
			climbing = true
		else:
			climb_dist += climb_speed
	
#	var dist = global_position.distance_to(hook.global_position)
	if climbing:
		global_position = hook.global_position.clamped(climb_dist)

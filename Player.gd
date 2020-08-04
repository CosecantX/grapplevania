extends KinematicBody2D

onready var reticle = $Reticle

export var walk_force = 1000
export var max_walk_speed = 500
export var stop_force = 1300
export var jump_force = 250
export var gravity = 500
export var climb_speed = 5
export var max_rope_length = 220
export var max_health = 10

onready var hook = Global.get_hook()
onready var ceiling_detector = $CeilingDetector
onready var ceiling_detector2 = $CeilingDetector2
onready var ceiling_detector3 = $CeilingDetector3

var velocity = Vector2()
var hook_out = false
var hooked = false
var rope_length = 0
var current_health = max_health

func _enter_tree():
	Global.set_player(self)

func _physics_process(delta):
	if hooked:
		var dist = global_position.distance_to(hook.global_position)
		if dist > rope_length:
			global_position = hook.global_position + (global_position - hook.global_position).normalized() * rope_length
	
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
	if not hooked:
		velocity.y += gravity * delta
	else:
		var dist = global_position.distance_to(hook.global_position)
		if dist < rope_length:
			velocity.y += gravity * delta
			
	
	# Move based on the velocity and snap to the ground.
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	
	# Check for jumping. is_on_floor() must be called after movement code.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = -jump_force
		elif hook_out:
			shoot_hook()
		
	# Stop moving upwards if player lets go of jump button.
	if velocity.y < 0 and Input.is_action_just_released("jump"):
		velocity.y = 0
	
	# Aim reticle towards mouse pointer
	reticle.look_at(get_global_mouse_position())
	update()
	
	if Input.is_action_just_pressed("shoot_hook"):
		shoot_hook()
	
	if Input.is_action_pressed("move_up"):
		if not colliding_with_ceiling():
			rope_shorten()
	
	if Input.is_action_pressed("move_down"):
		rope_lengthen()

func _draw():
	if hooked:
		draw_arc(to_local(hook.global_position), rope_length, 0, 2 * PI, 32, Color(1, 1, 1))

func shoot_hook():
	if not hook_out:
		hook.shoot(reticle.rotation)
		hook_out = true
	else:
		hook.retract()
		hook_out = false

func rope_lengthen():
	if hooked:
		rope_length += climb_speed
		if rope_length > max_rope_length:
			rope_length = max_rope_length

func rope_shorten():
	if hooked:
		rope_length -= climb_speed
		if rope_length < 0:
			rope_length = 0

func colliding_with_ceiling():
	return ceiling_detector.get_collider() or ceiling_detector2.get_collider() or ceiling_detector3.get_collider()

func _on_hook_locked():
	hooked = true
	rope_length = global_position.distance_to(hook.global_position)
	if rope_length > max_rope_length:
			rope_length = max_rope_length

func _on_hook_unlocked():
	hooked = false
	rope_length = 0
	velocity = Vector2.ZERO


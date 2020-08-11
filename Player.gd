extends KinematicBody2D

var bullet_node = preload("res://Bullet.tscn")

onready var reticle = $Reticle
onready var raycast = $RayCast2D
onready var raycast2 = $RayCast2D2
onready var gun_timer = $GunTimer

export var player_width = 16
export var walk_force = 1000
export var max_walk_speed = 500
export var stop_force = 1300
export var jump_force = 280
export var gravity = 500
export var climb_speed = 5
export var max_rope_length = 220
export var max_health = 10

onready var hook = Global.get_hook()

var velocity = Vector2()
var hook_out = false
var hooked = false
var rope_length = 0
var current_health = max_health

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
	if not hooked:
		velocity.y += gravity * delta
	else:
		# Don't apply gravity if past rope length
		var dist = global_position.distance_to(hook.global_position)
		if dist < rope_length:
			velocity.y += gravity * delta
			
	
	# Move based on the velocity and snap to the ground.
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	
	# Constrain player's position if beyond rope length
	if hooked:
		var dist = global_position.distance_to(hook.global_position)
		if dist > rope_length:
			global_position = hook.global_position + (global_position - hook.global_position).normalized() * rope_length
	
	# Check for jumping. is_on_floor() must be called after movement code.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() and not hook_out:
			velocity.y = -jump_force
		elif hook_out:
			# Jump again and release rope if rope out
			hook.retract()
			hook_out = false
			velocity.y = -jump_force
		
	# Stop moving upwards if player lets go of jump button.
	if velocity.y < 0 and Input.is_action_just_released("jump"):
		velocity.y = 0
	
	# Aim reticle towards mouse pointer
	reticle.look_at(get_global_mouse_position())
	
	# Update drawn circle
	update()
	
#	if Input.is_action_just_pressed("shoot_hook"):
#		shoot_hook()
	
	if Input.is_action_just_pressed("shoot_hook"):
		hook.shoot(reticle.rotation)
		hook_out = true
	
	if Input.is_action_just_released("shoot_hook"):
		hook.retract()
		hook_out = false
	
	if Input.is_action_pressed("move_up"):
		if not check_for_collision_on_rope_shortening():
			rope_shorten()
	
	if Input.is_action_pressed("move_down"):
		rope_lengthen()
	
	if Input.is_action_pressed("shoot_gun") and gun_timer.is_stopped():
		shoot_gun()

func _draw():
	# Draw circle to signify rope length
	if hooked:
		draw_arc(to_local(hook.global_position), rope_length, 0, 2 * PI, 32, Color(1, 1, 1))

#func shoot_hook():
#	if not hook_out:
#		hook.shoot(reticle.rotation)
#		hook_out = true
#	else:
#		hook.retract()
#		hook_out = false

func rope_lengthen():
	if hooked:
		rope_length += climb_speed
#		if rope_length > max_rope_length:
#			rope_length = max_rope_length

func rope_shorten():
	if hooked:
		rope_length -= climb_speed
		if rope_length < 0:
			rope_length = 0

func check_for_collision_on_rope_shortening():
	var angle = hook.global_position.angle_to_point(global_position)
	raycast.set_cast_to(Vector2.RIGHT.rotated(angle) * (climb_speed + player_width))
	raycast2.set_cast_to(Vector2.RIGHT.rotated(angle) * (climb_speed + player_width))
	return raycast.is_colliding() or raycast2.is_colliding()

func shoot_gun():
	var bullet = bullet_node.instance()
	add_child(bullet)
	bullet.global_position = global_position
	bullet.shoot(reticle.rotation)
	gun_timer.start()

func _on_hook_locked():
	hooked = true
	# Set rope length to distance between player and hook
	rope_length = global_position.distance_to(hook.global_position)
#	if rope_length > max_rope_length:
#			rope_length = max_rope_length

func _on_hook_unlocked():
	hooked = false
	rope_length = 0
	velocity.y = 0


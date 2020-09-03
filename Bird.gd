extends KinematicBody2D

onready var raycast = $RayCast2D
onready var face = $Face
onready var rand_timer = $RandTimer

export var speed = 100
export var turn_speed = .01
export var max_health = 5
export var contact_damage = 10

var health = max_health

var velocity = Vector2.ZERO
var aim_dir = 0

func _ready():
	rand_dir()

func _process(delta):
	if health <= 0:
		queue_free()
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.collider.has_method("damage"):
			collision.collider.damage(contact_damage)
		rotation = rand_range(0, 2 * PI)
		rand_dir()
		rand_timer.start()
	if raycast.is_colliding():
		aim_dir = (raycast.get_collision_normal().angle() + rotation) / 2
	steer()
#	face.global_rotation = aim_dir

func steer():
	var diff = rotation - aim_dir
	if abs(diff) > turn_speed:
		rotation += -turn_speed * sign(diff)
	else:
		rotation = aim_dir

func rand_dir():
	randomize()
	aim_dir = rand_range(0, 2 * PI)

func damage(dmg):
	health -= dmg
	if health < 0:
		health = 0

func _on_RandTimer_timeout():
	rand_dir()

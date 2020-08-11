extends KinematicBody2D

export var speed = 15

var velocity = Vector2.ZERO

func _physics_process(delta):
	var collision = move_and_collide(velocity)
	if collision:
		queue_free()

func shoot(angle):
	rotation = angle
	velocity = Vector2.RIGHT.rotated(angle) * speed

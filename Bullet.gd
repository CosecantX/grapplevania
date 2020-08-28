extends KinematicBody2D

export var speed = 15

export var damage = 1

var velocity = Vector2.ZERO

func _physics_process(delta):
	var collision = move_and_collide(velocity)
	if collision:
		if collision.collider.has_method("damage"):
			collision.collider.damage(damage)
		queue_free()

func shoot(angle):
	rotation = angle
	velocity = Vector2.RIGHT.rotated(angle) * speed

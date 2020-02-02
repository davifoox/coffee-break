extends KinematicBody2D

var can_fall = false
var is_getting_weak = false

func _physics_process(delta):
	if is_getting_weak:
		translate(Vector2(0,7) * delta)
	if can_fall:
		$CollisionShape2D.disabled = true
		translate(Vector2(0,700) * delta)

func _on_Area2DPlayerDetection_body_entered(body):
	if body.is_in_group("player"):
		is_getting_weak = true
		$TimerToFall.start()
		$Area2DPlayerDetection.queue_free()
			

func _on_TimerToFall_timeout():
	is_getting_weak = false
	can_fall = true

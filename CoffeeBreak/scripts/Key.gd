extends Area2D

onready var light = get_tree().get_nodes_in_group("light")[0]
onready var broken_piece = get_tree().get_nodes_in_group("broken_piece")[0]

func _on_Key_body_entered(body):
	if body.is_in_group("player"):
		body.get_key()
		light.position = broken_piece.position
		queue_free()

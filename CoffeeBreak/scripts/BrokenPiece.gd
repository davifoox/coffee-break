extends Area2D

onready var light = get_tree().get_nodes_in_group("light")[0]
onready var player = get_tree().get_nodes_in_group("player")[0]
onready var player_initial_position = player.position
onready var door = get_tree().get_nodes_in_group("door")[0]

export var is_tutorial = false


func _on_Glow_body_entered(body):
	if body.is_in_group("player") and body.has_key:
		var crushers = get_tree().get_nodes_in_group("crush")
		for c in crushers:
			c.can_move = true
		if !is_tutorial:
			light.position = player_initial_position
		else:
			light.position = Vector2(3663, 715)
		door.open = true
		player.play_fix_sound()
		queue_free()

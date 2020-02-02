extends Area2D

var open = false

export(String, FILE, "*.tscn") var next_level

func _on_NextLevelDoor_body_entered(body):
	if body.is_in_group("player") and open:
		get_tree().change_scene(next_level)

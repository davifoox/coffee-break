extends Node

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene("res://scenes/Menu.tscn")

func _on_ButtonBack_pressed():
	get_tree().change_scene("res://scenes/Menu.tscn")

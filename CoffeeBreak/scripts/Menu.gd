extends Node

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene("res://scenes/Level00(Tutorial).tscn")

func _on_ButtonStart_pressed():
	MusicManager.change_music("theme")
	get_tree().change_scene("res://scenes/Level00(Tutorial).tscn")


func _on_ButtonCredits_pressed():
	get_tree().change_scene("res://scenes/Credits.tscn")

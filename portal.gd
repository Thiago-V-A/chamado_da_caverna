extends Area2D
@export var next_scene = "res://nivel-2/nivel_2.tscn";

func _on_body_entered(body):
	if body.is_in_group("personagem"):
		get_tree().change_scene_to_file(next_scene)

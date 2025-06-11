extends Control


func _on_reiniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://nivel/nivel.tscn")



func _on_sair_pressed() -> void:
	get_tree().quit()

extends Area2D
	
func _on_body_entered(body) -> void:
	if body.is_in_group("inimigos"):
		body.take_damage(20)
		print('O inimigo entrou em contato com o slime')
	else:
		return;

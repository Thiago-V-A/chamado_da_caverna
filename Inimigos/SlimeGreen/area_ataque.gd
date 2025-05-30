extends Area2D
	
func _on_body_entered(player) -> void:
	if player.is_in_group("player"):
		player.take_damage(10)
		print('O player entrou em contato com o slime')
	else:
		return;

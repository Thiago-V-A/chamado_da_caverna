extends Area2D
	
func _on_body_entered(player) -> void:
	if player.is_in_group("player"):
		player.visivel(true);
		print('O player está visivel para o slime');
	else:
		player.visivel(false);
		print('O player não está visivel para o slime');

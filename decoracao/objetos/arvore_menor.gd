extends "res://decoracao/objetos/objeto_de_base.gd"


func tocar_animacao_dano() -> void:
	if _vida <= 5: 
		$AnimationPlayer.play("arvore_cortada")
	else:
		super.tocar_animacao_dano()

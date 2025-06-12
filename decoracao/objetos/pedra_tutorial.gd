extends Area2D

@export var objeto_que_destroi: String
@export var _vida: int = 10

func tocar_animacao_dano() -> void:
	$AnimationPlayer.play("perdendo_vida")

func perdendo_vida(_dano) -> void:
	_vida = _vida - _dano
	if _vida > 0:
		tocar_animacao_dano()
	else:
		queue_free()

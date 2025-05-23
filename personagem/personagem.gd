extends CharacterBody2D

var _sufixo_da_animacao: String = 'baixo'
var _pode_atacar: bool = true


@export var max_health := 100
var health := max_health
@export var _velocidade_de_movimento: float = 128
@export var _animador_do_personagem: AnimationPlayer
@export var _temporizador_de_acoes: Timer
@export var _area_de_ataque: Area2D
@export var dano_do_ataque := 50

var is_dead := false

func _physics_process(_delta: float) -> void:
	if is_dead:
		return
	var direcao = Input.get_vector(
		"mover_esquerda", "mover_direita", "mover_cima", "mover_baixo"
	)
	velocity = direcao * _velocidade_de_movimento
	move_and_slide()
	_sufixo_da_animacao = _sufixo_do_personagem()
	_atacar()
	_animar()

func _sufixo_do_personagem () -> String:  
	var _acao_horizontal: float = Input.get_axis("mover_esquerda", "mover_direita") 
	if _acao_horizontal == -1: 
		_area_de_ataque.position = Vector2(-15, 0)
		return "_esquerda" 
		
	if _acao_horizontal == +1:
		_area_de_ataque.position = Vector2(+16, 0)
		return "_direita" 

	var _acao_vertical: float = Input.get_axis("mover_cima", "mover_baixo") 
	if _acao_vertical == -1: 
		_area_de_ataque.position = Vector2(0, -14)
		return "_cima" 
		
	if _acao_vertical == +1:
		_area_de_ataque.position = Vector2(0, +12)
		return "_baixo"
	return _sufixo_da_animacao

func _atacar() -> void:
	if Input.is_action_just_pressed("atacar") and _pode_atacar:
		_temporizador_de_acoes.start(0.4)
		_animador_do_personagem.play("atacando" + _sufixo_da_animacao)
		_pode_atacar = false
		set_physics_process(false)

		# Verifica quem está na área de ataque
		for corpo in _area_de_ataque.get_overlapping_bodies():
			if corpo.is_in_group("enemies"):
				corpo.take_damage(dano_do_ataque)


func _animar() -> void:
	if _pode_atacar == false:
		return
	if velocity:
		_animador_do_personagem.play("andando" + _sufixo_da_animacao)
		return

	_animador_do_personagem.play("parado" + _sufixo_da_animacao)


func _on_temporazidaro_de_acoes_timeout() -> void:
	set_physics_process(true)
	_pode_atacar = true
	
# --- Novo método de dano e morte ---
func take_damage(amount: int) -> void:
	
	if is_dead:
		return
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	is_dead = true
	_animador_do_personagem.play("morte" + _sufixo_da_animacao)
	velocity = Vector2.ZERO
	set_physics_process(false)
	queue_free()

	

extends CharacterBody2D

var _arma_atual: String = "espada"
var _sufixo_da_animacao: String = "_baixo"
var _pode_atacar: bool = true
var _dano_ataque: int = 15
var _vida_atual: int = 100
var _is_dead: bool;
var _ataque_ativo := false

@export var _velocidade_de_movimento: float = 128
@export var _animador_do_personagem: AnimationPlayer
@export var _temporizador_de_acoes: Timer
@export var _area_de_ataque: Area2D
@export var _texto_arma_atual: Label
var target: CharacterBody2D = null

func _process(_delta: float) -> void:
	var direcao = Input.get_vector(
		"mover_esquerda", "mover_direita", "mover_cima", "mover_baixo"
	)
	velocity = direcao * _velocidade_de_movimento
	move_and_slide()
	
	_sufixo_da_animacao = _sufixo_do_personagem()
	_definir_arma_atual()
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
		_area_de_ataque.position = Vector2(0, -12)
		return "_cima" 
		
	if _acao_vertical == +1:
		_area_de_ataque.position = Vector2(0, +12)
		return "_baixo"
	return _sufixo_da_animacao

func _definir_arma_atual() -> void:
	if Input.is_action_just_pressed("espada"):
		_arma_atual = "espada"
	
	if Input.is_action_just_pressed("picareta"):
		_arma_atual ='picareta'
	_texto_arma_atual.text = _arma_atual


func _atacar(body = null) -> void:
	if Input.is_action_just_pressed("atacar") and _pode_atacar:
		_animador_do_personagem.play("atacando_" + _arma_atual + _sufixo_da_animacao)
		_ataque_ativo = true  # Ativa o modo ataque
		_temporizador_de_acoes.start(0.4)
		_pode_atacar = false
		set_process(false)

		await get_tree().create_timer(0.2).timeout  # tempo do impacto
		_ataque_ativo = false  # Desativa ataque após impacto


func _animar() -> void:
	if _pode_atacar == false:
		return
	if velocity:
		_animador_do_personagem.play("andando" + _sufixo_da_animacao)
		return

	_animador_do_personagem.play("parado" + _sufixo_da_animacao)


func _on_temporazidaro_de_acoes_timeout() -> void:
	set_process(true)
	_pode_atacar = true

func take_damage(amount: int):
	if _is_dead == true:
		return
		
	_vida_atual -= amount
	print(_vida_atual)
	if _vida_atual <= 0:
		_die()

func _die():
	_is_dead = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	queue_free()


func _on_area_de_ataque_body_entered(body: Node2D) -> void:
	if _ataque_ativo and body.is_in_group("inimigos"):
		body.take_damage(_dano_ataque, global_position)
	return

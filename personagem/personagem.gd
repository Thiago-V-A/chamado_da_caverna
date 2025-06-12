extends CharacterBody2D
# Adicione esta variável
var movimento_travado: bool = false
var esta_vivo: bool = true
var _arma_atual: String = "espada"
var _sufixo_da_animacao: String = "_baixo"
var _pode_atacar: bool = true

var icones_armas: Dictionary = {
	"espada": preload("res://interface/armas/espada.png"),
	"picareta": preload("res://interface/armas/picareta.png"),
	"machado": preload("res://interface/armas/machado.png"),
	"enxada": preload("res://interface/armas/enxada.png"),
}

@export var _velocidade_de_movimento: float = 128
@export var _animador_do_personagem: AnimationPlayer
@export var _temporizador_de_acoes: Timer
@export var _area_de_ataque: Area2D

@export var _vida: int = 10

@onready var icone_hud: TextureRect = $CanvasLayer/IconeArmaHUD

func _process(_delta: float) -> void:
	if not movimento_travado:
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
	var arma_foi_trocada: bool = false

	if Input.is_action_just_pressed("espada"):
		_arma_atual = "espada"
		arma_foi_trocada = true
	elif Input.is_action_just_pressed("picareta"):
		_arma_atual = "picareta"
		arma_foi_trocada = true
	elif Input.is_action_just_pressed("machado"):
		_arma_atual = "machado"
		arma_foi_trocada = true
	elif Input.is_action_just_pressed("enxada"):
		_arma_atual = "enxada"
		arma_foi_trocada = true
	
	if arma_foi_trocada:
		_atualizar_icone_arma()


func _atacar() -> void:
	if Input.is_action_just_pressed("atacar") and _pode_atacar:
		_animador_do_personagem.play("atacando_" + _arma_atual + _sufixo_da_animacao)
		_temporizador_de_acoes.start(0.4)
		_pode_atacar = false
		
		set_process(false)

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


func _on_area_de_ataque_area_entered(_area: Area2D) -> void:
	if _area.is_in_group("area_de_dano"):
		_area.get_parent().perdendo_vida(randi_range(1, 5))
		return
	
	if _area.is_in_group("objetos"):
		print(_arma_atual)
		if _arma_atual == _area.objeto_que_destroi:
			_area.perdendo_vida(randi_range(1, 5))
		
func perdendo_vida(_dano_recebido: int) -> void:
	if esta_vivo == false:
		return
	
	_vida -= _dano_recebido
	if _vida > 0:
		$AnimadorVida.play("perdendo_vida")
		return
		
	_kill()

func _kill() -> void:
	_temporizador_de_acoes.stop()
	set_process(false)
	esta_vivo = false
	_animador_do_personagem.play("morte")
	
func _atualizar_icone_arma() -> void:
	icone_hud.texture = icones_armas[_arma_atual]


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if _anim_name == "morte":
		get_tree().change_scene_to_file("res://interface/tela_de_game_over.tscn")
		$ColisaoPersonagem.set_deferred("disabled", true)
		icone_hud.hide()
		
# Adicione estas funções novas
func travar_movimento():
	movimento_travado = true
	_animador_do_personagem.play("parado" + _sufixo_da_animacao)
	
func destravar_movimento():
	movimento_travado = false

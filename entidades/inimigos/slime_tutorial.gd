extends CharacterBody2D

var direcao: Vector2
var esta_correndo: bool = false
var esta_atacando: bool = false
var morto: bool = false
var personagem: CharacterBody2D
# Adicione esta variável para controlar o estado de perseguição
var modo_perseguicao: bool = false
var alvo_perseguicao: Node2D = null
@export var _tempo_de_caminhada: Timer
@export var _tempor_de_corrida: Timer
@export var _animador: AnimationPlayer
@export var _textura: Sprite2D
@export var _tempo_de_ataque: Timer

@export var _velocidade_de_movimento_normal: float = 32
@export var _veolicdade_de_movimento_correndo: float = 64
@export var _vida: int = 10
@export var _entidade_agressiva: bool = false

func _ready() -> void:
	direcao = retornar_direcao_aleatoria()
	_tempo_de_caminhada.start(100.00)
	
	# Se não for agressivo, desativa a detecção
	if !_entidade_agressiva:
		$AreaDeDeteccao.monitoring = false
		$AreaDeDeteccao.monitorable = false


func _physics_process(delta: float) -> void:
	# Modo perseguição especial (para tutorial)
	if modo_perseguicao && is_instance_valid(alvo_perseguicao):
		var distancia: float = global_position.distance_to(alvo_perseguicao.global_position)
		
		# Para quando chegar perto do alvo
		if distancia < 20:
			velocity = Vector2.ZERO
			_animador.play("parado")
		else:
			direcao = global_position.direction_to(alvo_perseguicao.global_position)
			velocity = _velocidade_de_movimento_normal * direcao
		
		move_and_slide()
		_animar()
		return
		
	# Comportamento normal para mobs agressivos
	if _entidade_agressiva && is_instance_valid(personagem) && personagem.esta_vivo:
		var distancia: float = global_position.distance_to(personagem.global_position)
		
		# Sistema de perseguição/ataque
		if distancia < 150:  # Raio de detecção
			if distancia < 20:  # Distância de ataque
				if esta_atacando == false:
					personagem.perdendo_vida(randi_range(1, 5))
					esta_atacando = true
					_tempo_de_ataque.start()
				velocity = Vector2.ZERO
			else:
				direcao = global_position.direction_to(personagem.global_position)
				velocity = _velocidade_de_movimento_normal * direcao
			
			move_and_slide()
			_animar()
			return
	
	# Comportamento padrão (caminhada aleatória)
	velocity = _velocidade_de_movimento_normal * direcao
	if esta_correndo:
		velocity = _veolicdade_de_movimento_correndo * direcao
		
	move_and_slide()
	_bounce()
	_animar()
	
func _bounce() -> void:
	if get_slide_collision_count() > 0:
		direcao = velocity.bounce(get_slide_collision(0).get_normal()).normalized()

func _animar() -> void:
	if velocity.x > 0:
		_textura.flip_h = true
		if _entidade_agressiva:
			_textura.flip_h = false
	if velocity.x < 0:
		_textura.flip_h = false
		if _entidade_agressiva:
			_textura.flip_h = true
	
	if velocity != Vector2(0, 0):
		_animador.play("andando")
		return
	
	_animador.play("parado")

func retornar_direcao_aleatoria() -> Vector2:
	return Vector2(
		[-1, 0, +1].pick_random(),
		[-1, 0, +1].pick_random()
	).normalized()


func _on_tempo_de_caminhada_timeout() -> void:
	_tempo_de_caminhada.start(5.0)
	if direcao != Vector2(0, 0):
		direcao = Vector2(0, 0)
		return
		
	if direcao == Vector2(0, 0):
		direcao = retornar_direcao_aleatoria()
		

func perdendo_vida(_dano_recebido: int) -> void:
	_vida -= _dano_recebido
	if _vida > 0:
		$AnimadorVida.play("perdendo_vida")
		if !_entidade_agressiva:
			_tempor_de_corrida.start(5.0)
			direcao = retornar_direcao_aleatoria()
			_tempo_de_caminhada.stop()
			esta_correndo = true
			return
		
		if _entidade_agressiva:
			return
		
	_kill()
	
func _kill() -> void:
	morto = true
	if _entidade_agressiva:
		set_physics_process(false)
		_animador.play("morrendo")
		return
		
	queue_free()
	
	
func _on_tempo_de_corrida_timeout() -> void:
	_tempo_de_caminhada.start(5.0)
	esta_correndo = false


func _on_area_de_deteccao_body_entered(_body: Node2D) -> void:
	if _entidade_agressiva == false:
		return
		
	if _body.is_in_group("personagem"):
		_tempo_de_caminhada.stop()
		personagem = _body


func _on_area_de_deteccao_body_exited(_body: Node2D) -> void:
	if _entidade_agressiva == false:
		return
		
	if _body.is_in_group("personagem"):
		_tempo_de_caminhada.start(5.0)
		personagem = null


func _on_tempo_de_ataque_timeout() -> void:
	esta_atacando = false




func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if _anim_name == "morrendo":
		queue_free()
		
func iniciar_perseguicao_tutorial(alvo: Node2D):
	modo_perseguicao = true
	alvo_perseguicao = alvo
	_tempo_de_caminhada.stop()
	esta_correndo = false
	esta_atacando = false

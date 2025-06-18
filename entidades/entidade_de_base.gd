extends CharacterBody2D

var direcao: Vector2
var esta_correndo: bool = false
var esta_atacando: bool = false
var esta_atordoado: bool = false

var personagem: CharacterBody2D

@export var _tempo_de_caminhada: Timer
@export var _tempor_de_corrida: Timer
@export var _animador: AnimationPlayer
@export var _textura: Sprite2D
@export var _tempo_de_ataque: Timer
@export var _tempo_atordoamento: Timer

@export var _velocidade_de_movimento_normal: float = 32
@export var _veolicdade_de_movimento_correndo: float = 64
@export var _vida: int = 10
@export var _entidade_agressiva: bool = false

func _ready() -> void:
	direcao = retornar_direcao_aleatoria()
	_tempo_de_caminhada.start(5.00)

func _physics_process(_delta: float) -> void:
	if esta_atordoado:
		velocity = velocity.move_toward(Vector2.ZERO, 500 * _delta) 
		move_and_slide()
		return
		
	velocity = _velocidade_de_movimento_normal * direcao
	
	if esta_correndo:
		velocity = _veolicdade_de_movimento_correndo * direcao
		
	if is_instance_valid(personagem) and personagem.esta_vivo == true:
		var distancia: float = global_position.distance_to(personagem.global_position)
		if distancia < 10:
			if esta_atacando == false:
				personagem.perdendo_vida(1)
				esta_atacando = true
				_tempo_de_ataque.start()
			
			return 
		
		direcao = global_position.direction_to(personagem.global_position)
		velocity = _velocidade_de_movimento_normal * direcao
		
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
	if esta_atordoado:
		return

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
			esta_atordoado = true
			_tempo_atordoamento.start(0.3)

			if is_instance_valid(personagem):
				var direcao_knockback = (global_position - personagem.global_position).normalized()
				velocity = direcao_knockback * 100
			return
		
	_kill()
	
func _kill() -> void:
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


func _on_temporizador_atordoamento_timeout() -> void:
	esta_atordoado = false

extends CharacterBody2D

@export var speed := 60
@export var attack_damage = 10
@export var max_health := 30
@export var attack_range := 0
@export var attack_cooldown := 1.5
@export var _som_slime_correndo: AudioStreamPlayer
@export var _som_slime_tomando_dano: AudioStreamPlayer

@onready var _collider: CollisionShape2D = $Colisao
@onready var _area_ataque = $AreaAtaque/ColisaoDeAtaque
@onready var _jump_timer: Timer = $JumpTimer
@onready var sprite := $Animacao
@onready var skin:= $Skin

#Atributo:
var knockback_velocity := Vector2.ZERO
var knockback_timer := 0.0
var current_health := max_health
var target: CharacterBody2D = null
var attack_timer := 0.0
var is_dead := false
var is_stunned := false
var stun_duration := 0.3  # segundos de interrupção
var _wait_time = 2;
var visivel = false;

func _ready():
	# Pega a instancia de player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]
	else:
		push_error("Nenhum nó no grupo 'player' encontrado.")

	# Multiplicado de slime
	var multiply_timer = Timer.new()
	multiply_timer.wait_time = 8.0
	multiply_timer.one_shot = false
	multiply_timer.autostart = true
	add_child(multiply_timer)
	multiply_timer.timeout.connect(_on_multiply_timeout)

func _physics_process(delta):
	z_index = 2
	# Verifica a morte do slime.
	if is_dead:
		_area_ataque.set_deferred("disabled", true)
		_collider.set_deferred("disabled", true)
		velocity = Vector2.ZERO
		sprite.play("morrendo")
		await get_tree().create_timer(1.0).timeout
		z_index = 1
		sprite.seek(sprite.current_animation_length, true)
		await get_tree().create_timer(10.0).timeout
		set_physics_process(false)
		queue_free()
	else:
		if not target or not is_instance_valid(target):
			return

		if knockback_timer > 0.0:
			velocity = knockback_velocity
			move_and_slide()
			knockback_timer -= delta

		if is_stunned:
			velocity = Vector2.ZERO
			await get_tree().create_timer(0.5).timeout
			sprite.play("parado")
			is_stunned = false
		attack_timer -= delta
		var distance = position.distance_to(target.position)
		if distance <= attack_range:
			if attack_timer <= 0:
				_attack(target)
		else:
			if visivel:
				_chase_target(delta)
				if !_som_slime_correndo.playing:
					_som_slime_correndo.play()

func _get_direction() -> Vector2:
	var direction = (target.position - position).normalized()
	return direction

func _chase_target(delta):
	sprite.play("correndo")
	_jump_timer.start(_wait_time)
	velocity = _get_direction() * speed
	move_and_slide()

func _attack(player):
		attack_timer = attack_cooldown

func take_damage(amount: int, attacker_position: Vector2):
	if is_dead:
		return
	_som_slime_tomando_dano.play();
	current_health -= amount
	_piscar_dano()
	# knockback
	var direction = (position - attacker_position).normalized()
	knockback_velocity = direction * 150
	knockback_timer = 0.2
	is_stunned = true
	print(current_health)
	if current_health <= 0:
		_die()

func _piscar_dano():
	for i in range(3):
		var original_color = skin.modulate
		skin.modulate = Color(1, 0, 0, 0.5)  # vermelho com 50% de opacidade
		await get_tree().create_timer(0.1).timeout
		skin.modulate = original_color

func _on_multiply_timeout():
	if is_dead:
		return

	var slime_count = get_tree().get_nodes_in_group("slimes").size()
	if slime_count >= 8:
		return

	var new_slime = duplicate()
	new_slime.position = position + Vector2(20, 0) # ligeiramente ao lado
	get_parent().add_child(new_slime)

func _player_is_visivel(retorno):
	visivel = retorno
func _die():
	is_dead = true
	


func _on_visao_body_entered(player: Node2D) -> void:
	if player.is_in_group("player"):
		_player_is_visivel(true);
		print('O player está visivel para o slime');
	else:
		return;

extends CharacterBody2D

@export var speed := 100
@export var max_health := 100
@export var regen_amount := 5
@export var regen_interval := 3.0
@export var attack_slow_damage := 30
@export var attack_fast_damage := 8
@export var attack_range := 40.0
@export var attack_cooldown := 1.5
@export var attack_fast_cooldown := 0.5

var current_health := max_health
var target: CharacterBody2D = null
var attack_timer := 0.0
var regen_timer := 0.0
var is_dead := false

@onready var sprite := $Animation

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]
	else:
		push_error("Nenhum nó no grupo 'player' encontrado.")

func _physics_process(delta):
	if is_dead or not target or not is_instance_valid(target):
		return

	# Atualiza ataque e regen independentemente
	attack_timer -= delta
	regen_timer += delta

	# Distância até o alvo
	var distance = position.distance_to(target.position)

	# Ataque se estiver perto
	if distance <= attack_range:
		if attack_timer <= 0:
			_attack(target)
	else:
		_chase_target(delta)

	_handle_regen()

func _chase_target(delta):
	var direction = (target.position - position).normalized()
	velocity = direction * speed
	move_and_slide()
	sprite.play("run")

func _attack(player):
	var use_slow = randf() < 0.3  # 30% de chance de ataque forte
	if use_slow:
		sprite.play("smash")
		player.call_deferred("take_damage", attack_slow_damage)
		attack_timer = attack_cooldown
	else:
		sprite.play("thrust")
		player.call_deferred("take_damage", attack_fast_damage)
		attack_timer = attack_fast_cooldown

func _handle_regen():
	if regen_timer >= regen_interval and current_health < max_health:
		current_health = min(current_health + regen_amount, max_health)
		sprite.play("heal")
		regen_timer = 0.0

func take_damage(amount):
	current_health -= amount
	if current_health <= 0:
		_die()

func _die():
	is_dead = true
	velocity = Vector2.ZERO
	sprite.play("death")
	set_physics_process(false)

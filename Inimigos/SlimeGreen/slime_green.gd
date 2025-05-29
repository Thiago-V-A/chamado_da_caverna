extends CharacterBody2D

@export var speed := 80
@export var attack_damage = 10
@export var max_health := 30
@export var attack_range := 0
@export var attack_cooldown := 1.5
@export var _jump_timer: Timer

#Atributo:
var current_health := max_health
var target: CharacterBody2D = null
var attack_timer := 0.0
var is_dead := false

#Timer
var _wait_time = 2

@onready var sprite := $Animacao

func _ready():
	_wait_time = 2
	_jump_timer.start(_wait_time)
#	Perseguir player
	
#	Multiplicado de slime
	var multiply_timer = Timer.new()
	multiply_timer.wait_time = 8.0
	multiply_timer.one_shot = false
	multiply_timer.autostart = true
	add_child(multiply_timer)
	multiply_timer.timeout.connect(_on_multiply_timeout)

func _physics_process(delta):
	if is_dead or not target or not is_instance_valid(target):
		return

	attack_timer -= delta

	# Distância até o alvo
	var distance = position.distance_to(target.position)
	
	# Ataque se estiver perto
	if distance == attack_range:
		if attack_timer <= 0:
			_attack(target)
	else:
		_chase_target(delta)
	
func _on_jump_timer_timeout() -> void:
	return

func _get_direction() -> Vector2:
	var direction = (target.position - position).normalized()
	return direction
	
func _chase_target(delta):
	_jump_timer.start(_wait_time)
	velocity = _get_direction() * speed
	move_and_slide()
	sprite.play("correndo")

func _attack(player):
		attack_timer = attack_cooldown

func take_damage(amount: int, attacker_position: Vector2):
	if is_dead:
		return

	current_health -= amount
	
	# Empurra para trás
	var knockback_direction = (position - attacker_position).normalized()
	velocity = knockback_direction * 100  # ajuste a força do recuo conforme quiser

	if current_health <= 0:
		_die()

func _on_multiply_timeout():
	if is_dead:
		return
	
	var slime_count = get_tree().get_nodes_in_group("slimes").size()
	if slime_count >= 8:
		return
	
	var new_slime = duplicate()
	new_slime.position = position + Vector2(20, 0) # ligeiramente ao lado
	get_parent().add_child(new_slime)

func _die():
	is_dead = true
	velocity = Vector2.ZERO
	sprite.play("morte")
	set_physics_process(false)

extends Node2D

@export var SlimeScene: PackedScene

var multiply_timer: Timer

func _ready():
	# Cria o slime inicial
	var initial_slime = SlimeScene.instantiate()
	add_child(initial_slime)
	initial_slime.position = Vector2(0, 0)  # posição inicial

	# Timer de multiplicação
	multiply_timer = Timer.new()
	multiply_timer.wait_time = 5.0
	multiply_timer.one_shot = false
	multiply_timer.autostart = true
	add_child(multiply_timer)
	multiply_timer.timeout.connect(_on_multiply_timeout)

	
func _on_multiply_timeout():

	var slime_count = get_tree().get_nodes_in_group("slimes").size()
	if slime_count >= 8:
		return
	
	var new_slime = SlimeScene.instantiate()
	get_parent().add_child(new_slime)
	new_slime.position = position + Vector2(1, 0)
	new_slime.nascer()

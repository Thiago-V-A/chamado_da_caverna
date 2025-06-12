extends Node2D

@onready var label_left  := $CanvasLayer/LabelLeft        # “Use as teclas”
@onready var wasd_image  := $CanvasLayer/awsd             # sua imagem
@onready var label_right := $CanvasLayer/LabelRight       # “para mover”

var tutorial_stage := 0
var tutorial_done  := false

func _ready() -> void:
	# ─── LABEL ESQUERDO ─────────────────────────────────────────────
	label_left.bbcode_enabled = true
	label_left.visible = true
	label_left.bbcode_text = "[center]Use as teclas[/center]"
	label_left.anchor_left = 0.05
	label_left.anchor_right = 0.30
	label_left.anchor_top = 0.65
	label_left.anchor_bottom = 0.100
	label_left.offset_left = 0
	label_left.offset_right = 0
	label_left.offset_top = 15
	label_left.offset_bottom = 0
	label_left.set("custom_minimum_size", Vector2(200, 30))

	# ─── IMAGEM ───────────────────────────────────────────────────────
	wasd_image.visible = true
	wasd_image.expand = true
	wasd_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	wasd_image.anchor_left = 0.50
	wasd_image.anchor_right = 0.90
	wasd_image.anchor_top = 0.12
	wasd_image.anchor_bottom = 0.27
	wasd_image.offset_left = 0
	wasd_image.offset_right = 0
	wasd_image.offset_top = 0
	wasd_image.offset_bottom = 0

	# ─── LABEL DIREITO ────────────────────────────────────────────────
	label_right.bbcode_enabled = true
	label_right.visible = true
	label_right.bbcode_text = "[center]para mover[/center]"
	label_right.anchor_left = 0.40
	label_right.anchor_right = 0.80
	label_right.anchor_top = 0.65
	label_right.anchor_bottom = 0.100
	label_right.offset_left = 0
	label_right.offset_right = 0
	label_right.offset_top = 15
	label_right.offset_bottom = 0
	label_right.set("custom_minimum_size", Vector2(200, 30))

func _process(delta: float) -> void:
	if not tutorial_done:
		travar_todos_mobs()
	else:
		destravar_todos_mobs()
	if tutorial_stage == 0 and _player_pressed_move_key():
		tutorial_stage = 1
		_avancar_para_tutorial_ataque()
		slime_persegue()
		await get_tree().create_timer(1.0).timeout
		var personagens = get_tree().get_nodes_in_group("personagem")
		var personagem = personagens[0]
		personagem.travar_movimento()

	elif tutorial_stage == 2 and Input.is_action_just_pressed("atacar"):  # certifique-se de mapear "attack"
		
		var slime = $Slime_tutorial
		if  not slime:
				tutorial_stage = 3
				print("aaaa")
				tutorial_stage = 3
				var personagens = get_tree().get_nodes_in_group("personagem")
				personagens[0].destravar_movimento()
				_avancar_para_tutorial_minerar() 
			
	elif tutorial_stage == 3 and  Input.is_action_just_pressed("atacar"):
		var pedra = $pedra3
		if not pedra:
			tutorial_stage = 4
			_finalizar_tutorial()

func _player_pressed_move_key() -> bool:
	return (
		Input.is_action_just_pressed("ui_left")  or
		Input.is_action_just_pressed("ui_right") or
		Input.is_action_just_pressed("ui_up")    or
		Input.is_action_just_pressed("ui_down")  or
		Input.is_key_pressed(KEY_W) or
		Input.is_key_pressed(KEY_A) or
		Input.is_key_pressed(KEY_S) or
		Input.is_key_pressed(KEY_D)
	)
	


# ──────────────────────────────────────────────────────────────
# Função reutilizável para esconder tudo após X segundos
func esconder_mensagem(segundos: float, proxima_acao: Callable) -> void:
	await get_tree().create_timer(segundos).timeout
	label_left.visible = false
	wasd_image.visible = false
	label_right.visible = false
	proxima_acao.call()

# ──────────────────────────────────────────────────────────────
# Fase 1 → Fase 2 (Movimentar → Atacar)
func _avancar_para_tutorial_ataque() -> void:
	esconder_mensagem(0.5, func():
		tutorial_stage = 2
		label_left.bbcode_text = "[center]Clique com o \n botão esquerdo do mouse \n para atacar[/center]"
		label_left.anchor_left = 0.35
		label_left.anchor_right = 0.65
		label_left.anchor_top = 0.05
		label_left.anchor_bottom = 0.15
		label_left.offset_left = 0
		label_left.offset_right = 0
		label_left.offset_top = 0
		label_left.offset_bottom = 0
		label_left.set("custom_minimum_size", Vector2(200, 100))
		label_left.visible = true
	)

# ──────────────────────────────────────────────────────────────
# Fase 2 → Fase 3 (Atacar → minerar)
func _avancar_para_tutorial_minerar() -> void:
	esconder_mensagem(0.5, func():
		tutorial_stage = 2
		label_left.bbcode_text = "[center]Cliqueno numero 2 \n para equipar a picareta \n e utilize o botao esquerdo para minerar[/center]"
		label_left.anchor_left = 0.35
		label_left.anchor_right = 0.65
		label_left.anchor_top = 0.05
		label_left.anchor_bottom = 0.15
		label_left.offset_left = 0
		label_left.offset_right = 0
		label_left.offset_top = 0
		label_left.offset_bottom = 0
		label_left.set("custom_minimum_size", Vector2(200, 100))
		label_left.visible = true
	)

# ──────────────────────────────────────────────────────────────
# Fase 3 → Fim do tutorial
func _finalizar_tutorial() -> void:
	esconder_mensagem(1.0, func():
		tutorial_done = true
	)

func slime_persegue():
	# Busca o slime específico do tutorial
	var slime_tutorial = $Slime_tutorial  # Ajuste o caminho conforme sua cena
	
	# Busca o personagem
	var personagens = get_tree().get_nodes_in_group("personagem")
	
	if slime_tutorial and personagens.size() > 0:
		var personagem = personagens[0]
		slime_tutorial.iniciar_perseguicao_tutorial(personagem)
# No script do tutorial, adicione:
func travar_todos_mobs():
	var mobs = get_tree().get_nodes_in_group("entity")
	for mob in mobs:
		if mob.has_method("travar_movimento"):
			mob.travar_movimento()
			
func destravar_todos_mobs():
	var mobs = get_tree().get_nodes_in_group("entity")
	for mob in mobs:
		if mob.has_method("destravar_movimento"):
			mob.destravar_movimento()

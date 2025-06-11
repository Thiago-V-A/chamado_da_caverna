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
	if tutorial_stage == 0 and _player_pressed_move_key():
		tutorial_stage = 1
		_avancar_para_tutorial_ataque()

	elif tutorial_stage == 2 and Input.is_action_just_pressed("atacar"):  # certifique-se de mapear "attack"
		tutorial_stage = 3
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
	esconder_mensagem(4.0, func():
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
# Fase 2 → Fase 3 (Atacar → Defender)


# ──────────────────────────────────────────────────────────────
# Fase 3 → Fim do tutorial
func _finalizar_tutorial() -> void:
	esconder_mensagem(4.0, func():
		tutorial_done = true
		print("Tutorial finalizado!")
	)

# Quiz.gd — Godot 4.x (GDScript)
extends "res://Script/mainmenu.gd"

@onready var verb_selector: OptionButton = %VerbSelector
@onready var reset_btn: Button = %ResetButton
@onready var back_btn: Button = %BackButton
@onready var score_label: Label = %ScoreLabel
@onready var feedback_label: Label = %FeedbackLabel
@onready var pronouns_box: GridContainer = %Pronouns
@onready var forms_box: GridContainer = %Forms
@onready var soundController: AudioStreamPlayer2D = %Sound
var current_verb: String = "sein"
var matched_pairs: int = 0

# Визуальные настройки
const OK_COLOR := Color(0.1, 0.7, 0.2) # зелёный
const WRONG_COLOR := Color(0.8, 0.2, 0.2)
const IDLE_COLOR := Color(1, 1, 1)

# Данные: порядок местоимений и их подписи
const PRONOUN_KEYS := ["ich", "du", "er", "sie_f", "es", "wir", "ihr", "sie_pl", "Sie"]
const PRONOUN_LABEL := {
	"ich": 		"ich",
	"du": 		"du",
	"er": 		"er",
	"sie_f":	"sie (она)",
	"es": 		"es",
	"wir": 		"wir",
	"ihr": 		"ihr",
	"sie_pl": 	"sie (они)",
	"Sie": 		"Sie (вежл.)"
}
const PRONOUN_SOUND := {
	"ich": 		"res://Sound/pronoun/ich.wav",
	"du": 		"res://Sound/pronoun/du.wav",
	"er": 		"res://Sound/pronoun/er.wav",
	"sie_f":	"res://Sound/pronoun/sie.wav",
	"es": 		"res://Sound/pronoun/es.wav",
	"wir": 		"res://Sound/pronoun/wir.wav",
	"ihr": 		"res://Sound/pronoun/ihr.wav",
	"sie_pl": 	"res://Sound/pronoun/sie.wav",
	"Sie": 		"res://Sound/pronoun/sie.wav"
}
const VERB_SOUND := {
	"bin":  "res://Sound/sein/bin.wav", 
	"bist": "res://Sound/sein/bist.wav",
	"ist":  "res://Sound/sein/ist.wav", 
	"sind": "res://Sound/sein/sind.wav",
	"seid": "res://Sound/sein/seid.wav",
	"habe":  "res://Sound/haben/habe.wav", 
	"hast":  "res://Sound/haben/hast.wav",
	"hat":   "res://Sound/haben/hat.wav", 
	"haben": "res://Sound/haben/haben.wav",
	"habt":  "res://Sound/haben/habt.wav"
}
# Карты соответствий в Präsens
const FORMS := {
	"sein": {
		"ich":    "bin", 
		"du":     "bist", 
		"er":     "ist", 
		"sie_f":  "ist", 
		"es":     "ist", 
		"wir":    "sind", 
		"ihr":    "seid", 
		"sie_pl": "sind", 
		"Sie":    "sind"
	},
	"haben": {
		"ich":    "habe",
		"du":     "hast",
		"er":     "hat", 
		"sie_f":  "hat", 
		"es":     "hat", 
		"wir":    "haben",
		"ihr": 	  "habt", 
		"sie_pl": "haben", 
		"Sie": 	  "haben", 
	}
}

# Текущее состояние раунда
var left_buttons: Array[Button] = []
var right_buttons: Array[Button] = []
var selected_left_idx: int = -1
var selected_left_key: String = "";
var selected_right_key: String = "";

func _ready() -> void:
	verb_selector.clear()
	verb_selector.add_item("sein")
	verb_selector.add_item("haben")
	verb_selector.select(0)
	verb_selector.item_selected.connect(_on_verb_selected)
	reset_btn.pressed.connect(_on_reset_pressed)
	back_btn.pressed.connect(_go_to_mainMenu)
	_build_round()

func _on_verb_selected(_idx: int) -> void:
	current_verb = verb_selector.get_item_text(_idx)
	_build_round()

func _on_reset_pressed() -> void:
	_build_round()
	
func _go_to_mainMenu() -> void:
	_hide_welcome(sein_block);

func _build_round() -> void:
	# Сброс
	matched_pairs = 0
	selected_left_idx = -1
	feedback_label.text = ""
	_update_score()
	_clear_children(pronouns_box)
	_clear_children(forms_box)
	left_buttons.clear()
	right_buttons.clear()
	
	var pronoun_list: Array[String] = []
	for i in PRONOUN_KEYS.size():
		pronoun_list.append(PRONOUN_KEYS[i])
	pronoun_list.shuffle()

	# Слева — 9 кнопок с местоимениями в фиксированном порядке
	for i in pronoun_list.size():
		var key: String = pronoun_list[i]
		var b := Button.new()
		b.text = PRONOUN_LABEL[key]
		b.custom_minimum_size  = Vector2(0,50)
		b.toggle_mode = false
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(func():
			_on_left_pressed(i, key)
		)
		pronouns_box.add_child(b)
		left_buttons.append(b)

	# Справа — те же 9 форм (с повторами), но перетасованные
	var forms_list: Array[String] = []
	for key: String in PRONOUN_KEYS:
		forms_list.append(FORMS[current_verb][key])
	forms_list.shuffle()

	for i in forms_list.size():
		var key := forms_list[i]
		var b2 := Button.new()
		b2.text = key
		b2.custom_minimum_size  = Vector2(0,50)
		b2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b2.pressed.connect(func():
			_on_right_pressed(i, key)
		)
		forms_box.add_child(b2)
		right_buttons.append(b2)

func _on_left_pressed(i: int, key: String) -> void:
	# Выделить выбранное местоимение
	selected_left_idx = i;
	selected_left_key = key;
	feedback_label.text = "Выбери форму для: %s" % PRONOUN_LABEL[key];
	soundController.stream = load(PRONOUN_SOUND[key]);
	soundController.play();
	_highlight_left(i)

func _on_right_pressed(i: int, key: String) -> void:
	if selected_left_idx == -1:
		feedback_label.text = "Сначала выбери местоимение слева."
		feedback_label.modulate = WRONG_COLOR
		return
	selected_right_key = "";
	
	var got = FORMS[current_verb][selected_left_key] 

	if got == key and not right_buttons[i].disabled and not left_buttons[selected_left_idx].disabled:
		# Верно — фиксируем пару
		_mark_pair_ok(selected_left_idx, i)
		matched_pairs += 1
		_update_score()
		feedback_label.text = "Верно: %s — %s" % [selected_left_key, got]
		feedback_label.modulate = OK_COLOR
		selected_left_idx = -1
		soundController.stream = load(VERB_SOUND[key]);
		soundController.play();
		
		# Успех раунда
		if matched_pairs >= PRONOUN_KEYS.size():
			feedback_label.text = "Готово! Нажми «Сброс» или переключи глагол."
	else:
		# Неверно — короткая подсветка
		feedback_label.text = "Неверно, попробуй ещё."
		feedback_label.modulate = WRONG_COLOR
		soundController.stream = load("res://Sound/error.wav");
		soundController.play();
		_flash_wrong(right_buttons[i])

func _mark_pair_ok(i: int, j: int) -> void:
	var lb := left_buttons[i]
	var rb := right_buttons[j]
	lb.disabled = true
	rb.disabled = true
	lb.modulate = OK_COLOR
	rb.modulate = OK_COLOR

func _highlight_left(i: int) -> void:
	for idx in left_buttons.size():
		left_buttons[idx].modulate = IDLE_COLOR if not left_buttons[idx].disabled else OK_COLOR
	if i >= 0 and i < left_buttons.size():
		left_buttons[i].modulate = Color(0.9, 0.9, 0.4) # мягкий акцент

func _flash_wrong(btn: Button) -> void:
	btn.modulate = WRONG_COLOR
	await get_tree().create_timer(0.25).timeout
	if not btn.disabled:
		btn.modulate = IDLE_COLOR

func _update_score() -> void:
	score_label.text = "%d/%d" % [matched_pairs, PRONOUN_KEYS.size()]

func _clear_children(node: Node) -> void:
	for c in node.get_children():
		c.queue_free()

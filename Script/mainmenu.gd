extends Control;
@onready var sein_btn: Button = %SeinButton;
@onready var welcome_block: VBoxContainer = %Welcome;
@onready var avatar_block: MarginContainer = %AvatarContainer;
@onready var up_block: Panel = %Up;
@onready var down_block: Panel = %Down;
@onready var main_block: MarginContainer = %MainMenu;
@onready var sein_block: MarginContainer = %Sein;
@onready var avatar_panel_block: Panel = %AvatarPanel;
@onready var fade_block: Panel = %AvatarPanel;
var isWelcome = true;

func _ready():
	sein_btn.pressed.connect(_go_to_sein);

func _hide_welcome(_target) -> void:
	var tween = get_tree().create_tween().set_parallel(true).set_ease(Tween.EASE_OUT);
	if isWelcome:
		#tween.tween_property(welcome_block, "position", Vector2(-300, welcome_block.position.y), 0.3);
		#tween.tween_property(avatar_block, "theme_override_constants/margin_top", 15, 0.3);
		#tween.tween_property(up_block, "custom_minimum_size", Vector2(0, 0), 0.2);
		#tween.tween_property(avatar_panel_block, "custom_minimum_size", Vector2(0, 0), 0.2);
		#tween.tween_property(_target, "position", Vector2(0, _target.position.y), 0.3);
		#tween.tween_property(main_block, "position", Vector2(-500, main_block.position.y), 0.3);
		tween.tween_property(down_block, "position", Vector2(0, -33), 0.1);
	else:
		#tween.tween_property(up_block, "custom_minimum_size", Vector2(0, 300), 0.2);
		#tween.tween_property(avatar_panel_block, "custom_minimum_size", Vector2(128, 128), 0.2);
		#tween.tween_property(avatar_block, "theme_override_constants/margin_top", 100, 0.3);
		#tween.tween_property(welcome_block, "position", Vector2(15, welcome_block.position.y), 0.5).set_trans(Tween.TRANS_ELASTIC);
		#tween.tween_property(_target, "position", Vector2(500, _target.position.y), 0.3);
		#tween.tween_property(main_block, "position", Vector2(0, main_block.position.y), 0.3);
		tween.tween_property(down_block, "position", Vector2(0, 300), 0.1);
	isWelcome = !isWelcome;

func _go_to_sein() -> void:
	#get_tree().change_scene_to_file("res://seinHaben.tscn")
	_hide_welcome(sein_block);

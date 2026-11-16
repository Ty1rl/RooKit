extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var user_label: RichTextLabel = $UserLabel

@onready var _sprite_effect := SpriteFrameEffect.new()

var username: String = ""
var size: float = 1.0


func _ready() -> void:
	# Prepare the emojis handler
	user_label.install_effect(_sprite_effect) # Install the emojihandler into the richtext label
	user_label.text = _sprite_effect.prepare_message("[b]" + username + "[/b]", user_label)
	
	scale = Vector2.ONE * size
	
	animated_sprite.play("idle")


func _on_animated_sprite_2d_animation_changed() -> void:
	if animated_sprite.animation == "enter":
		user_label.visible = false

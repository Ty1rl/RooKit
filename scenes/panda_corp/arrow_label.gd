extends RichTextLabel

const ARROWS: Array[String] = ["[b]△[/b]", "[b]▽[/b]"]


func _on_door_opening_started() -> void:
	text = ARROWS.pick_random()


func _on_door_closing_finished() -> void:
	text = ""

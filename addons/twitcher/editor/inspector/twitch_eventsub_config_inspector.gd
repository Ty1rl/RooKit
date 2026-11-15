extends EditorInspectorPlugin

const EventsubConditionProperty = preload("res://addons/twitcher/editor/inspector/twitch_eventsub_condition_property.gd")
const EventsubDocsProperty = preload("res://addons/twitcher/editor/inspector/twitch_eventsub_docs_property.gd")

func _can_handle(object: Object) -> bool:
	return object is TwitchEventsubConfig


func _parse_property(object: Object, type: Variant.Type, name: String, \
		hint_type: PropertyHint, hint_string: String, usage_flags: int, \
		wide: bool) -> bool:

	if name == &"condition":
		add_property_editor("condition", EventsubConditionProperty.new(), true)
		return true
	if name == &"type":
		add_property_editor("type", EventsubDocsProperty.new(), true, "Documentation")
	return false

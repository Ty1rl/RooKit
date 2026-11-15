extends Control

@export var scene_parent: Node

@onready var scene_list: ItemList = %SceneList

var scenes: Dictionary[StringName,String] = {}

var active_scene: Dictionary[StringName,Node] = {}


func _ready() -> void:
	for scene_name in scenes.keys():
		scene_list.add_item(scene_name)


func _on_collapse_button_toggled(toggled_on: bool) -> void:
	scene_list.visible = toggled_on


func _on_scene_list_multi_selected(index: int, selected: bool) -> void:
	if not scene_parent:
		printerr("SceneSwitcher: scene parent not set")
		return
	
	var selected_name: StringName = scene_list.get_item_text(index)
	if selected:
		if not active_scene.has(selected_name):
			var selected_scene: Node = load(scenes.get(selected_name)).instantiate()
			active_scene[selected_name] = selected_scene
			scene_parent.add_child(selected_scene)
	elif active_scene.has(selected_name):
		var selected_scene: Node = active_scene.get(selected_name)
		selected_scene.queue_free()
		active_scene.erase(selected_name)

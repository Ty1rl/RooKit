extends Control

@export var scene_parent: Node

@onready var scene_list: ItemList = %SceneList

var scenes: Dictionary[StringName,String] = {
	&"Clock-in" : "uid://b2fq8v2ed247x",
	&"Clock-in Overlay" : "uid://brcxplrppn8u5",
	&"Bongos" : "uid://0s23bgajhsy0"
}

var active_scene: Dictionary[StringName,Node] = {}


func _ready() -> void:
	for scene_name in scenes.keys():
		scene_list.add_item(scene_name)
	
	scene_list.select(0)
	_add_scene(&"Clock-in")


func _on_scene_list_multi_selected(index: int, selected: bool) -> void:
	if not scene_parent:
		printerr("SceneSwitcher: scene parent not set")
		return
	
	var selected_name: StringName = scene_list.get_item_text(index)
	if selected:
		_add_scene(selected_name)
	else:
		_remove_scene(selected_name)


func _add_scene(scene_name: StringName) -> void:
	if not active_scene.has(scene_name):
			var scene: Node = load(scenes.get(scene_name)).instantiate()
			active_scene[scene_name] = scene
			scene_parent.add_child(scene)


func _remove_scene(scene_name: StringName) -> void:
	if active_scene.has(scene_name):
		var scene: Node = active_scene.get(scene_name)
		scene.queue_free()
		active_scene.erase(scene_name)

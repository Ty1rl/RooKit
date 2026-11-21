extends ItemList

@export var scene_parent: Node

var scenes: Dictionary[StringName,String] = {
	&"Clock-in" : "uid://b2fq8v2ed247x",
	&"Clock-in Overlay" : "uid://brcxplrppn8u5",
	&"Bongos" : "uid://0s23bgajhsy0"
}

var active_scene: Node


func _ready() -> void:
	item_selected.connect(_on_item_selected)
	
	for scene_name in scenes.keys():
		add_item(scene_name)
	
	select(0)
	active_scene = load(scenes.get(&"Clock-in")).instantiate()
	scene_parent.add_child(active_scene)


func _on_item_selected(index: int) -> void:
	if not scene_parent:
		printerr("SceneSwitcher: scene parent not set")
		return
	
	var selected_name: StringName = get_item_text(index)
	
	active_scene.queue_free()
	
	active_scene = load(scenes.get(selected_name)).instantiate()
	scene_parent.add_child(active_scene)


#func _on_multi_selected(index: int, selected: bool) -> void:
	#if not scene_parent:
		#printerr("SceneSwitcher: scene parent not set")
		#return
	#
	#var selected_name: StringName = get_item_text(index)
	#if selected:
		#_add_scene(selected_name)
	#else:
		#_remove_scene(selected_name)


#func _add_scene(scene_name: StringName) -> void:
	#if not active_scene.has(scene_name):
		#var scene: Node = load(scenes.get(scene_name)).instantiate()
		#active_scene[scene_name] = scene
		#scene_parent.add_child(scene)


#func _remove_scene(scene_name: StringName) -> void:
	#if active_scene.has(scene_name):
		#var scene: Node = active_scene.get(scene_name)
		#scene.queue_free()
		#active_scene.erase(scene_name)

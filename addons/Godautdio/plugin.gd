@tool
extends EditorPlugin

var inspector_drawer
var audio_manager_editor_window
var audio_manager_singleton


func _enter_tree():
	inspector_drawer = preload("res://addons/Godautdio/editor/audio_ref_inspector.gd").new()
	audio_manager_editor_window = preload("res://addons/Godautdio/Nodes/audio_manager_ui.tscn").instantiate()
	add_autoload_singleton("Godautdio","res://addons/Godautdio/Scripts/Godautdio.gd")
	add_inspector_plugin(inspector_drawer)
	add_control_to_bottom_panel(audio_manager_editor_window,"Godautdio")
	make_bottom_panel_item_visible(audio_manager_editor_window)


func _exit_tree():
	remove_autoload_singleton("Godautdio",)
	remove_inspector_plugin(inspector_drawer)
	remove_control_from_bottom_panel(audio_manager_editor_window)
	audio_manager_editor_window.free()

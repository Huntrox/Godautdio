@tool
extends PopupPanel
class_name AudioPicker

@onready var search_filter_input:LineEdit = $VBoxContainer/SearchFilterInput
@onready var tree = $VBoxContainer/Tree

var current_filter:String = ""
var current_calback:Callable

var audio_library:AudioLibrary

func show_filter(on_select_callback:Callable,mouse_position:Vector2)->void:
	search_filter_input.grab_focus() 
	current_calback = on_select_callback
	audio_library = preload("res://addons/Godautdio/Resources/AudioLib.tres") as AudioLibrary
	refresh_tree()
	position = mouse_position
	show()

func _on_search_filter_input_text_changed(new_text:String)->void:
	current_filter = new_text
	refresh_tree()

func refresh_tree()->void:
	tree.clear()
	var root = tree.create_item()
	tree.hide_root = true
	var paths = audio_library.audio_clips.map(func(clip:AudioClip): return clip.clip_path)
	var tree_dict = GodautdioUtils.path_list_to_tree_dict(paths,current_filter)
	var path_icons = {}
	for path in paths:
		path_icons[path]={}
		path_icons[path]["type"] = audio_library.clips_dict[path].clip_space_type
	GodautdioUtils.create_tree_from_dict(tree_dict,tree,root,path_icons)	
	
func _on_tree_item_selected()->void:
	var selected = tree.get_selected()
	var meta = selected.get_metadata(0)
	if meta and current_calback:
		current_calback.call(meta)
		hide()

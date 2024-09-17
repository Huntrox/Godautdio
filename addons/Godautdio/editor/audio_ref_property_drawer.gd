extends EditorProperty


# The main control for editing the property.
var ply_btn_property_control:Button
var search_btn_property_control:Button
#var path_input_property_control:LineEdit

var property_control = preload("res://addons/Godautdio/Nodes/audio_ref_property.tscn")
var menu_tree_panal = preload("res://addons/Godautdio/Nodes/audio_picker.tscn")

var audio_picker_menu:AudioPicker
var updating = false

var audio_ref:AudioRef

func _init()->void:

	var prop = property_control.instantiate()
	ply_btn_property_control = prop.find_child("plyBtn") as Button
	search_btn_property_control = prop.find_child("srchBtn") as Button

	
	audio_picker_menu = menu_tree_panal.instantiate()
	audio_picker_menu.hide()
	add_child(prop)
	add_child(audio_picker_menu)
	
	add_focusable(ply_btn_property_control)
	
	ply_btn_property_control.pressed.connect(_on_play_button_pressed)
	search_btn_property_control.pressed.connect(_on_search_button_pressed)


		

func _ready()->void:
	audio_ref = get_edited_object()[get_edited_property()] as AudioRef
	var audio_lib:AudioLibrary = preload("res://addons/Godautdio/Resources/AudioLib.tres")
	if audio_ref == null or not audio_lib.clips_dict.has(audio_ref.clip_path):
		audio_ref = AudioRef.new()
		emit_changed(get_edited_property(),audio_ref)
		
	refresh_control_text()
	
func _on_path_input_changed(new_value:String) ->void:
	print(new_value)
	audio_ref.clip_path = new_value
	emit_changed(get_edited_property(),audio_ref)

	
func _on_play_button_pressed() ->void:
	if (updating):
		return
	print("PRESSED: " + str(audio_ref.clip_path))
	Godautdio.editor_preivew(audio_ref)
#	refresh_control_text()
#	emit_changed(get_edited_property(), current_value)


func _on_search_button_pressed() ->void:
	if (updating):
		return
	audio_picker_menu.show_filter(on_item_selected,get_screen_position())
	


func on_item_selected(value:String) ->void:
	audio_ref.clip_path = value
	search_btn_property_control.text = value
	emit_changed(get_edited_property(),audio_ref)
	

func _update_property() ->void:
	pass

func refresh_control_text() ->void:
	search_btn_property_control.text = audio_ref.clip_path

	

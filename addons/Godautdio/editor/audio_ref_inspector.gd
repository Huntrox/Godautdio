extends EditorInspectorPlugin

var audio_ref_drawer = preload("res://addons/Godautdio/editor/audio_ref_property_drawer.gd")


func _can_handle(object):
	return true
	

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide)->bool:
	if hint_string == "AudioRef":
		add_property_editor(name, audio_ref_drawer.new())
		return true
	return false

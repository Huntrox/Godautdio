extends EditorInspectorPlugin

var audio_ref_drawer = preload("res://addons/Godautdio/editor/audio_ref_property_drawer.gd")


func _can_handle(object: Object) -> bool:
	return true
	
func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if hint_string == "AudioRef":
		add_property_editor(name, audio_ref_drawer.new())
		return true
	return false

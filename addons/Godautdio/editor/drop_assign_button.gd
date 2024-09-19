@tool
extends Control

@export var multiple_files:bool = false

signal on_file_dropped(file)


func _drop_data(position: Vector2, data) -> void:
	if multiple_files:
		for file in data.files:
			on_file_dropped.emit(file)
	else:
		var file: String = data.files[0]
		on_file_dropped.emit(file)


func _can_drop_data(position: Vector2, data) -> bool:
	var filter:Array[String] = Godautdio.audio_library.audio_files_format
	
	if not data is Dictionary or not "type" in data:
		return false
	if data.type != "files":
		return false
	if data.files.size() != 1 and not multiple_files:
		return false
	if not multiple_files:
		return is_allowed_type(data.files[0],filter)
	var all_files_valid = true
	
	for file in data.files:
		if not is_allowed_type(file,filter):
			all_files_valid = false
			break
	return all_files_valid

func is_allowed_type(file_path:String,filter:Array[String])->bool:
	var file = load(file_path)
	if file is AudioStream and filter.has(file_path.get_extension()):
		return true
	return false


#func _get_drag_data(position:Vector2)->Variant:
	#return 
	#pass

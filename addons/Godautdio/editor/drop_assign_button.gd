@tool
extends Control

@export var multiple_files:bool = false
@export var filter:Array[String] = ["mp3","wav","ogg"]
signal on_file_dropped(file)


func _drop_data(position: Vector2, data) -> void:

	if multiple_files:
		for file in data.files:
			on_file_dropped.emit(file)
	else:
		var file: String = data.files[0]
		on_file_dropped.emit(file)


func _can_drop_data(position: Vector2, data) -> bool:
	if not data is Dictionary or not "type" in data:
		return false
	if data.type != "files":
		return false
	if data.files.size() != 1 and not multiple_files:
		return false
	if not multiple_files:
		return filter.has(data.files[0].get_extension())
	var all_files_valid = true
	
	for file in data.files:
		if not filter.has(file.get_extension()):
			all_files_valid = false
			break
	return all_files_valid



#func _get_drag_data(position:Vector2)->Variant:
	#return 
	#pass

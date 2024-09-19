@tool
extends Control
class_name StreamField





var ui_manager:GodautdioEditorUI
@export var stream_index:int
@export var weight_slider:HSlider
@export var weight_input:SpinBox
@export var path_input:LineEdit

var current_stream_path:String

func set_value(stream:AudioStream,weight:float,index:int,manager:GodautdioEditorUI) ->void:
	stream_index = index
	ui_manager = manager
	if stream:
		set_stream(stream.resource_path)
	else:
		set_stream("")
	if weight_input:
		weight_input.set_value_no_signal(weight)
	if weight_slider:
		weight_slider.set_value_no_signal(weight)
		
	


func on_assign_btn() ->void:
	if ui_manager:
		ui_manager.clip_file_open_dailogue.clear_filters()
		for filter:String in Godautdio.filters:
			ui_manager.clip_file_open_dailogue.add_filter("*."+filter)
		ui_manager.clip_file_open_dailogue.file_selected.connect(_try_set_stream)
		ui_manager.clip_file_open_dailogue.popup()
		await ui_manager.clip_file_open_dailogue.file_selected
		ui_manager.clip_file_open_dailogue.file_selected.disconnect(_try_set_stream)



func _try_set_stream(file:String) ->void:
	if file.is_empty():
		return
	on_drop_file(file)


func set_stream(path:String) ->void:
	current_stream_path = path
	if not path == "":
		var file_name = path.split("/")[-1]
		path_input.text = file_name
	else:
		path_input.text = ""
	

func on_drop_file(file:String) ->void:
	if ui_manager and ui_manager.on_stream_file_dropped(stream_index,file):
		set_stream(file)

func on_preview_stream() ->void:
	if ui_manager:
		ui_manager.on_stream_preview(stream_index)
		
func on_delete_element() ->void:
	if path_input:
		path_input.text = ""
	current_stream_path = ""
	if ui_manager:
		ui_manager.on_stream_element_deleted(stream_index)
		

func on_weight_input_changed(value:float) ->void:
	if weight_slider:
		weight_slider.set_value_no_signal(value)
	on_weight_value_changed(value)

func on_weight_slider_changed(value:float) ->void:
	if weight_input:
		weight_input.set_value_no_signal(value)
	on_weight_value_changed(value)


func on_weight_value_changed(value:float) ->void:
	if ui_manager:
		ui_manager.on_stream_weight_changed(stream_index,value)

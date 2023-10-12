extends Control

@export var audio_clip:AudioRef

var clip_loops:int = 0
var clip_delay:float = 0
var clip_path:String = "UI/time_over"

func _on_print_current():
	Godautdio._log_current()


func _on_pressed_():
	#ui_click.play_audio().set_loops(5).set_delay(5.5)
	var first:Godautdio.RefResult = Godautdio.play_by_path("sfx/hit") as Godautdio.RefResult
#	var sec:Godautdio.RefResult = Godautdio.play_by_path("sfx/hitss") as Godautdio.RefResult

	GodautdioUtils.log(first.stream_state)
#	GodautdioUtils.log(sec.stream_state)


func play_audio_by_path():
	Godautdio.play_by_path(clip_path)

func play_audio_clip():
	audio_clip.play().set_loops(clip_loops).set_delay(clip_delay)

func stop_audio_clip():
	audio_clip.stop()
	
	
	


func _on_line_edit_text_changed(new_text):
	clip_path = new_text


func _on_loop_spin_box_value_changed(value):
	clip_loops = int(value)


func _on_delay_spin_box_value_changed(value):
	clip_delay = value

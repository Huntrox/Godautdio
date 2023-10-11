extends Control

@export var test_audio:AudioRef


func _on_print_current():
	Godautdio._log_current()


func _on_pressed_():
	#ui_click.play_audio().set_loops(5).set_delay(5.5)
	var first:Godautdio.RefResult = Godautdio.play_by_path("sfx/hit") as Godautdio.RefResult
#	var sec:Godautdio.RefResult = Godautdio.play_by_path("sfx/hitss") as Godautdio.RefResult

	GodautdioUtils.log(first.stream_state)
#	GodautdioUtils.log(sec.stream_state)

func _on_test_audio():
	test_audio.play(false)
	
func _on_test_audio_print():
	GodautdioUtils.log(test_audio.instance_id)

func clear_audio():
	Godautdio.clear()

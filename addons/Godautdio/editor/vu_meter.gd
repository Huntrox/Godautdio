@tool
extends Control

@onready var vu_meter_bar_left = $VUMeterLeftChannel
@onready var vu_meter_bar_right = $VUMeterRightChannel


func _process(delta):

	if Engine.is_editor_hint() and Godautdio and Godautdio.editor_audio_instance.is_playing():
		vu_meter_bar_left.value = AudioServer.get_bus_peak_volume_left_db(0,0)
		vu_meter_bar_right.value = AudioServer.get_bus_peak_volume_right_db(0,0)
	else:
		vu_meter_bar_left.value = lerp(vu_meter_bar_left.value, -80.0,delta * 10)
		vu_meter_bar_right.value = lerp(vu_meter_bar_right.value, -80.0,delta * 10)


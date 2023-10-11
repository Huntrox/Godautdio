extends AudioStreamPlayer
class_name AudioInstance

var instance_id:String

func setup_instance(sound:AudioStream,params:ClipParams):
	set_stream(sound)
	volume_db = params.volume_db
	pitch_scale = params.pitch_scale

	
func on_finish():
	Godautdio.on_instance_finish(self)
	queue_free()

extends Node
class_name AudioInstance

var instance_id:String

	
func on_finish():
	Godautdio.on_instance_finish(self)
	queue_free()

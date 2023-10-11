extends Resource
class_name AudioRef

@export var clip_path:String 

var one_shot:bool
var last_play:Godautdio.RefResult
var instance_id:String

#TODO add signals (on_finish,on_stopped,on_canceled, on_loop_finishied(current_loop:int))

func play(free_on_finish:bool = true)->Godautdio.RefResult:
	return Godautdio.play(self,null,free_on_finish)
	
func play_attached(parent:Node,free_on_finish:bool = true)->Godautdio.RefResult:
	return Godautdio.play(self,parent,free_on_finish)

func stop():
	return Godautdio.stop(self)

func play_at_location(position:Vector3)->Godautdio.RefResult:
	return Godautdio.play_at_location(self,position)
	
func play_one_shot()->Godautdio.RefResult:
	return Godautdio.play_one_shot(self)

func is_playing()->bool:
	return Godautdio.is_playing(self)

func clear():
	Godautdio.erase_ref(self)

func _init(path:String = ""):
	clip_path = path

@tool
extends Node

const STREAM_PLAYER_INSTANCE:String = "stream_player_instance" #Assigned Stream player Instance
const AUDIO_REFERENCE:String = "audio_reference"			   #AudioRef Currently Playing
const CURRENT_CLIP_ID:String  = "current_clip_id"
const CLIP_LOOPS:String  = "clip_loops"
const PLAY_QUEUE_TOKEN:String  = "play_queue_token"
const CLIP_DELAY:String  = "clip_delay"


var audio_instance = preload("res://addons/Godautdio/Nodes/audio_instance.tscn")

var audio_library:AudioLibrary


var currently_playing = {}

var editor_audio_instance:AudioInstance


func _init():
	if Engine.is_editor_hint():
		editor_audio_instance = audio_instance.instantiate()
		add_child(editor_audio_instance)
	reload_db()


func reload_db():
	audio_library = preload("res://addons/Godautdio/Resources/AudioLib.tres")
	
#region EDITOR
func editor_clip_preivew(clip:AudioClip)->void:
	if not Engine.is_editor_hint() or clip == null or clip.clip_stream.streams_count <= 0:
		return
	var instance = setup_editor_instance(clip)
	if clip.params.delay > 0:
			await get_tree().create_timer(clip.params.delay).timeout
	instance.play()

	
func editor_preivew(ref:AudioRef)->void:
	if not Engine.is_editor_hint():
		return
	reload_db()
	if audio_library.clips_dict.has(ref.clip_path):
		var clip:AudioClip = audio_library.clips_dict[ref.clip_path]
		editor_clip_preivew(clip)

func editor_stream_preivew(stream:AudioStream)->void:
	if not Engine.is_editor_hint():
		return
	editor_audio_instance.set_stream(stream)
	editor_audio_instance.volume_db = 0
	editor_audio_instance.pitch_scale = 1
	editor_audio_instance.play()

func setup_editor_instance(clip:AudioClip)-> AudioInstance:
	stop_editor_preivew()
	editor_audio_instance.set_stream(clip.clip_stream)
	editor_audio_instance.volume_db = clip.params.volume_db
	editor_audio_instance.pitch_scale = clip.params.pitch_scale
	editor_audio_instance.bus = AudioServer.get_bus_name(clip.bus_index)
	return editor_audio_instance
	
func stop_editor_preivew()->void:
	if editor_audio_instance.playing:
		editor_audio_instance.stop()
		
#endregion #########################################################################




func play_by_path(path:String,parent:Node = null)-> RefResult:
	var result = RefResult.new()
	var ref = AudioRef.new()
	ref.clip_path = path
	_play_instance(ref,parent,true,result)
	return result
	

#TODO: add use stream player param 

#func play_stream_player(ref:AudioRef,streamPlayer)-> RefResult:
#	var result = ref.last_play if ref.last_play else RefResult.new()
#	if audio_library.clips_dict.has(ref.clip_path) and streamPlayer:
#		var clip:AudioClip = audio_library.clips_dict[ref.clip_path]
#		streamPlayer.stop()
#		streamPlayer = setup_audio_instance(clip,streamPlayer)
#
#	return result

#TODO: add play at specified position on the clip  should be 0.0 to 1.0 ratio. 0.5 means halfway 

#func play_at(ref:AudioRef,position:float)->RefResult:
#	var result = RefResult.new()
#	return result


func play(ref:AudioRef,parent:Node = null,free_on_finish:bool = true)-> RefResult:
	var result = ref.last_play if ref and ref.last_play else RefResult.new()
	_play_instance(ref,parent,free_on_finish,result)
	return result


func play_one_shot(ref:AudioRef,parent:Node = null,target_position:Vector3 = Vector3.ZERO)-> RefResult:
	var result = RefResult.new()
	if audio_library.clips_dict.has(ref.clip_path):
		var clip:AudioClip = audio_library.clips_dict[ref.clip_path]
		var instance = create_new_instance(clip,parent if parent else self)
		if target_position != Vector3.ZERO:
			var space = clip.clip_space_type
			instance = set_instance_position(target_position,space,instance)
		instance.finished.connect(func(): _on_finish_setup(clip,true,instance))
		result.audio_instance = instance
		result.instance_id = instance.instance_id
		ref.last_play = result
		schedule_clip(ref.clip_path,result)
	return result
	
func play_at_location(ref:AudioRef,target_position:Vector3)->RefResult:
	var result = ref.last_play if ref.last_play else RefResult.new()

	var position_2d = Vector2(target_position.x,target_position.y)
	var instance = _play_instance(ref,self,true,result)

	if not result.stream_state == StreamState.NotFound:
		var space = audio_library.clips_dict[ref.clip_path].clip_space_type
		instance = set_instance_position(target_position,space,instance)
	return result

	
func _play_instance(ref:AudioRef,parent:Node,free_on_finish:bool,result:RefResult)->AudioInstance:
#	if not ref:
#
#		return null
#	if ref.clip_path.is_empty():
#		return null
	var instance:AudioInstance
	if audio_library.clips_dict.has(ref.clip_path):
		var clip:AudioClip = audio_library.clips_dict[ref.clip_path]
		if not result.instance_id.is_empty() and currently_playing.has(result.instance_id):
			instance = currently_playing[result.instance_id][STREAM_PLAYER_INSTANCE]
			instance.stop()
		else:## create instance
			instance = create_new_instance(clip,parent if parent else self)
			instance.finished.connect(func(): 
				if not clip.params.looping:
					result.stream_state = StreamState.Finished
				_on_finish_setup(clip,free_on_finish,instance)
			)
		if not ref.last_play:
			ref = ref.duplicate()
		ref.last_play = result
		result.audio_instance = instance
		result.instance_id = instance.instance_id
		ref.instance_id = instance.instance_id
		currently_playing[instance.instance_id][AUDIO_REFERENCE] = ref
		schedule_clip(ref.clip_path,result)
	else:
		result.stream_state = StreamState.NotFound
		GodautdioUtils.log_warn("{0} Was not found on Audio Library".format({"0":str(ref.clip_path)}))
	return instance
	
	
func stop(ref:AudioRef)->RefResult:
	var result = ref.last_play if ref.last_play else RefResult.new() 
	if currently_playing.has(ref.instance_id):
		var stream_player_instance = currently_playing[ref.instance_id][STREAM_PLAYER_INSTANCE]
		stream_player_instance.stop()
		currently_playing[result.instance_id][PLAY_QUEUE_TOKEN] = ""
		result.stream_state = StreamState.Stopped
	return result
	
func stop_ref(instance:String)->void:
	if currently_playing.has(instance):
		var ref = currently_playing[instance][AUDIO_REFERENCE]
		stop(ref)

func stop_all()->void:
	for clip in currently_playing:
		stop(currently_playing[clip][AUDIO_REFERENCE])

func is_playing(ref:AudioRef)->bool:
	if not ref or ref.instance_id.is_empty():
		return false
	if currently_playing.has(ref.instance_id) and ref.last_play:
		return ref.last_play.stream_state == StreamState.Playing
	return false

func erase_ref(ref:AudioRef)->void:
	if ref and currently_playing.has(ref.instance_id):
		currently_playing.erase(ref.instance_id)

func clear():
	stop_all()
	for clip in currently_playing:
		currently_playing.erase(clip)



func schedule_clip(clip_path:String,result:RefResult)->void:
	var token = GodautdioUtils.generate_id(16)#generate temp token to cancel audio from playing after timer timeout
	
	result.stream_state = StreamState.Queued
	var clip:AudioClip = audio_library.clips_dict[clip_path]
	currently_playing[result.instance_id][PLAY_QUEUE_TOKEN] = str(token)
	var instance = currently_playing[result.instance_id][STREAM_PLAYER_INSTANCE]
	instance.stop()
	var delay = currently_playing[result.instance_id][CLIP_DELAY]
	if delay > 0:
		await get_tree().create_timer(delay).timeout
		
	#check if the token is still the same if not means it was canceled 
	if currently_playing[result.instance_id][PLAY_QUEUE_TOKEN] != str(token):
		GodautdioUtils.log("schedule canceled")
		return
	instance.play()
	result.stream_state = StreamState.Playing
	await instance.finished
	result.stream_state = StreamState.Finished
	


func set_clip_loops(instance_id:String,loops:int)->void:
	if currently_playing.has(instance_id):
		currently_playing[instance_id][CLIP_LOOPS] = loops
		GodautdioUtils.log("Loops Set To: " + str(loops) + " For: "+ str(instance_id))

func set_clip_delay(instance_id:String,delay:float,result:RefResult)->void:
	if currently_playing.has(instance_id):
		currently_playing[instance_id][CLIP_DELAY] = delay
		currently_playing[instance_id][PLAY_QUEUE_TOKEN] = ""
		
		var clip_path = currently_playing[instance_id][CURRENT_CLIP_ID]
		schedule_clip(clip_path,result)


func on_instance_finish(instance:AudioInstance)->void:
	GodautdioUtils.log("Finished: "+ str(instance.instance_id))
	_log_current()
	if currently_playing.has(instance.instance_id):
		currently_playing.erase(instance.instance_id)
	_log_current()

func set_instance_position(target_position:Vector3,space:AudioClip.ClipSpaceType,instance:AudioInstance)->AudioInstance:
	var position_2d = Vector2(target_position.x,target_position.y)
	match space:
		AudioClip.ClipSpaceType.Is2DSpace:
			instance.global_position = position_2d
		AudioClip.ClipSpaceType.Is3DSpace:
			instance.global_position = target_position
	return instance


#region HELPERS
func _log_current():
	GodautdioUtils.log(currently_playing)
	
func _on_finish_setup(clip:AudioClip,free_on_finish:bool,instance:AudioInstance)->void:
	#infinite looping
	if currently_playing[instance.instance_id][CLIP_LOOPS]  == -1:
		instance.play()
		return
	#loops count
	if currently_playing[instance.instance_id][CLIP_LOOPS] > 0:
		currently_playing[instance.instance_id][CLIP_LOOPS] -= 1
		instance.play()
		return
	if free_on_finish :
		on_instance_finish(instance)
		instance.queue_free()

func _clamp_volume01(volume)->float:
	volume = clamp(volume,0,1)
	if volume > 0:
		volume = 45.0 * log(volume) / log(10)
	else:
		volume -=144.0
	return volume

func set_bus_volume(volume:float,bus_name:String)->void:
	if volume == null:
		return
	var value = _clamp_volume01(volume)
	var bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index,value)
	
func create_new_instance(clip:AudioClip,parent:Node)->AudioInstance:
	
	var script = load("res://addons/Godautdio/Scripts/AudioInstance.gd")
	var instance:AudioInstance
	
	match clip.clip_space_type:
		AudioClip.ClipSpaceType.NonePositional:
			var stream_player = AudioStreamPlayer.new()
			stream_player.set_script(script)
			instance = stream_player as AudioInstance
		AudioClip.ClipSpaceType.Is2DSpace:
			var stream_player_2d = AudioStreamPlayer2D.new()
			stream_player_2d.set_script(script)
			instance = stream_player_2d as AudioInstance
		AudioClip.ClipSpaceType.Is3DSpace:
			var stream_player_3d = AudioStreamPlayer3D.new()
			stream_player_3d.set_script(script)
			instance = stream_player_3d as AudioInstance
			
	instance = setup_audio_instance(clip,instance)
	
	currently_playing[instance.instance_id] = {}
	currently_playing[instance.instance_id][STREAM_PLAYER_INSTANCE] = instance
	currently_playing[instance.instance_id][CURRENT_CLIP_ID] = clip.clip_path
	currently_playing[instance.instance_id][CLIP_LOOPS] =-1 if clip.params.looping else 0
	currently_playing[instance.instance_id][PLAY_QUEUE_TOKEN] = ""
	currently_playing[instance.instance_id][CLIP_DELAY] = clip.params.delay
	parent.add_child(instance)
	return instance


func setup_audio_instance(clip:AudioClip,instance:AudioInstance)->AudioInstance:
	var id = GodautdioUtils.generate_id()
	
	match clip.clip_space_type:
		AudioClip.ClipSpaceType.Is2DSpace:
			instance.max_distance = clip.params.max_distance2D
			
		AudioClip.ClipSpaceType.Is3DSpace:
			instance.max_distance = clip.params.max_distance3D
#		AudioClip.ClipSpaceType.NonePositional:

	var stream = clip.clip_stream
	
	instance.set_stream(stream)
	instance.volume_db = clip.params.volume_db
	instance.pitch_scale = clip.params.pitch_scale
	instance.instance_id = id
	instance.bus = AudioServer.get_bus_name(clip.bus_index)
	return instance


#endregion 
enum StreamState {Queued,Puased,Playing,Finished,Stopped,NotFound}
class RefResult:
	var audio_instance:Node
	@export var instance_id:String
	@export var stream_state:StreamState
	
	func set_loops(loops:int)->RefResult:
		Godautdio.set_clip_loops(instance_id,loops)
		return self
	func set_delay(dalay:float)->RefResult:
		Godautdio.set_clip_delay(instance_id,dalay,self)
		GodautdioUtils.log("Delay Set To: " + str(dalay) + " For: "+ str(instance_id))
		return self
	func stop()->RefResult:
		Godautdio.stop_ref(instance_id)
		return self

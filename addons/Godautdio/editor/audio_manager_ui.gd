@tool
extends Control
#class_name AudioManagerUI


#Resources
@onready var multi_stream_field = preload("res://addons/Godautdio/Nodes/stream_field.tscn")
@onready var clips_container:AudioLibrary = preload("res://addons/Godautdio/Resources/AudioLib.tres")

#tabs
@onready var tab_bar:TabBar = $BoxContainer/header/container/TabBar
@onready var sound_container = $BoxContainer/SoundContainer
@onready var settings_contianer = $BoxContainer/SettingsContianer



#audio clip inputs
@onready var name_line_edit = $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/nameFieldContainer/nameLineEdit
@onready var stream_type_button:OptionButton = $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/nameFieldContainer/streamTypeButton
@onready var bus_option_button:OptionButton = $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/busFieldContainer/busOptionButton
@onready var clip_type_option_button:OptionButton =$BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/ClipTypeContainer/clipTypeOptionButton
@onready var playback_mod_option_button:OptionButton = $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/clipFieldContainer/header/playbackModContainer/playbackModOptionButton





#containers 
@onready var single_stream_field:StreamField = $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/clipFieldContainer/header/SingleStreamField
@onready var streams_array_container = $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/clipFieldContainer/StreamsArrayContainer
@onready var streams_grid_container:GridContainer = $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/clipFieldContainer/StreamsArrayContainer/StreamsScrollContainer/PanelContainer/MarginContainer/StreamsGridContainer
@onready var add_stream_btn = $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/clipFieldContainer/StreamsArrayContainer/AddStreamBtn
@onready var playback_mod_container = $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/clipFieldContainer/header/playbackModContainer



##params inputs 
@onready var looping_checkbox:CheckBox = $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/more/loopingCheckbox
@onready var delay_input:SpinBox = $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/more/delayInput
#Volume
@onready var vol_slider:HSlider = $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/VBoxContainer/VolumeContainer/Content/HFlowContainer2/volSlider
@onready var max_vol_box:SpinBox =$BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/VBoxContainer/VolumeContainer/Content/HFlowContainer2/maxVolBox
@onready var rand_vol_slider:HSlider = $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/RandVolContainer/HFlowContainer2/randVolSlider
@onready var rand_vol_box:SpinBox = $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/RandVolContainer/HFlowContainer2/randVolBox
#Pitch
@onready var pitch_slider:HSlider = $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/VBoxContainer/PitchContainer/Content/HFlowContainer2/pitchSlider
@onready var max_pitch_box:SpinBox = $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/VBoxContainer/PitchContainer/Content/HFlowContainer2/maxPitchBox
@onready var rand_pitch_slider:HSlider = $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/RandPitchContainer/HFlowContainer2/randPitchSlider
@onready var rand_pitch_box:SpinBox= $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/RandPitchContainer/HFlowContainer2/randPitchBox
#max distance
@onready var max_dis_2d_box:SpinBox = $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/VBoxContainer/MaxDisranceContainer/Content/HFlowContainer2/maxDis2DBox
@onready var max_dis_3d_box:SpinBox = $BoxContainer/SoundContainer/AudioSettingRect/MarginContainer/VBoxContainer/VBoxContainer/MaxDisranceContainer/Content/HFlowContainer2/maxDis3DBox



#main window
@onready var search_input:LineEdit = $BoxContainer/SoundContainer/AudioListRect/VBoxContainer/HBoxContainer/searchInput
@onready var sounds_tree:Tree = $BoxContainer/SoundContainer/AudioListRect/VBoxContainer/soundClipsTree


#popups

@onready var clip_file_open_dailogue:FileDialog = $OpenClipFileDialog
@onready var warning_popup:AcceptDialog = $warningPopup
@onready var context_menu = $contextMenu
@onready var confirmation_dialog = $ConfirmationDialog


#
var root:TreeItem
var regex = RegEx.new()
var selectedClip:AudioClip
var search_filter:String
var clips_dict:Dictionary = {}
var current_filter:String = ""

func _ready():
	sounds_tree.item_selected.connect(_on_item_selected)
	tab_bar.tab_changed.connect(func(index):
		sound_container.visible = index == 0
		settings_contianer.visible = index == 1)
	
	search_input.text_changed.connect(on_search_filter)
	#clip settings 
	name_line_edit.text_changed.connect(func(value): selectedClip.clip_path = value)
	clip_type_option_button.item_selected.connect(_on_clip_type_changed)
	bus_option_button.item_selected.connect(func(value): selectedClip.bus_index  = value)
	stream_type_button.item_selected.connect(_on_stream_type_change)
	playback_mod_option_button.item_selected.connect(func(value): selectedClip.clip_stream.playback_mode = value)
	#params
	looping_checkbox.toggled.connect(func(value): selectedClip.params.looping = value)
	delay_input.value_changed.connect(func(value): selectedClip.params.delay = value)
	
	rand_vol_slider.value_changed.connect(func(value): 
		rand_vol_box.set_value_no_signal(value)
		selectedClip.clip_stream.random_volume_offset_db = value)
	rand_vol_box.value_changed.connect(func(value): 
		rand_vol_slider.set_value_no_signal(value)
		selectedClip.clip_stream.random_volume_offset_db = value)
	rand_pitch_slider.value_changed.connect(func(value): 
		rand_pitch_box.set_value_no_signal(value)
		selectedClip.clip_stream.random_pitch = value)
	rand_pitch_box.value_changed.connect(func(value): 
		rand_pitch_slider.set_value_no_signal(value)
		selectedClip.clip_stream.random_pitch = value)
	vol_slider.value_changed.connect(func(value): 
		max_vol_box.set_value_no_signal(value)
		selectedClip.params.volume_db = value)
	max_vol_box.value_changed.connect(func(value): 
		vol_slider.set_value_no_signal(value)
		selectedClip.params.volume_db = value)
	pitch_slider.value_changed.connect(func(value): 
		max_pitch_box.set_value_no_signal(value)
		selectedClip.params.pitch_scale = value)
	max_pitch_box.value_changed.connect(func(value): 
		pitch_slider.set_value_no_signal(value)
		selectedClip.params.pitch_scale = value)
	max_dis_2d_box.value_changed.connect(func(value): selectedClip.params.max_distance2D = value)
	max_dis_3d_box.value_changed.connect(func(value): selectedClip.params.max_distance3D = value)

	
	
	refresh_view()
	preview_clip(AudioClip.new())
	



func _on_draw():
	refresh_view()
	preview_clip(selectedClip)


func on_search_filter(filter:String)->void:
	current_filter = filter
	refresh_tree_view()

func _on_tab_changed(index:int)->void:
	sound_container.visible = true if index == 0 else false
	settings_contianer.visible = true if index == 0 else false


func _on_clip_type_changed(index:int)->void:
	match index:
		0:
			selectedClip.clip_space_type = AudioClip.ClipSpaceType.Is2DSpace
		1:
			selectedClip.clip_space_type = AudioClip.ClipSpaceType.Is3DSpace
		2:
			selectedClip.clip_space_type = AudioClip.ClipSpaceType.NonePositional


func _on_stream_type_change(value:int)->void:
	var type = AudioClip.StreamType.Single if value == 0 else AudioClip.StreamType.RandomStream
	selectedClip.stream_type = type
	refresh_stream_fields()



func _on_item_selected()->void:
	var selected = sounds_tree.get_selected()
	var meta = selected.get_metadata(0)
	if meta:
		var clip = clips_dict[meta] as AudioClip
		preview_clip(clip)


func on_file_open()->void:
	clip_file_open_dailogue.popup()


func on_multi_file_dropped(file:String)->void:
	var index = selectedClip.clip_stream.streams_count
	on_stream_file_dropped(index,file)
	refresh_stream_fields()
	


func on_stream_file_dropped(index:int , file:String)->void:
	var stream_file = load(file)
	if stream_file:
		if selectedClip.stream_type == AudioClip.StreamType.Single:
			selectedClip.clip_stream.set_stream(0,stream_file)
		else:
			if index == selectedClip.clip_stream.streams_count:
				selectedClip.clip_stream.add_stream(index,stream_file)
			else:
				selectedClip.clip_stream.set_stream(index,stream_file)


func on_stream_element_deleted(index:int)->void:
	if index == 0 and selectedClip.clip_stream.streams_count == 1:
		return
	if selectedClip.stream_type == AudioClip.StreamType.RandomStream: 
		selectedClip.clip_stream.remove_stream(index)
	else:
		selectedClip.clip_stream.remove_stream(index)
	refresh_stream_fields()


func on_stream_weight_changed(index:int , value:float)->void:
	if selectedClip.stream_type == AudioClip.StreamType.RandomStream: 
		selectedClip.clip_stream.set_stream_probability_weight(index,value)
	refresh_stream_fields()


func on_add_stream_element()->void:
	if selectedClip.stream_type == AudioClip.StreamType.RandomStream: 
		var count = selectedClip.clip_stream.streams_count
		selectedClip.clip_stream.add_stream(count,null,1.0)
	refresh_stream_fields()




func _on_create_new_btn_pressed()->void:
	var newClip = AudioClip.new()
	preview_clip(newClip)
	name_line_edit.grab_focus()



func show_warning_dialog(msg:String,titel:String = "Warning!")->void:
	warning_popup.title = titel
	warning_popup.dialog_text = msg
	warning_popup.show()

func refresh_view()->void:
	for clip in clips_container.audio_clips:
			clips_dict[clip.clip_path] = clip
	refresh_tree_view()
	
	bus_option_button.clear()

	for bus_index in AudioServer.bus_count:
		bus_option_button.add_item(AudioServer.get_bus_name(bus_index))

func refresh_tree_view()->void:
	sounds_tree.clear()
	root = sounds_tree.create_item()
	sounds_tree.hide_root = true
	var paths = clips_container.audio_clips.map(func(clip:AudioClip): return clip.clip_path)
	var path_icons = {}
	for path in paths:
		path_icons[path]={}
		path_icons[path]["type"] = clips_container.clips_dict[path].clip_space_type
	var tree_dict = GodautdioUtils.path_list_to_tree_dict(paths,current_filter)
	GodautdioUtils.create_tree_from_dict(tree_dict,sounds_tree,root,path_icons)


func refresh_stream_fields()->void:
	var type = selectedClip.stream_type if selectedClip else AudioClip.StreamType.Single
	
	add_stream_btn.visible = type ==  AudioClip.StreamType.RandomStream
	streams_array_container.visible = type ==  AudioClip.StreamType.RandomStream
	playback_mod_container.visible  = type ==  AudioClip.StreamType.RandomStream
	
	single_stream_field.visible = type ==  AudioClip.StreamType.Single
	
	
	for child in streams_grid_container.get_children(): child.queue_free()
	var stream_count = selectedClip.clip_stream.streams_count
	match type:
		AudioClip.StreamType.Single:
			if stream_count == 0:
				selectedClip.clip_stream.add_stream(0,null)
			else:
				var index = 0
				for i in stream_count:
					if index == 0:
						index =+1
						continue#skip first item remove rest
					selectedClip.clip_stream.remove_stream(index)
					index =+1
				
			single_stream_field.set_value(selectedClip.clip_stream.get_stream(0),1,0,self);
		AudioClip.StreamType.RandomStream:
			for index in stream_count:
				var stream = selectedClip.clip_stream.get_stream(index)
				var weight = selectedClip.clip_stream.get_stream_probability_weight(index)
				var multi_stream = multi_stream_field.instantiate() as StreamField
				multi_stream.set_value(stream,weight,index,self);
				index = index+1
				streams_grid_container.add_child(multi_stream)
				

func preview_clip(clip:AudioClip)->void:
	
	selectedClip = clip.duplicate()
	selectedClip.clip_stream = clip.clip_stream.duplicate()
	
	name_line_edit.text = selectedClip.clip_path if selectedClip else ""
	bus_option_button.select(selectedClip.bus_index if selectedClip else 0)
	playback_mod_option_button.select(selectedClip.clip_stream.playback_mode)
	var clip_type = selectedClip.clip_space_type
	
	stream_type_button.select(selectedClip.stream_type)
	clip_type_option_button.select(clip_type if selectedClip else 0)
	looping_checkbox.set_pressed_no_signal(selectedClip.params.looping if selectedClip else false)
	delay_input.set_value_no_signal(selectedClip.params.delay if selectedClip else 0.0)

	#volume
	vol_slider.set_value_no_signal(selectedClip.params.volume_db if selectedClip else 0.0)
	max_vol_box.set_value_no_signal(selectedClip.params.volume_db if selectedClip else 0.0)
	rand_vol_slider.set_value_no_signal(selectedClip.clip_stream.random_volume_offset_db if selectedClip else 0.0)
	rand_vol_box.set_value_no_signal(selectedClip.clip_stream.random_volume_offset_db if selectedClip else 0.0)
	#pitch
	pitch_slider.set_value_no_signal(selectedClip.params.pitch_scale if selectedClip else 1)
	max_pitch_box.set_value_no_signal(selectedClip.params.pitch_scale if selectedClip else 1)
	rand_pitch_slider.set_value_no_signal(selectedClip.clip_stream.random_pitch if selectedClip else 0.0)
	rand_pitch_box.set_value_no_signal(selectedClip.clip_stream.random_pitch if selectedClip else 0.0)
	#max distance
	max_dis_2d_box.set_value_no_signal(selectedClip.params.max_distance2D)
	max_dis_3d_box.set_value_no_signal(selectedClip.params.max_distance3D)
	
	refresh_stream_fields()


func _on_save_btn_pressed()->void:
	if not save():
		return
		
	refresh_view()
	preview_clip(selectedClip.duplicate())


func save(force:bool = false)-> bool:
	
	if not force:
		if selectedClip.clip_path == "":
			show_warning_dialog("Name is required before saving.")
			return false
		if selectedClip.clip_stream.streams_count == 0:
			show_warning_dialog("select at least one stream file before saving.")
			return false
		selectedClip.clip_stream = selectedClip.clip_stream.duplicate()
		selectedClip.params = selectedClip.params.duplicate()
		clips_dict[selectedClip.clip_path] = selectedClip.duplicate()
		
	clips_container.clips_dict = clips_dict
	var clips_array:Array[AudioClip]
	for clip in clips_dict.values():
		clips_array.append(clip)
	clips_container.audio_clips = clips_array
	ResourceSaver.save(clips_container)
	Godautdio.reload_db()
	return true

func _on_delete_btn_pressed()->void:
	clips_dict.erase(selectedClip.clip_path)
	save(true)
	refresh_view()
	preview_clip(AudioClip.new())
	



func _on_sound_clips_tree_item_mouse_selected(click_position, mouse_button_index):
	GodautdioUtils.log("pressed: {0} at {1}".format({"0":mouse_button_index,"1":click_position}))
	if not mouse_button_index == 2:
		return

	context_menu.clear()
	context_menu.position = click_position
	context_menu.add_item("YES")
	context_menu.add_separator()
	context_menu.add_item("Delete")
	context_menu.reset_size()
	
	context_menu.show()
	GodautdioUtils.log(context_menu.position)


func _on_ply_btn_pressed():
	Godautdio.editor_clip_preivew(selectedClip)

func _on_stp_btn_pressed():
	Godautdio.stop_editor_preivew()



func _on_clear_all_pressed():
	var mouse_pos = get_global_mouse_position()
	confirmation_dialog.title = "CLEAR ALL"
	confirmation_dialog.dialog_text ="Warning: Deleting all items will permanently remove all data.\nAre you sure you want to proceed?"
	confirmation_dialog.ok_button_text = "YES"
	confirmation_dialog.cancel_button_text = "NO"
#	confirmation_dialog.position = mouse_pos
	confirmation_dialog.show()
	
	



func _on_clear_all_confiremd():
	clips_container.audio_clips = []
	clips_container.clips_dict = {}
	clips_dict = {}
	ResourceSaver.save(clips_container)
	Godautdio.reload_db()
	refresh_view()
	preview_clip(AudioClip.new())
	

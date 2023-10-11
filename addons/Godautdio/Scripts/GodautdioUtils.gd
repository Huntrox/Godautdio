extends Node
class_name GodautdioUtils


const DEBUG:bool = true

static func log(msg):
	if not DEBUG:
		return
	print(msg)
	
static func log_err(msg):
	if not DEBUG:
		return
	printerr(msg)

static func log_warn(msg):
	if not DEBUG:
		return
	push_warning(msg)

	
static func create_tree_from_dict(tree_dict:Dictionary,target_tree:Tree,tree_root:TreeItem,path_icons:Dictionary)->void:
	
	var folder_ico = preload("res://addons/Godautdio/icons/Folder.svg")
	var icos = [preload("res://addons/Godautdio/icons/AudioStreamPlayer.svg"),
				preload("res://addons/Godautdio/icons/AudioStreamPlayer2D.svg"),
				preload("res://addons/Godautdio/icons/AudioStreamPlayer3D.svg")]
				
					
	for tag in tree_dict:
		var section_item = target_tree.create_item(tree_root)
		if typeof(tree_dict[tag]) == TYPE_ARRAY:
			section_item.set_text(0,tag)
			section_item.set_icon(0,folder_ico)
			for item_title in tree_dict[tag]:
				var full_path = "{0}/{1}".format({"0":tag,"1":item_title})
				var icon_indx = path_icons[full_path]["type"]
				var tree_item = target_tree.create_item(section_item)
				tree_item.set_text(0,item_title)
				tree_item.set_icon(0,icos[icon_indx])
				tree_item.set_metadata(0,full_path)
				tree_item.set_tooltip_text(0,full_path)
				
		else:
			var icon_indx = path_icons[tag]["type"]
			section_item.set_text(0,tag)
			section_item.set_tooltip_text(0,tag)
			section_item.set_icon(0,icos[icon_indx])
			section_item.set_metadata(0,tag)

static func path_list_to_tree_dict(path_list:Array,filter:String = "")->Dictionary:
	var tree = {}
	var regex = RegEx.new()
	regex.compile("(.+)/")
	for path in path_list:
		if not filter.is_empty() and not filter.to_lower() in path.to_lower():
			continue
		var sections = path.split("/")
		
		var last_item = sections[sections.size() - 1] if sections.size() != 0 else path
		var result = regex.search(path)
		if result:
			var str = result.get_string()
			var tag = str.substr(0,str.length() - 1)
			if not tree.has(tag):
				tree[tag] = []
			tree[tag].append(last_item)
		elif sections.size() == 1:
			tree[path] = path
			
	return tree
	
	
static func generate_id(length: int = 32,dashed:bool = true) -> String:
	var characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	var guid_chars = []

	# Calculate characters length only once
	var characters_length = characters.length()

	for i in range(length):
		guid_chars.append(characters[randi() % characters_length])
	
	if length == 32 and dashed: # If the length is 36, format it as a standard GUID
		guid_chars.insert(8, "-")
		guid_chars.insert(13, "-")
		guid_chars.insert(18, "-")
		guid_chars.insert(23, "-")
		return ''.join(guid_chars)
		
	elif length > 4 and dashed:
		var dash_count = length / 8
		var dash_interval = length / dash_count
		var dash_position = dash_interval

		while dash_position < length:
			guid_chars.insert(int(dash_position), "-")
			dash_position += dash_interval
	return ''.join(guid_chars)

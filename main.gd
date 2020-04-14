extends Spatial

var ended_level = null
var current_level = null

func _ready():
	next_level()

func next_level():
	
	var next_level = levels.get_next_level()
	ended_level = current_level
	
	if next_level == "":
		return
	
	current_level = load(next_level).instance()
	
	if levels.current_level == 0:
		load_level(null)
		$Block.start_point = get_node(str(get_path_to(current_level)) + "/Start").translation
		$Block._on_RespawnTimer_timeout(null)
	else:
		var timer_node = get_node(str(get_path_to($Block)) + "/RespawnTimer")
		timer_node.connect("timeout", self, "load_level", [timer_node])
		timer_node.connect("timeout", $Block, "_on_RespawnTimer_timeout", [timer_node])
		timer_node.wait_time = 1
		timer_node.one_shot = true
		timer_node.start()
	
func load_level(timer_node):
	
	if ended_level != null:
		ended_level.queue_free()
	
	add_child(current_level)
	$Block.start_point = get_node(str(get_path_to(current_level)) + "/Start").translation
	$Light.translation = get_node(str(get_path_to(current_level)) + "/Ending").translation + Vector3(0, 1, 0)
	
	if timer_node != null:
		timer_node.disconnect("timeout", self, "load_level")

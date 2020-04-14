extends Control

var rotations_count = 0
var rotations_counter

func _ready():
	
	var block = get_node(str(get_path_to(get_tree().root)) + "/Spatial/Block")
	rotations_counter = $MarginContainer/RotationsCounter
	
	redraw_rotations_counter()
	
	block.connect("block_respawned", self, "clear")
	block.connect("block_rotated", self, "add")
	levels.connect("levels_ended", self, "show_game_completed_dialogue")

func redraw_rotations_counter():
	rotations_counter.text = "Rotations count: " + str(rotations_count)

func add():
	rotations_count += 1
	redraw_rotations_counter()

func clear():
	rotations_count = 0
	redraw_rotations_counter()

func show_game_completed_dialogue():
	$GameCompletedDialogue.show()

func _input(event):
	if event.is_action("ui_cancel"):
		get_tree().quit()
	elif levels.levels_ended and event.is_action("ui_accept"):
		get_tree().quit()
extends Area

const BlockClass = preload("res://block.gd")

func _on_Ending_body_entered( body ):
	var block = body.get_parent()
	if block.is_in_group("player") and block.orientation_before_animation == BlockClass.Orientation.Y and !block.won:
		block.won = true
		$GravityTimer.connect("timeout", self, "_on_GravityTimer_timeout", [block, body ])
		$GravityTimer.wait_time = block.movement_duration
		$GravityTimer.one_shot = true
		$GravityTimer.start()

func _on_GravityTimer_timeout(block, body):
	body.sleeping = false
	block.win()
	$GravityTimer.disconnect("timeout", self, "_on_GravityTimer_timeout")

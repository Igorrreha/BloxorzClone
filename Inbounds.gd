extends Area

func _on_Inbounds_area_exited( area ):
	var body = area.get_parent()
	var parent = body.get_parent()
	if parent.is_in_group("player"):
		parent.lose()

extends Area

export var tag = ""
export var is_active = false
export var tween_duration = 1.0

func _ready():
	$CollisionShape.disabled = is_active

func set_active():
	is_active = true
	$Timer.wait_time = tween_duration
	$Timer.start()

func set_unactive():
	is_active = false
	$Timer.wait_time = tween_duration
	$Timer.start()

func _on_Timer_timeout():
	$CollisionShape.disabled = is_active

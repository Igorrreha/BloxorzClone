extends MeshInstance

export var tag = ""
export var is_active = false

export var tween_translation = Vector3(0, 3, 0)
export var tween_duration = 1.0
export var tween_delay = 0.0

func _ready():
	if is_active:
		set_active(true)
	else:
		set_unactive(true)

func set_active(set_immediately = false):
	if set_immediately:
		translation += tween_translation
	else:
		$Tween.interpolate_property(self, "translation", translation, translation + tween_translation, tween_duration,
				Tween.TRANS_LINEAR, Tween.EASE_IN, tween_delay)
		$Tween.start()

func set_unactive(set_immediately = false):
	if set_immediately:
		translation -= tween_translation
	else:
		$Tween.interpolate_property(self, "translation", translation, translation - tween_translation, tween_duration,
				Tween.TRANS_LINEAR, Tween.EASE_IN, tween_delay)
		$Tween.start()

extends MeshInstance

signal button_pressed
signal button_released

export var tag = ""
export var is_pressed = false
var active_material = preload("res://materials/active_button.tres")
var unactive_material = preload("res://materials/unactive_button.tres")

func _ready():
	set_unactive()

func set_pressed():
	is_pressed = true
	material_override = active_material
	
	translation -= Vector3(0, 0.09, 0)
	emit_signal("button_pressed")

func set_unactive():
	mesh.material = unactive_material
	emit_signal("button_pressed")

func _on_Area_area_entered(area):
	if area.is_in_group("player_body_area"):
		if !is_pressed:
			set_pressed()

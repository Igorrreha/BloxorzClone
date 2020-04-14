extends Spatial

func _ready():
	connect_buttons_to_mecha()

func connect_buttons_to_mecha():
	for button in $GridMap/Buttons.get_children():
		for mecha in $GridMap/Mechanisms.get_children():
			if button.tag == mecha.tag:
				button.connect("button_pressed", mecha, "set_active")
				button.connect("button_released", mecha, "set_unactive")

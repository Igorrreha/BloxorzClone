extends Spatial

enum Direction { UP, DOWN, RIGHT, LEFT }
enum Orientation { X, Y, Z }

signal block_respawned
signal block_rotated

var orientation = Orientation.Y
var orientation_before_animation = Orientation.Y
var rotation_direction = null

var is_turning = false
var is_animation_started = false
var interpolation = 0
var movement_duration = 0.2
var won = false
var lost = false
var respawning = false

var preadjusted_shift = Vector3(0, 0, 0)
var start_point = Vector3(0, 0, 0)

var Shifts = { 
	"XTOX": Vector3(0, 0, 1),
	"XTOY": Vector3(1.5, 0.5, 0),
	"ZTOZ": Vector3(1, 0, 0),
	"ZTOY": Vector3(0, 0.5, 1.5)
}

var RotationShifts = {
	"XTOX": Vector3(0, -0.5, 0.5),
	"XTOY": Vector3(1, -0.5, 0),
	"ZTOZ": Vector3(0.5, -0.5, 0),
	"ZTOY": Vector3(0, -0.5, 1),
	"YTOX": Vector3(0.5, -1, 0),
	"YTOZ": Vector3(0, -1, 0.5)
}


func _physics_process(delta):

	if is_animation_started:
		var step = (delta / movement_duration)
		var angle = (PI / 2.0) * step
		var body = $RigidBody
		match rotation_direction:
			Direction.LEFT: 
				body.transform = body.transform.rotated(Vector3(0, 0, 1), angle)
			Direction.RIGHT:
				body.transform = body.transform.rotated(Vector3(0, 0, -1), angle)
			Direction.UP:
				body.transform = body.transform.rotated(Vector3(-1, 0, 0), angle)
			Direction.DOWN:
				body.transform = body.transform.rotated(Vector3(1, 0, 0), angle)
		
		interpolation += step
		if interpolation > 1:
			is_turning = false
			interpolation = 0
			adjust_shifts()
			orientation = orientation_before_animation
			is_animation_started = false
			
			emit_signal("block_rotated")

func _input(event):
	if event.is_action_pressed('player_left'):
		start_turning(Direction.LEFT)
	elif event.is_action_pressed('player_right'):
		start_turning(Direction.RIGHT)
	elif event.is_action_pressed('player_up'):
		start_turning(Direction.UP)
	elif event.is_action_pressed('player_down'):
		start_turning(Direction.DOWN)
	
	# Управление свайпами
	elif event is InputEventScreenDrag:
		var drag_dir = event.relative
		drag_dir = drag_dir.rotated(PI/5)
		
		if drag_dir.x < -20:
			start_turning(Direction.LEFT)
		elif drag_dir.x > 20:
			start_turning(Direction.RIGHT)
		elif drag_dir.y < -20:
			start_turning(Direction.UP)
		elif drag_dir.y > 20:
			start_turning(Direction.DOWN)

func start_turning(dir):
	# Проверка доступности управления
	if is_turning or respawning or won or lost or interpolation != 0 or not $GravityTimer.is_stopped():
		return
	is_turning = true
	
	# Запись направления вращения
	rotation_direction = dir
	
	calculate_orientation_before_animation()
	
	adjust_rotation_shifts()
	is_animation_started = true

func adjust_rotation_shifts():
	
	var shift = Vector3()
	
	match orientation:
		Orientation.X:
			match rotation_direction:
				Direction.LEFT:
					shift = RotationShifts.XTOY * Vector3(-1, 1, 0)
				Direction.RIGHT:
					shift = RotationShifts.XTOY
				Direction.UP:
					shift = RotationShifts.XTOX * Vector3(0, 1, -1)
				Direction.DOWN:
					shift = RotationShifts.XTOX
		Orientation.Y:
			match rotation_direction:
				Direction.LEFT:
					shift = RotationShifts.YTOX * Vector3(-1, 1, 0)
				Direction.RIGHT:
					shift = RotationShifts.YTOX
				Direction.UP:
					shift = RotationShifts.YTOZ * Vector3(0, 1, -1)
				Direction.DOWN:
					shift = RotationShifts.YTOZ
		Orientation.Z:
			match rotation_direction:
				Direction.LEFT:
					shift = RotationShifts.ZTOZ * Vector3(-1, 1, 0)
				Direction.RIGHT:
					shift = RotationShifts.ZTOZ
				Direction.UP:
					shift = RotationShifts.ZTOY * Vector3(0, 1, -1)
				Direction.DOWN:
					shift = RotationShifts.ZTOY
	
	preadjusted_shift = translation
	
	translation += shift
	# Центр вращения объекта - середина отрезка между собственной осью и осью родителя
	$RigidBody.translation = shift * Vector3(-2, -2, -2) 
	

func adjust_shifts():
	
	var shift = Vector3()
	
	match orientation:
		Orientation.X:
			match rotation_direction:
				Direction.LEFT:
					shift = Shifts.XTOY * Vector3(-1, 1, 0)
				Direction.RIGHT:
					shift = Shifts.XTOY
				Direction.UP:
					shift = Shifts.XTOX * Vector3(0, 1, -1)
				Direction.DOWN:
					shift = Shifts.XTOX
		Orientation.Y:
			match rotation_direction:
				Direction.LEFT:
					shift = Shifts.XTOY * Vector3(-1, -1, 0)
				Direction.RIGHT:
					shift = Shifts.XTOY * Vector3(1, -1, 0)
				Direction.UP:
					shift = Shifts.ZTOY * Vector3(0, -1, -1)
				Direction.DOWN:
					shift = Shifts.ZTOY * Vector3(0, -1, 1)
		Orientation.Z:
			match rotation_direction:
				Direction.LEFT:
					shift = Shifts.ZTOZ * Vector3(-1, 1, 0)
				Direction.RIGHT:
					shift = Shifts.ZTOZ
				Direction.UP:
					shift = Shifts.ZTOY * Vector3(0, 1, -1)
				Direction.DOWN:
					shift = Shifts.ZTOY
	
	$RigidBody.translation = Vector3(0, 0, 0)
	translation = preadjusted_shift + shift

func calculate_orientation_before_animation():
	if orientation == Orientation.X:
		match rotation_direction:
			Direction.LEFT, Direction.RIGHT:
				orientation_before_animation = Orientation.Y
	elif orientation == Orientation.Y:
		match rotation_direction:
			Direction.LEFT, Direction.RIGHT:
				orientation_before_animation = Orientation.X
			Direction.UP, Direction.DOWN:
				orientation_before_animation = Orientation.Z
	elif orientation == Orientation.Z:
		match rotation_direction:
			Direction.UP, Direction.DOWN:
				orientation_before_animation = Orientation.Y

func respawn():
	$RigidBody.sleeping = true
	respawning = true
	orientation = Orientation.Y
	orientation_before_animation = Orientation.Y
	rotation_direction = null
	is_turning = false
	is_animation_started = false
	interpolation = 0
	won = false
	lost = false
	
	translation = start_point + Vector3(0, 1, 0)
	$RigidBody.translation = Vector3(0, 0, 0)
	$RigidBody.rotation = Vector3(0, 0, 0)
	respawning = false
	
	emit_signal("block_respawned")

func _on_RespawnTimer_timeout(timer_node):
	respawn()
	if timer_node != null:
		timer_node.disconnect("timeout", self, "_on_RespawnTimer_timeout")

func _on_Body_area_entered(area):
	if area.is_in_group("obstacle"):
		lose()

func win():
	get_parent().next_level()
	print("Level " + str(levels.current_level) + " completed")
	
	if levels.levels_ended:
		print("You win")

func lose():
	
	if won or respawning or lost:
		return
	
	$RigidBody.sleeping = false
	lost = true
	
	var timer_node = $RespawnTimer
	timer_node.connect("timeout", self, "_on_RespawnTimer_timeout", [timer_node])
	timer_node.wait_time = 1
	timer_node.one_shot = true
	timer_node.start()
	
	print("You lose")

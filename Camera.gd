extends Camera

const RAY_LENGTH = 1000
const ZOOM_STOP_THRESHOLD = 0.001

var zoom_direction: float = 0

# Zoom settings
export(float, 20, 100) var zoom_speed = 25
export(float, 0.5, 0.9) var zoom_speed_damp = 0.9
export(float) var min_zoom = -8.0
export(float) var max_zoom = 8.0
var reseting_zoom: bool = false
export(float, 0.01, 1) var zoom_reset_speed = 0.1

# Rotation Settings
export(float, 0.001, 0.01) var rotation_sensibility = 0.005
var reseting_rotation = false

export(NodePath) var gimbal_path
onready var gimbal = get_node(gimbal_path)

export(NodePath) var player_path
onready var player = get_node(player_path)

func _process(delta):
	_bind_zoom(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_zoom_in"):
		zoom_direction = -1
		reseting_zoom = false
	elif event.is_action_pressed("camera_zoom_out"):
		zoom_direction = 1
		reseting_zoom = false

	if event.is_action_pressed("camera_reset_zoom"):
		reseting_zoom = true

func _input(event: InputEvent) -> void:
	_bind_movement(event)
	_bind_rotation(event)

func _bind_zoom(delta: float) -> void:
	if zoom_direction == 0:
		pass

	var new_zoom: float

	if reseting_zoom:
		if abs(translation.z) <= 0.001:
			reseting_zoom = false
			zoom_direction = 0
			pass

		new_zoom = lerp(translation.z, 0, zoom_reset_speed)

		translation.z = new_zoom
	else:
		new_zoom = clamp(
			translation.z + zoom_speed * delta * zoom_direction,
			min_zoom,
			max_zoom
		)

		translation.z = new_zoom

		# Stop smoothly
		zoom_direction *= zoom_speed_damp

		# Stop once the threshold was reached
		if abs(zoom_direction) <= ZOOM_STOP_THRESHOLD:
			zoom_direction = 0

func _bind_movement(event: InputEvent) -> void:
	if event is InputEventMouseButton and Input.is_action_just_pressed("move"):
		var from = project_ray_origin(event.position)
		var to = from + project_ray_normal(event.position) * RAY_LENGTH
		var space_state = get_world().direct_space_state

		var result = space_state.intersect_ray(from, to, [], 1)

		if result:
			player.move_to(result.position)

func _bind_rotation(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("camera_rotate"):
		gimbal.global_rotate(Vector3.DOWN, event.relative.x * rotation_sensibility)

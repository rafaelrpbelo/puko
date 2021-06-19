extends Camera

signal interacting(collider)

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
export(float, 30, 300) var reset_rotation_speed: int = 200
export(float, 1, 5) var reset_rotation_threshold: int = 3
var reseting_rotation: bool = false

export(NodePath) var gimbal_path
onready var gimbal = get_node(gimbal_path)

export(NodePath) var player_path
onready var player = get_node(player_path)

func _process(delta):
	_bind_zoom(delta)
	_bind_rotation_reset(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_zoom_in"):
		zoom_direction = -1
		reseting_zoom = false
	elif event.is_action_pressed("camera_zoom_out"):
		zoom_direction = 1
		reseting_zoom = false

	if event.is_action_pressed("camera_reset_zoom"):
		reseting_zoom = true

	if event.is_action_pressed("camera_reset_rotation") and _can_reset_rotation():
		reseting_rotation = true

func _input(event: InputEvent) -> void:
	_bind_movement(event)
	_bind_rotation(event)

	if event is InputEventMouseButton and Input.is_action_just_pressed("interact"):
		var result = _get_space_object_from_ray(event.position)

		if "collider" in result:
			emit_signal("interacting", result.collider)

func _bind_zoom(delta: float) -> void:
	if zoom_direction == 0:
		return

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
		var result = _get_space_object_from_ray(event.position)

		if result:
			player.move_to(result.position)

func _bind_rotation(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("camera_rotate"):
		gimbal.global_rotate(Vector3.DOWN, event.relative.x * rotation_sensibility)

func _bind_rotation_reset(delta: float) -> void:
	if not reseting_rotation:
		return

	var rotation_direction: int

	if gimbal.rotation_degrees.y > 0:
		rotation_direction = 1
	else:
		rotation_direction = -1

	var rotation_factor = reset_rotation_speed * delta * rotation_direction
	gimbal.rotation_degrees.y -= rotation_factor

	if abs(gimbal.rotation_degrees.y) <= reset_rotation_threshold:
		gimbal.rotation_degrees.y = 0
		reseting_rotation = false

func _can_reset_rotation() -> bool:
	return gimbal.rotation_degrees.y != 0

func _get_space_object_from_ray(position: Vector2) -> PhysicsDirectSpaceState:
	var from = project_ray_origin(position)
	var to = from + project_ray_normal(position) * RAY_LENGTH
	var space_state = get_world().direct_space_state

	return space_state.intersect_ray(from, to, [], 1)

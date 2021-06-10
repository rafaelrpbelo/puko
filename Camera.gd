extends Camera

const RAY_LENGTH = 1000
const ZOOM_STOP_THRESHOLD = 0.001

var zoom_direction: float = 0

# Zoom settings
export(float, 20, 100) var zoom_speed = 25
export(float, 0.5, 0.9) var zoom_speed_damp = 0.9
export(float) var min_zoom = -8.0
export(float) var max_zoom = 8.0

func _process(delta):
	_bind_zoom(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_zoom_in"):
		zoom_direction = -1
	elif event.is_action_pressed("camera_zoom_out"):
		zoom_direction = 1

func _input(event: InputEvent) -> void:
	_bind_movement(event)

func _bind_zoom(delta: float) -> void:
	var new_zoom = clamp(
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
			get_tree().call_group("player", "move_to", result.position)

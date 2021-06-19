extends KinematicBody

var targets: Array = []
var path = []
var path_node = 0

export(float, 1, 10) var move_speed = 5

const point = Vector3(52, 12, 0)

onready var nav = get_parent()

func _physics_process(delta):
	if targets.size() > 0:
		move_to(targets[0].global_transform.origin)

	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)

		if direction.length() < 1:
			path_node += 1
		else:
			move_and_slide(direction.normalized() * move_speed, Vector3.UP)

func move_to(target_pos: Vector3):
	path = nav.get_simple_path(global_transform.origin, target_pos)

func _on_body_entered(body: Node) -> void:
	# FIXME: Improve. Should not use body.name
	if body is KinematicBody and body.name == "Player":
		# FIXME: Sort all targets to follow the nearest one
		targets.push_back(body)
		print("colliding with player")

func _on_body_exited(body):
	print("body exiting... ", body, " targets: ", targets)
	targets.remove(targets.find(body))
	print("targets: ", targets)

	if targets.size() == 0:
		path_node = 0
		path = []

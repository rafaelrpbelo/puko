extends KinematicBody

export(float, 1, 10) var move_speed = 3
export(NodePath) var navigation_path
export(float, 0.1, 5) var reaction_time = 1
export(bool) var aggressive = true

var targets: Array = []
var path = []
var path_node = 0

onready var nav = get_node(navigation_path) as Navigation
onready var timer: Timer = $Timer

func _ready():
	add_to_group("enemy")
	timer.wait_time = reaction_time

func _physics_process(delta):
	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)
		if direction.length() < 1:
			path_node += 1
		else:
			move_and_slide(direction.normalized() * move_speed, Vector3.UP)

func move_to(target_pos: Vector3):
	path_node = 0
	path = nav.get_simple_path(global_transform.origin, target_pos)

func _on_body_entered(body: Node) -> void:
	# FIXME: Improve. Should not use body.name
	if aggressive and body is KinematicBody and body.name == "Player":
		timer.start()

		# FIXME: Sort all targets to follow the nearest one
		targets.push_back(body)

func _on_body_exited(body):
	targets.remove(targets.find(body))

	if targets.size() == 0:
		path_node = 0
		path = []
		timer.stop()

func _on_timeout():
	print("timeout")
	if targets.size() > 0:
		move_to(targets[0].global_transform.origin)

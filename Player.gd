extends KinematicBody

export(float, 1, 10) var move_speed = 5
export(NodePath) var navigation_path = null

var path = []
var path_node = 0

var selected: Node

var enemies_on_range = []

onready var nav = get_node(navigation_path) as Navigation

func _physics_process(delta):
	_process_atack()

	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)

		if direction.length() < 1:
			path_node += 1
		else:
			move_and_slide(direction.normalized() * move_speed, Vector3.UP)

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

func _process_atack():
	if selected and enemies_on_range.find(selected) > -1:
		print("attacking...")

func _on_interacting(collider: Node) -> void:
	if collider.is_in_group("enemy"):
		selected = collider
		move_to(collider.global_transform.origin)
	else:
		selected = null

func _on_body_enter_to_attack_range(body: Node) -> void:
	# Filtering my targets
	if body.is_in_group("enemy"):
		enemies_on_range.push_back(body)
		path = []
		path_node = 0

func _on_body_leave_from_attack_range(body):
	enemies_on_range.remove(enemies_on_range.find(body))

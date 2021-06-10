extends KinematicBody

var path = []
var path_node = 0

const move_speed = 5

const point = Vector3(52, 12, 0)

onready var nav = get_parent()

func _ready():
	add_to_group("player")
	
func _physics_process(delta):
	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)
		
		if direction.length() < 1:
			path_node += 1
		else:
			move_and_slide(direction.normalized() * move_speed, Vector3.UP)

func move_to(target_pos):
	print("Player", "target_pos", target_pos)
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

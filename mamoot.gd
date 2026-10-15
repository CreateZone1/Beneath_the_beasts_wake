extends CharacterBody3D

@export var speed = 2.0
@export var agent: NavigationAgent3D
@export var target_obj: Node3D
@export var poses: Array[Node3D]
@export var walkspeed := 2.0
@export var rotspeed := 0.6
@export var active = true
var realpivot :Node3D
var index = 0
var rotating = false

func _ready() -> void:
	if poses.size() > 0:
		target_obj = poses[index]
		agent.target_position = target_obj.global_position

func _physics_process(delta: float) -> void:
	if active:
		if not is_on_floor():
			velocity += get_gravity() * delta

		if agent.is_navigation_finished():
			upd()

		var next_position = agent.get_next_path_position()
		var direction = global_position.direction_to(next_position)

		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		var dir = agent.target_position - global_position
		var pos = atan2(dir.x, dir.z)

		rotation.y = lerp_angle(rotation.y, pos, 1.0 * delta)

		var forward = -global_transform.basis.z
		var target_dir = dir.normalized()
		var dot_product = forward.dot(target_dir)
		if dot_product < -0.9:
			rotating=false
		else:
			rotating = true
			
		if rotating:
			speed = rotspeed
		else:
			speed = walkspeed
		move_and_slide()

func upd() -> void:
	if poses.is_empty():
		return
	index = (index + 1) % poses.size()
	target_obj = poses[index]
	agent.target_position = target_obj.global_position

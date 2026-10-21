extends Node3D

@export var raycast:RayCast3D
@export var pivot:Node3D
@export var grabpoint:Node3D
var obj
var point
var being_climbed = false
var player
var collisioning=false
var mode = 1
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
func _process(delta: float) -> void:
	raycast.look_at(pivot.global_position)
	if raycast.is_colliding():
		obj = raycast.get_collider()
		if obj.is_in_group("escalable"):
			var pp = raycast.get_collision_point()
			grabpoint.global_position = pp
			point = pp
			collisioning = true
		else:
			collisioning = false
	if being_climbed:
			InputMovements(delta)
	else:
		var newpos = Vector3(player.global_position.x,player.global_position.y+2,player.global_position.z)
		pivot.look_at(newpos)
	#Position handle
	#handle_self_position()
	
func handle_self_position():
	if player.mamoot:
		being_climbed = true
		pivot.global_position.x = player.mamoot.pivotplace.global_position.x
		pivot.global_position.z = player.mamoot.pivotplace.global_position.z
		 
		player.mamoot.manager = $"."
		player.mamoot.point= $"../grabpoint"
func InputMovements(delta):
	
	raycast.look_at(pivot.global_position)
	if player.move:
		var input_dir := Input.get_vector("left", "right", "up", "down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() 
		match mode:
			1:
				pivot.global_rotation.y += direction.x*player.climbspeed*delta
				pivot.position.y+= -direction.z*player.climbspeed*delta
			2:
				pivot.global_rotation.y += direction.x*player.climbspeed*delta
				pivot.position.y += max(-direction.z, 0.0) * player.climbspeed * delta
				
			3:
				pivot.global_rotation.y += direction.x*player.climbspeed*delta
				pivot.position.y += min(-direction.z, 0.0) * player.climbspeed * delta
			

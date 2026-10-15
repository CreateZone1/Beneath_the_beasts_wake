extends Node3D

@export var raycast:RayCast3D
@export var pivot:Node3D
@export var grabpoint:Node3D
var obj
func _process(delta: float) -> void:
	raycast.look_at(pivot.global_position)
	if raycast.is_colliding():
		obj = raycast.get_collider()
		if obj.is_in_group("escalable"):
			var pp = raycast.get_collision_point()
			grabpoint.global_position = pp
	InputMovements(delta)
	print(obj)
func InputMovements(delta):
	raycast.look_at(pivot.global_position)
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() 
	pivot.global_rotation.y += direction.x*delta
	pivot.global_rotation.z+= direction.z*delta

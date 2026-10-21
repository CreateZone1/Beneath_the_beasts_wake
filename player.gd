extends CharacterBody3D


var SPEED = 3.0
var JUMP_VELOCITY = 2.5
@export var walk_speed:=3.0
@export var run_speed:=5.0
@export var climbspeed:=2.0
var running = false
@export var streng_multiplier_max:=3.0
@export var base_damage:=30.0
@export var ray:RayCast3D
@export var sens = 0.002
@export var pivot:Node3D
@export var sprarm:SpringArm3D
@export var camera:Camera3D
@export var model:Node3D
@export var climbarea:Area3D

var can_climb = false
var is_climbing = false
var mamoot


var strenght:=0.0
var is_in_weak_point:=false

var aux = 0.0
var point 
var try_hit:=false
var base_velocity:=Vector3.ZERO
var animal_velocity:=Vector3.ZERO
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	

func _physics_process(delta: float) -> void:
	match is_climbing:
		true:
			sprarm.spring_length = lerp(sprarm.spring_length,7.0,5*delta)
		false:
			sprarm.spring_length = lerp(sprarm.spring_length,3.45,7*delta)
	speed_control()
	keyscontrol()
	print(mamoot)
	if !is_climbing:
		handle_movement(delta)
	else:
		handle_climb_sistem(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if is_climbing:
			$pivotofp.rotate_y(-event.relative.x*sens)
			
		else:
			rotate_y(-event.relative.x*sens)
		pivot.rotate_x(-event.relative.y*sens)
		pivot.rotation.x = clamp(pivot.rotation.x,deg_to_rad(-80),deg_to_rad(80))
func keyscontrol():
	print("sens: ", sens)
	
	if Input.is_action_pressed("hit"):
		if is_climbing:
			try_hit = true
		else:
			try_hit = false
	else:
		try_hit = false
	if Input.is_action_just_released("hit") and try_hit:
		mamoot.Take_Damage(strenght)
	if Input.is_action_just_pressed("esc"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("climb") and can_climb:

		is_climbing = true
		point = mamoot.point
		mamoot.being_climbed = true
	if can_climb == false:
	
		is_climbing = false
		if mamoot:
			mamoot.being_climbed = false
func speed_control():

	if Input.is_action_pressed("run"):
		running= true
	else:
		running =false
	match running:
		true:
			SPEED = run_speed
		false:
			SPEED = walk_speed
func handle_climb_sistem(delta):
	var newlook = Vector3(mamoot.raycast_pivot.global_position.x,model.global_position.y,mamoot.raycast_pivot.global_position.z)
	model.look_at(newlook)

	var newpos = Vector3(point.global_position.x,point.global_position.y-2,point.global_position.z)
	global_position = lerp(global_position,newpos,03*delta)
	print("fuerza "+str(strenght))
	strenght = lerp(strenght,aux,1*delta)
	print("camera fov"+str(camera.fov))
	print("camera fov new"+str(camera.fov+(strenght*0.5)))
	
	camera.fov = lerp(camera.fov,75.0-(strenght),2*delta)
	if try_hit:
		aux = base_damage
		
	else:
		aux = 0.0
		camera.fov = lerp(camera.fov,75.0,7*delta)
		
func paralelismo(raycast:RayCast3D):
	if not raycast.is_colliding():
		return

	var normal = raycast.get_collision_normal()
	var forward = -global_basis.z
	forward = forward.slide(normal).normalized()

	if forward.length_squared() < 0.001:
		return
	if raycast.get_collider().is_in_group("escalable"):
		global_basis = Basis.looking_at(forward, normal)
func handle_movement(delta):
	#global_position = point.global_position
	if not is_on_floor():
		velocity.y += -9*delta
	for obj in get_tree().get_nodes_in_group("Exclude"):
		sprarm.add_excluded_object(obj)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	print(camera.fov)
	
	if direction:
		velocity.x = move_toward(velocity.x,direction.x*SPEED,.2)
		velocity.z =  move_toward(velocity.z,direction.z*SPEED,.2)
	else:
		velocity.x = move_toward(velocity.x, 0, .3)
		velocity.z = move_toward(velocity.z, 0, .3)
	move_and_slide()

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("escalable"):
		$Area3D.monitorable=false
		can_climb = true
		mamoot = area.main	
	else:
		$Area3D.monitorable = true
			

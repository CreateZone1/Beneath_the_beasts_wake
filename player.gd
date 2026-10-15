extends CharacterBody3D


var SPEED = 3.0
var JUMP_VELOCITY = 2.5
@export var walk_speed:=3.0
@export var run_speed:=5.0
var running = false
@export var sens = 0.002
@export var pivot:Node3D
@export var sprarm:SpringArm3D
@export var camera:Camera3D
@export var model:Node3D
@export var climbarea:Area3D
var can_climb = false
var is_climbing = false
var mamoot
var point 
var base_velocity:=Vector3.ZERO
var animal_velocity:=Vector3.ZERO
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
func _physics_process(delta: float) -> void:
	speed_control()
	#keyscontrol()
	handle_movement(delta)
	


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x*sens)
		pivot.rotate_x(-event.relative.y*sens)
		pivot.rotation.x = clamp(pivot.rotation.x,deg_to_rad(-80),deg_to_rad(80))
func keyscontrol():
	if Input.is_action_just_pressed("esc"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("climb") and can_climb:
		is_climbing = true
		point = mamoot.point
	if can_climb == false:
		is_climbing = false
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
	global_position = point.global_position
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
	if direction:
		velocity.x = move_toward(velocity.x,direction.x*SPEED,.2)
		velocity.z =  move_toward(velocity.z,direction.z*SPEED,.2)
	else:
		velocity.x = move_toward(velocity.x, 0, .3)
		velocity.z = move_toward(velocity.z, 0, .3)
	move_and_slide()

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("escalable"):
		can_climb = true
		mamoot = area.main	

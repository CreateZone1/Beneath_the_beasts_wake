extends CharacterBody3D


var SPEED = 3.0
var JUMP_VELOCITY = 2.5
@export var walk_speed:=3.0
@export var run_speed:=5.0
@export var climbspeed:=2.0
var running = false
@export var streng_multiplier_max:=3.0
var damage =0.0
@export var base_damage:=30.0
@export var buff_damage:=3.0
@export var ray:RayCast3D
@export var sens = 0.002
@export var pivot:Node3D
@export var sprarm:SpringArm3D
@export var camera:Camera3D
@export var model:Node3D
@export var climbarea:Area3D
@onready var label: Label = $Control/Label
@onready var timer: Timer = $Timer
@onready var mesh_instance_3d_2: MeshInstance3D = $MeshInstance3D/MeshInstance3D2

var can_climb = false
var is_climbing = false
var mamoot
var knock_velocity:=Vector3.ZERO
var posicion_inicial_z: float
var strenght:=0.0
var is_in_weak_point:=false

var aux = 0.0
var prepose
var fovlook=0.0
var aux2 = 0.0
var point 
var in_move=false
var try_hit:=false
var base_velocity:=Vector3.ZERO
var move=true
var animal_velocity:=Vector3.ZERO
var val = 0.0
var des = randi_range(1,4)
var movestrvelocirty:=1.0
var pressing = 0
var tecla = "ll"
var strenght_anterior = 0.0
var otherpose
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Control/Label/TextureProgressBar.max_value = timer.wait_time
	posicion_inicial_z = mesh_instance_3d_2.position.z

func _physics_process(delta: float) -> void:
	$Control/Label/TextureProgressBar.value = timer.time_left
	match des:
		1:
			tecla="[W]"
		2:
			tecla="[S]"
		3:
			tecla="[D]"	
		4:
			tecla="[A]"
	match is_climbing:
		true:
			if in_move:
				sprarm.spring_length = lerp(sprarm.spring_length,4.0,5*delta)
			else:
				sprarm.spring_length = lerp(sprarm.spring_length,7.0,5*delta)
		false:
			sprarm.spring_length = lerp(sprarm.spring_length,3.45,7*delta)

	speed_control()
	keyscontrol()
	
	if !is_climbing:
		handle_movement(delta)
	else:
		handle_climb_sistem(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:

			if mamoot and is_climbing and (strenght>10.0):
				if !in_move:
					
					mamoot.Take_Damage(strenght)
					if strenght >= 18:
						val = lerp(val,1.0,5)
			
			

	if event is InputEventMouseMotion:

		if is_climbing:
			$pivotofp.rotate_y(-event.relative.x*sens)
			
		else:
			rotate_y(-event.relative.x*sens)
		prepose = pivot.rotation
		otherpose=$pivotofp.rotation
		pivot.rotate_x(-event.relative.y*sens)
		pivot.rotation.x = clamp(pivot.rotation.x,deg_to_rad(-80),deg_to_rad(80))
func keyscontrol():
	print(strenght)
	if is_in_weak_point:
		damage=base_damage*buff_damage
	else:
		damage = base_damage
	if Input.is_action_pressed("hit"):
		if is_climbing:
			try_hit = true
			move=false
		else:
			
			try_hit = false
	else:
		move=true
		try_hit = false
	#PRESSING:
	if Input.is_action_pressed("up"):
		pressing =1
	elif Input.is_action_pressed("down"):
		pressing =2
	elif Input.is_action_pressed("right"):
		pressing =3
	elif Input.is_action_pressed("left"):
		pressing =4
	else:
		pressing=0

	if Input.is_action_just_pressed("esc"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("backdown"):
		is_climbing = false
		can_climb = false
		if mamoot:
			mamoot.being_climbed = false
			mamoot.timer.stop()
	if Input.is_action_just_pressed("climb") and can_climb:

		is_climbing = true
		mamoot.timer.start()
		point = mamoot.point
		mamoot.being_climbed = true
	if can_climb == false:
	
		is_climbing = false
		if mamoot:
			mamoot.being_climbed = false
			
			
func out():
	pivot.rotation = prepose
	$pivotofp.rotation = otherpose
	is_climbing = false
	can_climb = false
	in_move = false
	sprarm.spring_length = lerp(sprarm.spring_length,3.45,7)
	if mamoot:
			
			mamoot.player.in_move =false
			mamoot.des = false
			mamoot.timer.stop()
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
	
	label.text = tecla
	#blur radial
	var material = $"../..".material
	material.set_shader_parameter("power", val)
	val = lerp(val,0.0,2*delta)
	
	#rotation
	var newlook = Vector3(mamoot.raycast_pivot.global_position.x,model.global_position.y,mamoot.raycast_pivot.global_position.z)
	model.look_at(newlook)
	#movement

	var newpos = Vector3(point.global_position.x,point.global_position.y-2,point.global_position.z)
	global_position = lerp(global_position,newpos,8*delta)
		

	#damage
	if !in_move:
	
		strenght = lerp(strenght,aux,movestrvelocirty*delta)
		fovlook = lerp(fovlook,aux2,movestrvelocirty*delta)
		camera.fov = lerp(camera.fov,75.0-(fovlook),2*delta)
		if try_hit:
			mesh_instance_3d_2.position.z = posicion_inicial_z + fovlook * 0.1
			strenght_anterior = strenght
			aux = damage
			aux2 = 30.0
			movestrvelocirty = 1
		else:
			mesh_instance_3d_2.position.z = posicion_inicial_z - fovlook * 0.2
			aux = 0.0
			aux2=0.0
			movestrvelocirty = 5
			camera.fov = lerp(camera.fov,75.0,7*delta)
	if in_move:
					try_hit = false
					strenght = 0
					aux = 0.0
					aux2=0.0
					movestrvelocirty = 5
					camera.fov = lerp(camera.fov,75.0,7*delta)
	if !in_move:
		inmove()
		move=true
	else:
		label.visible = true
		move=false


func inmove():
	label.visible = false
	$Timer.start()
		
func _on_timer_timeout() -> void:
	if des != pressing:
		print("no pudiste")
		out()
		knockback(global_transform.basis.z,.1,15.0)
		$Timer.stop()
	if des == pressing:
		print("pudiste")
	des = randi_range(1,4)

	

func handle_movement(delta):
	
	#global_position = point.global_position
	if not is_on_floor():
		base_velocity.y += -9*delta
	for obj in get_tree().get_nodes_in_group("Exclude"):
		sprarm.add_excluded_object(obj)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		base_velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		base_velocity.x = move_toward(base_velocity.x,direction.x*SPEED,.2)
		base_velocity.z =  move_toward(base_velocity.z,direction.z*SPEED,.2)
	else:
		base_velocity.x = move_toward(base_velocity.x, 0, .3)
		base_velocity.z = move_toward(base_velocity.z, 0, .3)
	knock_velocity.x =move_toward(knock_velocity.x, 0, .3)
	knock_velocity.z =move_toward(knock_velocity.z, 0, .3)
	knock_velocity.y =move_toward(knock_velocity.y, 0, .3)
	
	
	velocity = base_velocity+knock_velocity
	move_and_slide()
func knockback(direction: Vector3, altura:float,force: float):
	var direccion = direction+ Vector3.UP * altura
	knock_velocity = direccion.normalized() * force
func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("escalable"):

		can_climb = true
		mamoot = area.main	
			


func _on_checl_area_entered(area: Area3D) -> void:
	if area.is_in_group("debil"):
		is_in_weak_point = true
	else:
		is_in_weak_point = false


func _on_checl_area_exited(area: Area3D) -> void:
	if area.is_in_group("debil"):
		is_in_weak_point = false

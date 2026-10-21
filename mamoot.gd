extends CharacterBody3D
@export var vida:=10.0
@export var speed = 2.0
@export var agent: NavigationAgent3D
@export var target_obj: Node3D
@export var poses: Array[Node3D]
@export var walkspeed := 2.0
@export var rotspeed := 0.6
@export var active = true
@export var point:=Node3D
@export var pr_vida:TextureProgressBar
@export var txt1:Texture2D
@export var txt2:Texture2D
@onready var timer: Timer = $Timer

var realpivot :Node3D
@export var pivot:Node3D
@onready var raycast_pivot: Node3D = $RaycastPivot
@export var anim:AnimationPlayer



enum statesanim {
	IDLE,
	WALK,
	MOVE1
}
var state=statesanim.IDLE
var index = 0
var rotating = false
var des = false
var being_climbed = false
var player
var death =false
var tecla:="[W]"
var moving = false
func Take_Damage(dam):
	animati()
	vida-=dam
func _ready() -> void:
	pr_vida.max_value =  vida
	player = get_tree().get_first_node_in_group("Player")
	if poses.size() > 0:
		target_obj = poses[index]
		agent.target_position = target_obj.global_position
func animcontrol():
	match state:
		statesanim.MOVE1:
			anim.play("MOVE1")
	
		
func camshot(value):
	player.val=value
func _physics_process(delta: float) -> void:
	pr_vida.value = lerp(pr_vida.value,vida,2*delta)

	if vida <=0:
		death =true
	if death:
		active=false

	if !being_climbed:
		pivot.position.y = player.position.y+2
	raycast_pivot.being_climbed = being_climbed 
		
	if active:
		animcontrol()
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
func animati():
	pr_vida.texture_progress = txt2
	await get_tree().create_timer(0.2).timeout
	pr_vida.texture_progress = txt1

func _on_area_3d_area_exited(_area: Area3D) -> void:
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	if being_climbed and!moving:
		des = true
		player.in_move =true
		if des:
			moving = true
			state=statesanim.MOVE1


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="MOVE1":
		moving = false
		state=statesanim.IDLE
		player.in_move =false
		des = false
		timer.start(randf_range(2.0,8.0))

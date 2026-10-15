extends Area3D

@onready var raycast_pivot: Node3D = $"../../RaycastPivot"
@onready var cantclimb: Area3D = $"../../cantclimb"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("lock"):
		print("?")
		raycast_pivot.mode = area.eje_bloqueado


func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("lock"):
		raycast_pivot.mode = 1

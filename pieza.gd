extends Area3D

@export var main:Node3D
@export var point:Node3D
@export var manager:Node3D
@export var pivotplace:Node3D
var being_climbed = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if manager:
		manager.being_climbed  = being_climbed

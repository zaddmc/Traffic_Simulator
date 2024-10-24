extends Node3D

var MaxSpeed = 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var vec = Vector3(10, 10, 0)
	translate(vec)
	print("This is my position: " + str(position))
	pass

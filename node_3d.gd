extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var child
	child.name = "Child"
	child.script = preload("res://BilKlasse.gd")
	child.sprite = preload("res://icon.svg")
	child.owner = self
	child.position = Vector3()
	add_child(child)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

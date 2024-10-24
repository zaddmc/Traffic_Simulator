extends PathFollow3D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_progress(get_progress()+1*delta)
	if get_progress() >= 1.0:
		set_progress(0)
	

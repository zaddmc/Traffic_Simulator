extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer = Timer.new()
	timer.autostart = true  
	timer.wait_time = 5 
	add_child(timer)
	timer.timeout.connect(testing)
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func testing():
	var material = get_child(0).get_child(0).get_active_material(0)
	material.albedo_color = Color(1, 0, 0)
	return

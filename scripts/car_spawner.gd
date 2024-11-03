# Unused legacy code
extends Path3D

@export var car_spawn_count: int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	var fast_car = Car.new_car(10, 50)
	add_child(fast_car)

	var fast_car2 = Car.new_car(100, 40)
	add_child(fast_car2)

	for i in range(car_spawn_count):
		var car = Car.new_car(-20*i)
		add_child(car)
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

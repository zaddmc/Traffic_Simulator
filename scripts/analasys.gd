class_name  Analasys
extends Node
"""Class / script to be placed on a traffic light root node 'cross' to count the 
throughput through it"""
#Git setup check

var total_cars_through: int = 0
var total_cars_through_histo: Array[int]
var cars_through_direction = []


func _ready() -> void:
    for x in range(0,get_child(0).get_child_count()):
        cars_through_direction.append(0)



func add_through(road):
    total_cars_through += 1
    cars_through_direction[road.get_index()] += 1


func update_histo():
    total_cars_through_histo.append(total_cars_through)
    

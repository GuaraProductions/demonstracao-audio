extends Control

@onready var btn_demo_1: Button = %BtnDemo1
@onready var btn_demo_2: Button = %BtnDemo2
@onready var btn_demo_3: Button = %BtnDemo3
@onready var btn_demo_4: Button = %BtnDemo4

func _ready() -> void:
	btn_demo_1.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/demo_1_global/demo_global.tscn"))
	btn_demo_2.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/demo_2_2d/demo_2d.tscn"))
	btn_demo_3.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/demo_3_3d/demo_3d.tscn"))
	btn_demo_4.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/demo_4_transition/scene_a.tscn"))

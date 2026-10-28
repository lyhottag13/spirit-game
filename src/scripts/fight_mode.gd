extends Node
@onready var spirit_bar: ColorRect = $CanvasLayer/ColorRect
var wet:bool = false
signal finished
signal pressure_changed(pressure)

@export var increment: int
@export var decrement: int
@onready var color_rect: ColorRect = $CanvasLayer/Control/ColorRect
@onready var gun_rotate: Node2D = $GunRotate
@onready var texture_rect: TextureRect = $GunRotate/TextureRect
@onready var water_gun: Node2D = $WaterGun
@onready var point: Node2D = $GunRotate/point




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


var spirit_health = 100.0

func update_health():
	if color_rect.size.x >= 1920:
		emit_signal("finished")
	var pressure = (color_rect.size.x / 1920)
	pressure_changed.emit(pressure)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_cords = get_viewport().get_mouse_position()
	var direction = mouse_cords - gun_rotate.global_position

	if direction.length() > 10:
		gun_rotate.rotation = direction.angle() + (PI/18 * 15.5)
		water_gun.muzzle.position = point.global_position
	if wet and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		color_rect.size.x += increment * delta
	else:
		color_rect.size.x += decrement * delta
	update_health()
	
	

func _on_spirit_entity_wet() -> void:
	wet = not wet

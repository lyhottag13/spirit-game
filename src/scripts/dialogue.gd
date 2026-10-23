extends Control
@onready var text_label: RichTextLabel = $RichTextLabel
@onready var color_rect: ColorRect = $ColorRect
func change_color():
	color_rect.size = text_label.size 
	color_rect.position= text_label.position

func change_text(text: String):
	text_label.text = text
	await get_tree().process_frame
	change_color()
func change_visibility(choice: bool):
	self.visibile = choice
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

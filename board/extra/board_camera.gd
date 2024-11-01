extends Camera2D


@export_custom(PROPERTY_HINT_LINK, "") var frame_margin: Vector2 = Vector2(4, 4)
@export var zoom_step: float = 0.25

@onready var _board: Board2D = Board2D.find_parent_board(self)


func _process(_delta: float) -> void:
	if _board:
		var board_rect := _board.get_layout_bounds()
		global_position = _board.to_global(board_rect.get_center())
		var viewport_rect := get_viewport_rect()
		var rect_ratio := viewport_rect.size / (board_rect.size + frame_margin * 2.0)
		var zoom_ratio := minf(rect_ratio.x, rect_ratio.y)
		zoom = Vector2.ONE * snappedf(zoom_ratio, zoom_step)

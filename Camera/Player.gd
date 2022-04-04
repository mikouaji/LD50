extends Camera

func init(_mapRadius : int, _pos : Vector3) -> void:
	BOUNDRY = _mapRadius
	global_transform.origin = _pos
	pass

func _input(event):
	_zoom(event)
	_move(event)

const ZOOM := Vector2(10, 500)
const ZOOM_STEP := 0.1
onready var ZoomTween : Tween = get_node("ZoomTween")
func _zoom(_event : InputEvent) -> void:
	var value = get_translation()
	var newValue = value
	if _event.is_action("ZOOM_IN") && value.y>ZOOM.x:
		newValue = value - value*ZOOM_STEP
	if _event.is_action("ZOOM_OUT") && value.y<ZOOM.y:
		newValue = value + value*ZOOM_STEP
	if newValue != value:
		ZoomTween.interpolate_method(
			self, "set_translation",
			value, newValue, 0.1,
			Tween.TRANS_LINEAR, Tween.EASE_OUT
		)
		ZoomTween.start()
	pass

var BOUNDRY : int = 100
const MOVE_STEP := 10
var MOUSE_DRAG_ON := false
var MOUSE_DRAG_POS := Vector2.ZERO
onready var MoveTween : Tween = get_node("MoveTween")
func _move(_event : InputEvent) -> void:
	var position = get_translation()
	var pos2D = Vector2(position.x, position.z)
	var newPos2D = pos2D
	#keyboard movement
	if _event.is_action("DOWN"):
		newPos2D.y += MOVE_STEP
	if _event.is_action("UP"):
		newPos2D.y -= MOVE_STEP
	if _event.is_action("LEFT"):
		newPos2D.x -= MOVE_STEP
	if _event.is_action("RIGHT"):
		newPos2D.x += MOVE_STEP
	#mouse draging
	if _event is InputEventMouseButton and _event.button_index == BUTTON_RIGHT:
		if _event.is_pressed():
			MOUSE_DRAG_ON = true
			MOUSE_DRAG_POS = _event.position
		else:
			MOUSE_DRAG_ON = false
	if MOUSE_DRAG_ON:
		var dir = MOUSE_DRAG_POS.direction_to(_event.position)
		newPos2D += dir * MOVE_STEP

	if newPos2D != pos2D && not __CrossesBounrdy(newPos2D, pos2D):
		MoveTween.interpolate_method(
			self, "set_translation", 
			position, Vector3(newPos2D.x, position.y, newPos2D.y), 
			0.1, Tween.TRANS_LINEAR, Tween.EASE_IN
		)
		MoveTween.start()
	pass

func __CrossesBounrdy(_newPos : Vector2, _pos : Vector2) -> bool:
	var newFromCenter = _newPos.distance_squared_to(Vector2.ZERO)
	var curFromCenter = _pos.distance_squared_to(Vector2.ZERO)
	if newFromCenter < curFromCenter:
		return false
	return _newPos.distance_squared_to(Vector2.ZERO) >= BOUNDRY*BOUNDRY * 1.05


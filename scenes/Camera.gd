extends Camera2D

var moving: PackedInt32Array = [-1,-1]

@onready var buildMenu: Panel = $buildMenu

@onready var laserButton: Button = get_node("buildMenu/laserButtonPanel/laserButton")
signal laserButtonPlacing

@onready var dogButton: Button = get_node("buildMenu/dogButtonPanel/dogButton")
signal dogButtonPlacing

@onready var mirrorButton: Button = get_node("buildMenu/mirrorButtonPanel/mirrorButton")
signal mirrorButtonPlacing

@onready var mirrorBlockerButton: Button = get_node("buildMenu/mirrorBlockerPanel/mirrorBlockerButton")
signal mirrorBlockerButtonPlacing

@onready var DeleteButton: Button = get_node("buildMenu/DeleteButtonPanel/DeleteButton")
signal deleteButtonPlacing

@onready var closeMenuButton: TextureButton = get_node("buildMenu/closeMenuButton")


var camVelocity: float = 150
var zoomVelocity: float = 1

var maxBottomRightX = 1152
var maxBottomRightY = 648

func _laserButtonPressed():
	laserButtonPlacing.emit()

func _mirrorButtonPressed():
	mirrorButtonPlacing.emit()

func _dogButtonPressed():
	dogButtonPlacing.emit()

func _mirrorBlockerButtonPressed():
	mirrorBlockerButtonPlacing.emit()

func  _deleteButtonPresseed():
	deleteButtonPlacing.emit()
	
func _hideBuildMenu():
	buildMenu.visible = false
	
func _ready():
	laserButton.pressed.connect(self._laserButtonPressed)
	mirrorButton.pressed.connect(self._mirrorButtonPressed)
	dogButton.pressed.connect(self._dogButtonPressed)
	mirrorBlockerButton.pressed.connect(self._mirrorBlockerButtonPressed)
	DeleteButton.pressed.connect(self._deleteButtonPresseed)
	closeMenuButton.pressed.connect(self._hideBuildMenu)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#go in various directions
	
	global_position.x = clamp(global_position.x, 0, maxBottomRightX)
	global_position.y = clamp(global_position.y, 0, maxBottomRightY)
	
	if moving[0] ==1:
		global_translate(Vector2(delta * camVelocity, 0 ))
	elif moving[0] == 3:
		global_translate(Vector2( - delta * camVelocity, 0))
	if moving[1] == 0:
		global_translate(Vector2(0, - delta * camVelocity))
	elif moving[1] == 2:
		global_translate(Vector2(0 , delta * camVelocity))
			
func _unhandled_input(event):
	
	if event.is_action_pressed("build_menu"):
		if buildMenu.visible == true:
			buildMenu.visible = false
		else:
			buildMenu.visible = true
	
	
	if event.is_action_pressed("camera_up"):
		moving[1] = 0
	elif event.is_action_pressed("camera_down"):
		moving[1] = 2
	if event.is_action_released("camera_up") or event.is_action_released("camera_down"):
		moving[1] = -1
		
	if event.is_action_pressed("camera_right"):
		moving[0] = 1
	elif event.is_action_pressed("camera_left"):
		moving[0] = 3
	if event.is_action_released("camera_left") or event.is_action_released("camera_right"):
		moving[0] = -1
	
			
				

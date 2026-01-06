extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") #گرفتن مقدار جاذبه از انجین

@export var player_speed : float = 6.0 #سرعت حرکت
@export var jump_force : float = 8.0 #قدرت پرش
@export var mouse_sensitivity : float = 0.5 # سرعت چرخش دوربین


@onready var plaer_camer: Node3D = $plaer_camer


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #قفل کردن موس در لحظاه ای اجرای بازی


func _process(delta: float) -> void:
	#کپچر کردن و ازاد کردن موس
	if Input.is_action_just_pressed("ui_cancel"): 
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED : #چک کردن وضعیت موس
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else :
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			


func _unhandled_input(event: InputEvent) -> void:
	#چرخاندن دوربین با استفاده از موس  و محدود کردن چرخش در محور ایکس
	if event is InputEventMouseMotion: 
		rotation_degrees.y -= event.relative.x * mouse_sensitivity #چرخاندن
		plaer_camer.rotation_degrees.x -= event.relative.y * mouse_sensitivity #چرخاندن
		plaer_camer.rotation_degrees.x = clamp(plaer_camer.rotation_degrees.x, -90, 90) #محدود کردن
	
func _physics_process(delta: float) -> void:
	#اعمال جاذبه
	if not is_on_floor():
		velocity.y -= gravity * delta
	#پرش
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() : 
		velocity.y += jump_force
	
	#حرکت به چپ و راست روبه رو و عقب
	#گرفتن جهت
	var input_dir = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	var diction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() #تبدیل به بردار سه بعدی
	#اعمال نیروی حرکتی 
	if diction: 
		velocity.x = diction.x * player_speed
		velocity.z = diction.z * player_speed
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

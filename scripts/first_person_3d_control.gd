extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") #گرفتن مقدار جاذبه از انجین

#----------------------------------------------------------------------------------------------
# مقییر ها برای تایین کلید های وردی برای کنترل پلیر
@export var forward_key: String 
@export var backward_key : String
@export var left_key: String
@export var right_key: String
@export var jump_key: String 
@export var sit_key: String
@export var run_key : String
@export var flashlight_key: String
#----------------------------------------------------------------------------------------------
#پارمتر های قابل تغییر برای پلیر
@export var player_walk_speed : float = 6.0 #سرعت حرکت
@export var player_run_speed : float = 8.5 #سرعت دویدن
@export var player_sit_speed : float = 2.5 #سرعت نشتن
var player_move_speed : float # متغییر برای تظیم تغییر بین حالت دویدون و راه رفتن
@export var player_jump_force : float = 6.0 #قدرت پرش
@export var mouse_sensitivity : float = 0.5 # سرعت چرخش دوربین

#----------------------------------------------------------------------------------------------
#نود های استفاده شده در کد
@onready var stand_collision : CollisionShape3D = $stand_collision
@onready var sit_collision : CollisionShape3D = $sit_collision
@onready var plaer_camer : Node3D = $plaer_camer
@onready var flash_light : SpotLight3D = $plaer_camer/flash_light
@onready var raycast : RayCast3D = $raycast
@onready var animation_camera: AnimationPlayer = $plaer_camer/Camera3D/animation_camera


#----------------------------------------------------------------------------------------------
# متغییر ها مربط به حالت ایستادن و نشتن پلیر
var stand_position_camera  # پوزیشن دوربین در حالت ایستاده
var sit_position_camera  # پوزیشن دوربین در حالت نشسته
enum sit_statos {stand , sit , co_sit} # حالت های پلیر
var player_statos : sit_statos = sit_statos.stand # تغییر حالت های پلیر (کنترل کردن حالت ها )


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #قفل کردن موس در لحظاه ای اجرای بازی
	
	# تنظیم حالت اولیه کولیژن ها و تنظیم مقادیر که دوربین باید به انها حرکت کند
	stand_collision.disabled = false
	sit_collision.disabled = true
	stand_position_camera = plaer_camer.position.y
	sit_position_camera = plaer_camer.position.y /2
	
	# مقدار اولیه سرعت حرکتر پلیر
	player_move_speed = player_walk_speed
	
	# تنظیم حالت اولیه ای چراغ قوه
	flash_light.visible = false
	
func _process(delta: float) -> void:
	#کپچر کردن و ازاد کردن موس
	if Input.is_action_just_pressed("ui_cancel"): 
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED : #چک کردن وضعیت موس
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else :
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	#--------------------------------------------------------------------------------	
	
	# فراخوانی تابع ها (برای تمیز تر شدن کد)
	player_sit(delta) # تابع نشتن
	flashlight() # تابع چراغ‌قوه
	camera_animation() # تابع کمنترل انمیشن های دوربین

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
	
#--------------------------------------------------------------------------------

	# فراخوانی تابع ها (برای تمیز تر شدن کد)
	player_move_ment() # تابع حرکت به چهار چهت پلیر
	player_jump()# تابع پرش پلیر 
	
	
	
	move_and_slide() # تابع مورد نیاز برای اعمال فیزیکی (اجباری و پیشفرض)



func  player_move_ment () : 
	
	#حرکت به چپ و راست روبه رو و عقب
	#گرفتن جهت
	var input_dir = Vector2(
		int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")) ,
		int(Input.is_action_pressed("backward")) - int(Input.is_action_pressed("forward"))
		)
	var diction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() #تبدیل به بردار سه بعدی
	#اعمال نیروی حرکتی 
	if diction:
		velocity.x = diction.x * player_move_speed
		velocity.z = diction.z * player_move_speed
	else:
		velocity.x = 0
		velocity.z = 0
	
	# دویدن پلیر
	if Input.is_action_pressed("run") and Input.is_action_pressed("forward") : 
		player_move_speed = player_run_speed
	else :
		player_move_speed = player_walk_speed

func player_jump () : 
	#پرش
	if Input.is_action_just_pressed(jump_key) and is_on_floor() : 
		velocity.y += player_jump_force

func player_sit (delta) : 
		
	#اعمال نسشت با استفاده از اینام وضیعت کاراکتر
	match player_statos : 
		sit_statos.stand:
			stand_collision.disabled = false
			sit_collision.disabled = true
			player_move_speed = player_walk_speed
			plaer_camer.position.y = lerp(plaer_camer.position.y , stand_position_camera , 6 *delta)
		sit_statos.sit : 
			stand_collision.disabled = true
			sit_collision.disabled= false
			player_move_speed = player_sit_speed
			plaer_camer.position.y = lerp(plaer_camer.position.y , sit_position_camera , 6 *delta)
		sit_statos.co_sit : 
			stand_collision.disabled = true
			sit_collision.disabled= false
			player_move_speed = player_sit_speed
			plaer_camer.position.y = lerp(plaer_camer.position.y , sit_position_camera , 6 *delta)
	# کنترل اینام وضعیت کاراکتر
	if Input.is_action_pressed(sit_key) : 
		player_statos = sit_statos.sit
	elif raycast.is_colliding() :
		player_statos = sit_statos.sit
	else :
		player_statos = sit_statos.stand

func flashlight () :
	if Input.is_action_just_pressed(flashlight_key) and flash_light.visible == false : 
		flash_light.visible = true
	elif Input.is_action_just_pressed(flashlight_key) and flash_light.visible == true :
		flash_light.visible = false

func camera_animation () : 
	if Input.is_action_pressed(forward_key) : 
		animation_camera.play("walke_animation")
	else :
		animation_camera.play("idel_camera")
	if Input.is_action_pressed(forward_key) and Input.is_action_pressed(run_key) : 
		animation_camera.play("run_camera")
	else :
		animation_camera.play("idel_camera")
	if Input.is_action_pressed(sit_key) :
		if raycast.is_colliding() and Input.is_action_pressed(forward_key) : 
			animation_camera.play("sit_animation")
	else :
		animation_camera.play("idel_camera")

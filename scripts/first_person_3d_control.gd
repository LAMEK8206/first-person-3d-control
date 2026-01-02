extends CharacterBody3D

# گرفتن مقدار جاذبه پیش‌فرض از تنظیمات پروژه
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# سرعت حرکت بازیکن
var player_move_speed : float = 6.0
# قدرت پرش بازیکن
var player_jump_power : float = 8.0
# حساسیت موس برای حرکت دوربین
var player_sensitivity : float = 0.5

# گرفتن نود دوربین در لحظه آماده شدن صحنه
@onready var plaer_camer: Node3D = $plaer_camer

func _ready() -> void:
	# موس را قفل می‌کند و روی پنجره بازی می‌گیرد (FPS کلاسیک)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	# بررسی اینکه آیا رویداد موس است
	if event is InputEventMouseMotion: 
		# چرخش بازیکن حول محور Y (چپ/راست) بر اساس حرکت موس
		rotation_degrees.y -= event.relative.x * player_sensitivity
		# چرخش دوربین حول محور X (بالا/پایین)
		plaer_camer.rotation_degrees.x -= event.relative.y * player_sensitivity
		# محدود کردن چرخش عمودی دوربین بین -90 و 90 درجه
		plaer_camer.rotation_degrees.x = clamp(plaer_camer.rotation_degrees.x, -90, 90)
	
func _physics_process(delta: float) -> void:
	# اعمال جاذبه اگر بازیکن در هوا باشد
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# پرش بازیکن وقتی روی زمین است و کلید پرش زده شده
	if Input.is_action_just_pressed("ui_accept") and is_on_floor(): 
		velocity.y += player_jump_power * 50 * delta  # ⚠️ بهتر است بدون ضرب در delta استفاده شود
		
	# گرفتن جهت حرکت از ورودی کاربر (WASD یا فلش)
	var input_dir = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	# تبدیل جهت دوبعدی به سه‌بعدی نسبت به چرخش بازیکن
	var diction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# اعمال حرکت بازیکن
	if diction: 
		velocity.x = diction.x * player_move_speed
		velocity.z = diction.z * player_move_speed
	else:
		# اگر جهت حرکت صفر باشد، سرعت صفر می‌شود
		velocity.x = 0
		velocity.z = 0
		
	# حرکت دادن بازیکن و بررسی برخوردها
	move_and_slide()
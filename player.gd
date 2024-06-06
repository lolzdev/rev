extends CharacterBody3D

@export var speed = 0.0
@export var jump_force = 0.0
@export var sensitivity = 0.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head = $Head
@onready var camera = $Head/Camera3D

var grabbed = true

func _enter_tree():
	set_multiplayer_authority(name.to_int())

# Called when the node enters the scene tree for the first time.
func _ready():
	camera.current = is_multiplayer_authority()
	if is_multiplayer_authority():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if is_multiplayer_authority():
		if event is InputEventMouseMotion && grabbed:
			head.rotate_y(-event.relative.x * sensitivity)
			camera.rotate_x(-event.relative.y * sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		if event is InputEventKey and event.pressed:
			if event.keycode == KEY_ESCAPE:
				grabbed = !grabbed
				if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				else:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):	
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity.y -= gravity * delta
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_force
		var input_dir = Input.get_vector("left", "right", "forward", "back")
		var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
		
		move_and_slide()

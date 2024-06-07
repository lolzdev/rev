extends CharacterBody3D

enum Colliders {
	HEAD = 0,
	LEFT_ARM = 1,
	RIGHT_ARM = 2,
	LEFT_LEG = 3,
	RIGHT_LEG = 4,
	TORSO = 5,
}

@export var speed = 0.0
@export var jump_force = 0.0
@export var sensitivity = 0.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var model_arms = $Model/Simon/Skeleton3D/Arms
@onready var model_head = $Model/Simon/Skeleton3D/Head
@onready var model_body = $Model
@onready var colliders = [$ColliderHead, $ColliderLeftArm, $ColliderRightArm, $ColliderLeftLeg, $ColliderRightLeg, $ColliderTorso]
@onready var animation_player = $Model/AnimationPlayer

var grabbed = true

func _enter_tree():
	set_multiplayer_authority(name.to_int())

# Called when the node enters the scene tree for the first time.
func _ready():
	camera.current = is_multiplayer_authority()
	if is_multiplayer_authority():
		model_head.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animation_player.play("Idle")

func _unhandled_input(event):
	if is_multiplayer_authority():
		if event is InputEventMouseMotion && grabbed:
			#head.rotate_y(-event.relative.x * sensitivity)
			self.rotate_y(-event.relative.x * sensitivity)
			
			camera.rotate_x(-event.relative.y * sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
			
			model_head.rotation.z = camera.rotation.x
			colliders[Colliders.HEAD].rotation = model_head.rotation
		if event is InputEventKey and event.pressed:
			if event.keycode == KEY_ESCAPE:
				grabbed = !grabbed
				if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				else:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	if is_multiplayer_authority():
		colliders[Colliders.LEFT_LEG].rotation = $Model/Simon/Skeleton3D/leftpant.rotation
		colliders[Colliders.RIGHT_LEG].rotation = $Model/Simon/Skeleton3D/rightpant.rotation
		colliders[Colliders.LEFT_ARM].rotation = $Model/Simon/Skeleton3D/Arms/leftsleeve.rotation
		colliders[Colliders.RIGHT_ARM].rotation = $Model/Simon/Skeleton3D/Arms/rightsleeve.rotation
		colliders[Colliders.TORSO].rotation = $Model/Simon/Skeleton3D/torso.rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):	
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity.y -= gravity * delta
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_force
		var input_dir = Input.get_vector("back", "forward", "left", "right")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			animation_player.play("Walk")
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			animation_player.play("Idle")
		
		move_and_slide()

extends State

@onready var right_wall_detector_top: RayCast2D = $"../../WallDetector/RightWallDetectorTop"
@onready var left_wall_detector_bottom: RayCast2D = $"../../WallDetector/LeftWallDetectorBottom"
@onready var left_wall_detector_top: RayCast2D = $"../../WallDetector/LeftWallDetectorTop"
@onready var right_wall_detector_bottom: RayCast2D = $"../../WallDetector/RightWallDetectorBottom"
@onready var jump_sfx: AudioStreamPlayer2D = $"../../SFX/Jump"


@export var double_jumping : State
@export var falling : State
@export var dashing : State
@export var walking : State

var wall
var wall_jump_vector : Vector2
var blocked_input : int

func process_input(event: InputEvent) -> State:
	if event.is_action_pressed("dash") && parent.has_dash:
		return dashing
	return null

func enter() -> void:
	jump_sfx.play()
	if right_wall_detector_bottom.is_colliding() or right_wall_detector_top.is_colliding():
		if Input.is_action_pressed("move_right"):
			wall_jump_vector.x = -1
		else:
			wall_jump_vector.x = -.5
		blocked_input = 1
	else:
		if Input.is_action_pressed("move_left"):
			wall_jump_vector.x =1
		else:
			wall_jump_vector.x = .5
		blocked_input = -1
		
	wall_jump_vector.y = -1
	parent.velocity = wall_jump_vector.normalized() * parent.wall_jump_strength
	await get_tree().create_timer(0.2).timeout
	blocked_input = 0

func process_physics(delta: float) -> State:
	if parent.velocity.y > 0:
		return falling
	
	var current_gravity = parent.GRAVITY
	if Input.is_action_pressed("jump"):
		current_gravity /= 1.5
	
	parent.velocity.y += current_gravity 
	
	var input_direction = Input.get_axis("move_left", "move_right")
	if input_direction != 0 && input_direction != blocked_input:
		input_direction *= parent.air_move_speed
		parent.velocity.x = lerp(parent.velocity.x, input_direction, parent.air_acceleration)
		
	if abs(parent.velocity.x) > parent.minimum_move_speed:
		parent.velocity.x = lerp(parent.velocity.x, 0.0, parent.air_friction)
	else:
		parent.velocity.x = 0

	
	parent.move_and_slide()
	return null

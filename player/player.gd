class_name Player
extends CharacterBody2D

@onready var state_machine = $StateMachine
@onready var wall_detector: Node2D = $WallDetector
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurtbox: Area2D = $Hurtbox
@onready var collision_shape: CollisionPolygon2D = $CollisionShape


const GRAVITY : float = 35
const RESPAWN_DELAY : float = 1

signal spawning

var has_dash : bool :
	get():
		return has_dash
	set(dash):
		if !dash:
			$DashParticles.emitDash()
		has_dash = dash
var has_double_jump : bool
var touching_wall : bool = false
var respawn_location : Vector2
var gems : Array

@export var ground_acceleration : float = .4
@export var ground_move_speed : float = 500
@export var ground_friction : float = 0.4
@export var air_acceleration : float = .2
@export var air_move_speed : float = 550
@export var air_friction : float = 0.03
@export var minimum_move_speed : float = 0.01
@export var jump_strength : float = 1000
@export var double_jump_strength : float = 1000
@export var dash_speed : float = 1000
@export var dash_time : float = 0.1
@export var wall_slide_speed : float = 500
@export var wall_jump_strength : float = 1000

func _check_if_valid_wall() -> bool:
	for raycast in wall_detector.get_children():
		if raycast.is_colliding():
			return true
	return false
	
func _ready() -> void:
	state_machine.init(self)

func spawn(loc) -> void:
	position = loc
	show_sprite()
	enable_collision()
	animation_player.play("spawn")
	state_machine.change_state($StateMachine/Idle)
	await animation_player.animation_finished
	set_spawn_location(loc)
	velocity = Vector2(0,0)
	GameManager.start_time()

func enable_collision() -> void:
	hurtbox.enable_collision()
	collision_shape.set_deferred("disabled", false)

func disable_collision() -> void:
	hurtbox.disable_collision()
	collision_shape.set_deferred("disabled", true)

func set_spawn_location(loc) -> void:
	respawn_location = loc

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

func die() -> void:
	disable_collision()
	$DeathParticles.emitting = true
	hide_sprite()
	state_machine.change_state($StateMachine/Stop)
	await get_tree().create_timer(RESPAWN_DELAY).timeout
	spawn(respawn_location)

func touch_goal(goal : Area2D) -> void:
	disable_collision()
	state_machine.change_state($StateMachine/GoalSucc)
	#Animations
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", goal.position, 1)
	animation_player.play("goal_portal")
	await animation_player.animation_finished
	tween.stop()
	#Load next map
	await GameManager.load_next_map()
	enable_collision()

func show_sprite() -> void:
	$Sprite.visible = true

func hide_sprite() -> void:
	$Sprite.visible = false

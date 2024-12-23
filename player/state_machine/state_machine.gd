extends Node

@export var starting_state : State

var current_state : State

var parent: Player

func init(parent:Player) -> void:
	for child in get_children():
		child.parent = parent
	
	change_state(starting_state)

func change_state(new_state: State)-> void:
	print("changing to:  ", new_state)
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()

func change_state_by_name(name : String) -> void:
	var new_state : State = find_child(name)
	prints("Found state by name:", name, "==", new_state)
	if new_state != null:
		change_state(new_state)
	
func process_physics(delta: float) -> void:
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)

func process_input(event: InputEvent) -> void:
	var new_state = current_state.process_input(event)
	if new_state:
		change_state(new_state)

func process_frame(delta: float) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)

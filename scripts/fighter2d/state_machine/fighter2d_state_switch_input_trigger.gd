class_name Fighter2DStateSwitchInputTrigger

extends Resource


@export var state_index: int = -1
@export var input_command_sequence: Fighter2DInputCommandSequence
@export var reverse_input_command: bool = false
@export var flip_direction: bool = false
@export var requires_hit: bool = true
@export var can_kara_cancel: bool = true


#enum OPTIONS {
	#CAN_CHANGE_DIRECTIONS = 1 << 0,
	#RESET_TRIGGERS_ON_ENTER = 1 << 1,
	#REQUIRES_HIT_TO_SWITCH = 1 << 2,
	#CAN_BE_BUFFED_CANCELED = 1 << 3,
#}

#@export_flags(
	#"Reverse input command", # Reverses the required input sequence (if it includes any reverable directions)
	#"Flip direction on switch",  # Flips the controller's direction when switching state
	#"Requires hit to switch",  # Can only switch states on an offensive hit
	#"Can be buffer canceled") # Some inputs have a buffer window. This allows to resolve sequences from the previous state at the start of this the current state within the buffer window
#var options: int

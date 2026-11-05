extends Area3D

# Make it super easy to create popups
@export_group("Popup Settings")
@export_multiline var popup_text: String = "Popup text"
@export var display_duration: float = 3.5 ## How many seconds the text stays on screen
@export var trigger_only_once: bool = true ## If true, this zone self-destructs after the first use

@export_group("Visual settings")
@export var is_visible: bool = true # toggle visibility

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

# track if this zone has already been triggered (trigger once)
var has_triggered: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if mesh_instance:
		mesh_instance.visible = is_visible

func _on_body_entered(body):
	if has_triggered and trigger_only_once:
		return
		
	if body is Player and body.has_method("show_popup"):
		print("Calling popup: Player detected.")
		has_triggered = true
		body.show_popup(popup_text)
		
		# create a countdown timer to clean up the screen popup
		get_tree().create_timer(display_duration).timeout.connect(
			func(): 
				if is_instance_valid(body): 
					body.hide_popup()
		)

func _on_body_exited(body):
	if body is Player:
		# self-destruct if the player has actually triggered the text and the toggle is checked
		if has_triggered and trigger_only_once:
			queue_free()

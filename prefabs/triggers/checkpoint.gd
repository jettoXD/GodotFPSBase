extends Area3D

@export_group("Visual settings")
@export var is_visible: bool = true

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

# made a popup system so that the player can be instructed or given information.
@onready var popup_label = $PopUp/RichTextLabel

# Store the position where the player will respawn
var spawn_position: Vector3

func _ready() -> void:
	if mesh_instance:
		mesh_instance.visible = is_visible
	
	# Set this checkpoint's position as the spawn target
	spawn_position = global_position
	
	# Connect collision signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" or body is Player:
		print("Checkpoint activated at: ", spawn_position)
		
		# Enable input processing so we can listen for key press
		set_process_unhandled_input(true)
		show_popup("Checkpoint set.")


func _unhandled_input(event: InputEvent) -> void:
	# Check if the player is dead and wants to respawn
	if (event is InputEventKey) and event.is_pressed():
		if not event.is_action("pause"):
			var player = get_tree().current_scene.find_child("Player", true, false) as Player
			if player and player.is_frozen and player.health <= 0:
				respawn_player(player)

func respawn_player(player: Player) -> void:
	print("Respawn...")
	
	# Teleport the player back to spawn
	player.global_position = spawn_position
	
	# Reset the player's death states
	player.is_frozen = false
	player.rotation.z = 0 # Untilt them from the _die() side roll
	
	# Restore health
	player.health = player.MAX_HEALTH
	player.bar_health.value = player.health
	
	# Restore screen visual color adjustments
	if player.camera.environment:
		player.camera.environment.adjustment_saturation = 1.0
		
	# Hide popup
	player.hide_popup()
	
# Notify the player that they reached... a... checkpoint...
func show_popup(text_to_show: String):
	popup_label.text = text_to_show
	popup_label.show()
	await get_tree().create_timer(1.0).timeout # One second
	hide_popup()
	
func hide_popup():
	popup_label.hide()

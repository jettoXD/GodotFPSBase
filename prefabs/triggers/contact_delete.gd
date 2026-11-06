extends Area3D

# The specific group name a prop must have to trigger the deletion
@export var target_group_name: String = ""

# The specific props that will be deleted when the target enters
@export var objects_to_delete: Array[Node3D] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# Check that a group name was actually typed
	if target_group_name.is_empty():
		return
		
	# Check if the colliding object belongs to the designated group
	if body.is_in_group(target_group_name):
		execute_deletion()

func execute_deletion() -> void:
	for obj in objects_to_delete:
		if is_instance_valid(obj):
			obj.queue_free()
	queue_free() # Delete the trigger

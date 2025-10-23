extends Resource
class_name ColliderComponent

## The collision shape type: "circle", "box", "sphere", etc.
var shape_type: String = "circle"

## The collision radius or half-extent (for circles/spheres)
var size: float = 0.5

## Whether this collider is a trigger (no physics, only events)
var is_trigger: bool = false

## Collision layer & mask (for filtering what it interacts with)
var layer: int = 1
var mask: int = 1

## Optional offset relative to TransformComponent
var offset: Vector3 = Vector3.ZERO

## If collider is linked to a physics body node (optional)
var node_ref: Node = null

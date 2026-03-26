class_name CardData
extends Resource

enum CardType { MOVE, SCOUT, GATHER, SETTLE, RESOURCE }
enum ResourceType { NONE, FOOD, MATERIALS }

@export var card_name: String = ""
@export_multiline var description: String = ""
@export var card_type: CardType = CardType.MOVE
@export var range_value: int = 1
@export var cost: int = 1
@export var card_color: Color = Color.WHITE
@export var icon_path: String = ""
@export var defense_cost: int = 0
@export var icon_scale: float = 1.0
@export var resource_type: ResourceType = ResourceType.NONE
@export var resource_value: int = 0

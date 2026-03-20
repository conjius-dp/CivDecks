extends PanelContainer

@onready var materials_label: Label = %MaterialsLabel
@onready var food_label: Label = %FoodLabel


func update_resources(materials: int, food: int) -> void:
	materials_label.text = "Materials: %d" % materials
	food_label.text = "Food: %d" % food

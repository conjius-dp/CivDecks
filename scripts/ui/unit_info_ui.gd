extends PanelContainer

@onready var avatar_rect: ColorRect = %AvatarRect
@onready var unit_name_label: Label = %UnitNameLabel
@onready var health_label: Label = %HealthLabel
@onready var attack_label: Label = %AttackLabel
@onready var defense_label: Label = %DefenseLabel


func update_unit(unit: Node3D) -> void:
	if unit == null:
		visible = false
		return
	visible = true
	avatar_rect.color = unit.avatar_color
	unit_name_label.text = unit.state.unit_name
	health_label.text = "HP: %d/%d" % [unit.state.health, unit.state.max_health]
	attack_label.text = "ATK: %d" % unit.state.attack
	defense_label.text = "DEF: %d" % unit.state.defense

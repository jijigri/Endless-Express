extends HSplitContainer

@onready var portrait: TextureRect = $Portrait
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var description_label: Label = $VBoxContainer/DescriptionLabel
@onready var menu_ability_slot1: MenuAbilitySlot = $VBoxContainer/MenuAbilitySlot1
@onready var menu_ability_slot2: MenuAbilitySlot = $VBoxContainer/MenuAbilitySlot2
@onready var menu_ability_slot3: MenuAbilitySlot = $VBoxContainer/MenuAbilitySlot3

func _ready() -> void:
	initialize(PlayableCharactersPool.characters[0])

func initialize(character_data: PlayableCharacterData) -> void:
	portrait.texture = character_data.portrait
	name_label.text = character_data.display_name
	description_label.text = character_data.description
	menu_ability_slot1.initialize(character_data.abilities[0])
	menu_ability_slot2.initialize(character_data.abilities[1])
	menu_ability_slot3.initialize(character_data.abilities[2])

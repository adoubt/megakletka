extends Resource
class_name DataBase

@export var enemy_configs = {
		"Aboba": {
			"scene": "res://Scenes/Enemy/Aboba.tscn",
			"hp": 10,
			"attack_speed":1.7,
			"collider_radius":0.25,
			"movespeed": 3.0,
			"xp_reward": 2.0
		}
	}
	
@export var poi_configs = {
		"fortune_teller": {
			"scene": "res://Scenes/POI/fortune_teller.tscn",
			"interact_radius": 2.5,
			"collider_radius":1.25,
			"drop_weight": 30,
			"target_priority" : 1
		},
		"wagon": {
			"scene": "res://Scenes/Objects/wagon.tscn",
			
			"interact_radius": 3.5,
			"collider_radius":1.0,
			"target_priority" : 1,
			"slots": 2
		},
}
		#"chest_big": {"scene": "...", "drop_weight": 1},
		#"altar": {"scene": "...", "drop_weight": 2},
		#"merchant": {"scene": "...", "drop_weight": 4},
	

@export var char_configs = {
		"Rigman": {
			"scene": "res://Scenes/Player/Player.tscn",
			"hp": 10,
			"attack_speed_mult":1,
			"collider_radius": 0.15,
			"movespeed": 10,
			"xp_pickup_range": 1.5,
			"weapon_name" : "carrot",
			"slots": 3
		}
	}
	
	
@export var weapon_configs = {
		
		"cheese": {
			"scene": "res://Scenes/Weapons/Projectiles/cheese.tscn",
			"cd": 5,
			"damage" : 4,
			"projectile_count" : 3.0,
			"projectile_radius" : 0.2,
			"weapon_radius": 1.5,
			"projectile_speed": 2.0,
		},
		"carrot": {
			"scene": "res://Scenes/Weapons/Projectiles/carrot.tscn",
			"cd": 5,
			"damage" : 4,
			"projectile_count" : 3.0,
			"projectile_radius" : 0.2,
			"weapon_radius": 1.5,
			"projectile_speed": 2.0,
		},
		"aura":{
			"scene": "res://Scenes/Weapons/AOE/Aura.tscn",
			"cd": 1,
			"damage" : 4,
			"weapon_radius": 1.0,
		}
}
@export var upgrades_configs = {
	
	}

@export var item_configs = {
	"heart_card": {
		"name": "Heart Boost",
		"suit": "hearts",
		"description": "+50% MaxHP",
		"icon": "res://assets/icons/Cards/Sprite-0002.png",
		"scene": "res://Scenes/Items/test_item.tscn",
		"abilities": {"stat": MaxHpMultComponent, "value": 1.5},
		"cost": 50,            # магазинная стоимость
		"drop_weight": 10      # шанс выпасть в апгрейде
	},
	"vamp_card": {
		"name": "Vamp",
		"suit": "hearts",
		"description": "Heal 1% on hit",
		"icon": "res://assets/icons/Cards/Diamonds.png",
		"scene": "res://Scenes/Items/test_item.tscn",
		"abilities": {"stat": LifestealComponent, "value": 0.1},
		"cost": 100,
		"drop_weight": 5
	},
	"projectiles_card": {
		"name": "CHEESUS CHRIST",
		"suit": "spades",
		"description": "+ 1 projectiles",
		"icon": "res://assets/icons/Cards/Spades.png",
		"scene": "res://Scenes/Items/test2_item.tscn",
		"abilities": {"stat": ProjectileCountComponent, "value": 1.0},
		"cost": 100,
		"drop_weight": 30
	},
	"atatck_spades_card": {
		"name": "ATKspeeddddd",
		"suit": "spades",
		"description": "+ 10% attack speed",
		"icon": "res://assets/icons/Cards/Clubs.png",
		"scene": "res://Scenes/Items/test2_item.tscn",
		"abilities": {"stat": AttackSpeedComponent, "value": 0.10},
		"cost": 100,
		"drop_weight": 10
	},
	"destroy_card": {
		"name": "Destroy Card",
		"suit": "spades",
		"description": "[color=red]Destroy[/color] random card",
		"icon": "res://assets/icons/Cards/tiktokcard2.png",
		"scene": "res://Scenes/Items/test2_item.tscn",
		"abilities": {"stat": AttackSpeedComponent, "value": 1.02},
		"cost": 100,
		"drop_weight": 5
	},
	"proj_speed_card": {
		"name": "Faster prog Card",
		"suit": "spades",
		"description": "+1 projectile speed",
		"icon": "res://assets/icons/Cards/Clubs.png",
		"scene": "res://Scenes/Items/test_item.tscn",
		"abilities": {"stat": ProjectileSpeedComponent, "value": 1},
		"cost": 100,
		"drop_weight": 30
	},
	"size_card": {
		"name": "FAT",
		"suit": "Hearts",
		"description": "+50% size",
		"icon": "res://assets/icons/Cards/Hearts.png",
		"scene": "res://Scenes/Items/test_item.tscn",
		"abilities": [
			{"stat": WeaponRadiusComponent, "value": 0.0},
			{"stat": ProjectileRadiusComponent, "value": 0.5}],
		"cost": 100,
		"drop_weight": 99
	},
}	

@export var sound_configs = {
	"diegetic": {
		"one_shot": {
			"enemy_death" : "res://assets/sounds/diegetic/one_shot/enemy_death.wav",
			"enemy_death2" : "res://assets/sounds/diegetic/one_shot/enemy_death_2.wav",
			"enemy_death3" : "res://assets/sounds/diegetic/one_shot/enemy_death_3.wav",
			"enemy_death4" : "res://assets/sounds/diegetic/one_shot/enemy_death_4.wav",
			"enemy_death5" : "res://assets/sounds/diegetic/one_shot/enemy_death_5.wav",
			"enemy_death6" : "res://assets/sounds/diegetic/one_shot/enemy_death_6.wav",
			"enemy_hitted" : "res://assets/sounds/diegetic/one_shot/enemy_damaged.wav",
			"enemy_hitted2" : "res://assets/sounds/diegetic/one_shot/enemy_damaged_2.wav",
		},
		"persistent": {
			
		},
	},
	"non_diegetic": {
		"music": {
			
		},
		"ui": {
			"game_start" : "res://assets/sounds/non_diegetic/ui/Game Start.mp3",
			"level_up" :"res://assets/sounds/non_diegetic/ui/level_up.wav",
			
		},
	}
}

extends Resource
class_name DataBase

var enemy_configs = {
		"Aboba": {
			"scene": "res://Scenes/Enemy/Aboba.tscn",
			"hp": 10,
			"attack_speed":1.7,
			"collider_radius":0.25,
			"movespeed": 3.0,
			"xp_reward": 2.0
		}
	}


var char_configs = {
		"Rigman": {
			"scene": "res://Scenes/Player/Player.tscn",
			"hp": 10,
			"attack_speed_mult":1,
			"collider_radius": 0.15,
			"movespeed": 10,
			"xp_pickup_range": 1.5
		}
	}
	
	
var weapon_configs = {
		
		"cheese": {
			"scene": "res://Scenes/Weapons/Projectiles/cheese.tscn",
			"cd": 5,
			"damage" : 4,
			"projectile_count" : 3.0,
			"projectile_radius" : 0.2,
			"weapon_radius": 1.5,
			"projectile_speed": 5.0,
		},
		"aura":{
			"scene": "res://Scenes/Weapons/AOE/Aura.tscn",
			"cd": 1,
			"damage" : 4,
			"weapon_radius": 1.0,
		}
}
var upgrades_configs = {
	
	}

var card_configs = {
	"heart_card": {
		"name": "Heart Boost",
		"suit": "hearts",
		"description": "+5% MaxHP",
		"icon": "res://assets/icons/Cards/Sprite-0002.png",
		"passive_effect": {"stat": MaxHpComponent, "mult": 0.05},
		"active_effect": null, # если карта можно сыграть
		"cost": 50,            # магазинная стоимость
		"drop_weight": 10      # шанс выпасть в апгрейде
	},
	"vamp_card": {
		"name": "Vampirism",
		"suit": "hearts",
		"description": "Heal 2% on hit",
		"icon": "res://assets/icons/Cards/Diamonds.png",
		"passive_effect": {"stat": LifestealComponent, "add": 0.02},
		"active_effect": null,
		"cost": 100,
		"drop_weight": 5
	},
	"spades_card": {
		"name": "SSSpades",
		"suit": "spades",
		"description": "+ 5 dmg",
		"icon": "res://assets/icons/Cards/Hearts.png",
		"passive_effect": {"stat": DamageComponent, "add": 0.02},
		"active_effect": null,
		"cost": 100,
		"drop_weight": 2
	},
	"atatck_spades_card": {
		"name": "ATKspeeddddd",
		"suit": "spades",
		"description": "+ 5 attack speed",
		"icon": "res://assets/icons/Cards/Clubs.png",
		"passive_effect": {"stat": AttackSpeedComponent, "add": 0.02},
		"active_effect": null,
		"cost": 100,
		"drop_weight": 10
	},
}	

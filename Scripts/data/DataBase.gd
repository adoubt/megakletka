extends Resource
class_name DataBase

@export var enemy_configs = {
		"Aboba": {
			"scene": "res://Scenes/Enemy/Aboba.tscn",
			"hp": 5,
			"attack_speed":1.0,
			"collider_radius":0.6,
			"movespeed": 3.0,
			"weapon_radius": 1.0,
			
			"projectile_radius": 1.0,
			"budget" : 1,
			"pierce": 1,
			"bounce":0,
			"duration": 1.0,
			"agr_radius": 40.0,
			"damage":0.5
		},
		"AbobaWithIceShard": {
			"scene": "res://Scenes/Enemy/AbobaWithIceShard.tscn",
			"hp": 2,
			"attack_speed":5.0,
			"collider_radius":0.5,
			
			"projectile_radius": 1.0,
			"movespeed": 2.0,
			"weapon_radius": 0.2,
			"weapon_name" : "ice_shard",
			"budget" : 2,
			"pierce": 1,
			"bounce":0,
			"duration": 1.0,
			"agr_radius": 40.0,
			"damage":0.5
		}
	}
	
@export var poi_configs = {
		"fortune_teller": {
			"scene": "res://Scenes/POI/fortune_teller.tscn",
			"interact_radius": 2.5,
			"collider_radius":1.25,
			"drop_weight": 2,
			"target_priority" : 1,
			"interact_type": InteractType.PRESS,
			
		},
		"campfire": {
			"scene": "res://Scenes/POI/campfire_poi.tscn",
			
			"interact_radius": 1.5,
			"collider_radius":1.0,
			"target_priority" : 1,
			"slots": 2,
			"interact_type": InteractType.HOLD | InteractType.PRESS,
		},
		"merchant":{
			"scene": "res://Scenes/POI/merchant_poi.tscn",
			"interact_radius": 1.5,
			"collider_radius":1.0,
			"target_priority" : 1,
			"slots": 3,
			"interact_type": InteractType.PRESS,
		},
		"max_hp_mushroom":{
			"scene": "res://Scenes/POI/max_hp_mushroom.tscn",
			"interact_radius": 1.5,
			"collider_radius":0.3,
			"target_priority" : 1,
			"interact_type": InteractType.PRESS,
			"mushroom": true,
			"drop_weight": 20,
		},
		"health_mushroom":{
			"scene": "res://Scenes/POIEntity.tscn",
			"interact_radius": 1.5,
			"collider_radius":0.3,
			"target_priority" : 1,
			"interact_type": InteractType.PRESS,
			"mushroom": true,
			"drop_weight": 0,
		},
		"xp_left_mushroom":{
			"scene": "res://Scenes/POI/xp_left_mushroom.tscn",
			"interact_radius": 1.5,
			"collider_radius":0.3,
			"target_priority" : 1,
			"interact_type": InteractType.PRESS,
			"mushroom": true,
			"drop_weight": 50,
		},
		"log_mushroom":{
			"scene": "res://Scenes/POIEntity.tscn",
			"interact_radius": 1.5,
			"collider_radius":0.3,
			"target_priority" : 1,
			"interact_type": InteractType.PRESS,
			"mushroom": true,
			"drop_weight": 0,
		},
		
}
		#"chest_big": {"scene": "...", "drop_weight": 1},
		#"altar": {"scene": "...", "drop_weight": 2},
		#"merchant": {"scene": "...", "drop_weight": 4},
	

@export var char_configs = {
		"Rigman": {
			"scene": "res://Scenes/Player/character.tscn",
			"hp": 10,
			"damage":1,
			"attack_speed":5.0,
			"attack_speed_mult":1,
			"collider_radius": 0.5,
			"movespeed": 5,
			"projectile_speed" : 1.0,
			"projectile_radius": 1.0,
			"pickup_range": 1.5,
			"weapon_name" : "fire_shard",
			"weapon_radius": 1.0,
			"duration": 1.0,
			"slots": 3,
			"pierce": 10,
			"bounce":0,
			"jumps":1
		}
	}
	
	
@export var weapon_configs = {	

		"fire_shard":{
			"scene": "res://Scenes/Weapons/Projectiles/fire_shard.tscn",
			"cd": 0.3,
			"damage" : 2,
			"projectile_count" : 1.0,
			"projectile_radius" : 0.2,
			"projectile_speed": 10.0,
			"weapon_radius": 30.0,
			"duration": 2.0,
			"pierce": 1,
			"bounce":0,
			"target": TargetType.CAMERA_ASSIST,
			"shadow": true,
		}
		,
		"ice_shard":{
			"scene": "res://Scenes/Weapons/Projectiles/ice_shard.tscn",
			"cd": 3.5,
			"damage" : 1,
			"projectile_count" : 1.0,
			"projectile_radius" : 0.1,
			"projectile_speed": 7.0,
			"weapon_radius": 20.0,
			"duration": 2.5,
			"pierce": 1,
			"bounce":0,
			"target": TargetType.NORMAL,
			"shadow": true,
		}	
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
			"enemy_died": [ "res://assets/sounds/diegetic/one_shot/enemy_death.mp3",
				"res://assets/sounds/diegetic/one_shot/enemy_death_2.mp3",
				"res://assets/sounds/diegetic/one_shot/enemy_death_3.mp3"
				],
			"enemy_hitted": [
				"res://assets/sounds/diegetic/one_shot/enemy_hitted.mp3",
				"res://assets/sounds/diegetic/one_shot/enemy_hitted_2.mp3",
				"res://assets/sounds/diegetic/one_shot/enemy_hitted_3.mp3",
				"res://assets/sounds/diegetic/one_shot/enemy_hitted_4.mp3",
			],
			"custom_sounds": []
		},
		"persistent": {
			"campfire_crackling" : "res://assets/sounds/diegetic/persistent/campfire-crackling-sound.mp3"
		},
	},
	"non_diegetic": {
		"music": {
			"combat_started":[
				
				"res://assets/sounds/non_diegetic/music/idle theme.mp3"
			],
			"combat_completed":[
				"res://assets/sounds/non_diegetic/music/3 ost tera no drums.mp3",
			],
			"game_start" : 
				["res://assets/sounds/non_diegetic/ui/Game Start.mp3",
				],
			"level_up" :
				["res://assets/sounds/non_diegetic/ui/level_up.wav",
				],
			"day_changed" : 
				["res://assets/sounds/non_diegetic/ui/day_changed.mp3",
				],
			"combat_completed_signal":
				["res://assets/sounds/non_diegetic/ui/combat_completed.mp3",
				],
			"combat_started_signal":
				[
				]
			
		},
		"ui": {
			"game_start" : 
				["res://assets/sounds/non_diegetic/ui/Game Start.mp3",
				],
			"level_up" :
				["",
				],
			"day_changed" : 
				["res://assets/sounds/non_diegetic/ui/day_changed.mp3",
				],
			"combat_completed":
				["res://assets/sounds/non_diegetic/ui/combat_completed.mp3",
				],
			"combat_started":
				["",
				]
		},
	}
}

@export var shaders_config = {
	"vhs" : "res://assets/Shaders/PostProcess/vhscamera3.gdshader",
	"vhs2": "res://assets/Shaders/PostProcess/vhs_shader.gdshader",
	"vhs3" : "res://assets/Shaders/PostProcess/VHS3.gdshader",
	"kuwahara" : "res://assets/Shaders/PostProcess/kuwahara.gdshader",
	"vignette" :"res://assets/Shaders/PostProcess/Vignette.gdshader",
	"Film": "res://assets/Shaders/PostProcess/Film.gdshader"
	
	
}

@export var vfx_configs = {
	"base_hit": {
		"scene" : "res://Scenes/hit_particle.tscn",
		"duration" : 0.5
	}
}

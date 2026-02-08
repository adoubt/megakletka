extends Resource
class_name DataBase

@export var enemy_configs = {
	"Aboba": {
		"scene": "res://Scenes/Enemy/Aboba.tscn",
		"hp": 10,
		"attack_speed":1.0,
		"collider_radius":0.7,
		"movespeed": 4.0,
		"weapon_radius": 1.0,
		"weapons" :[
				
		],
		"projectile_radius": 1.0,
		"budget" : 1,
		"pierce": 1,
		"bounce":0,
		"duration": 1.0,
		"agr_radius": 40.0,
		"damage":1.0,
		"damage_mult" :1.0,
		"armor": 10.0
	},
	"AbobaWithIceShard": {
		"scene": "res://Scenes/Enemy/AbobaWithIceShard.tscn",
		"hp": 10,
		"attack_speed":3.0,
		"collider_radius":0.5,
			
		"projectile_radius": 1.0,
		"movespeed": 2.0,
		"weapon_radius": 0.4,
		"weapons" :[
			"ice_shard",],
		"budget" : 2,
		"pierce": 1,
		"bounce":0,
		"duration": 1.0,
		"agr_radius": 40.0,
		"damage":0.0,
		"damage_mult" :1.0,
		"armor": -5.0
	}
}
	
@export var poi_configs = {
	"fortune_teller": {
		"scene": "res://Scenes/POI/fortune_teller.tscn",
		"interact_radius": 2.5,
		"collider_radius":1.25,
		"drop_weight": 0,
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
		"interact_radius": 2.0,
		"collider_radius": 1.0,
		"target_priority" : 1,
		"interact_type": InteractType.PRESS,
		"mushroom": true,
		"drop_weight": 20,
	},
	"health_mushroom":{
		"scene": "res://Scenes/POIEntity.tscn",
		"interact_radius": 1.5,
		"collider_radius":1,
		"target_priority" : 1,
		"interact_type": InteractType.PRESS,
		"mushroom": true,
		"drop_weight": 0,
	},
	"xp_left_mushroom":{
		"scene": "res://Scenes/POI/xp_left_mushroom.tscn",
		"interact_radius": 1.5,
		"collider_radius":1,
		"target_priority" : 1,
		"interact_type": InteractType.PRESS,
		"mushroom": true,
		"drop_weight": 50,
	},
	"log_mushroom":{
		"scene": "res://Scenes/POIEntity.tscn",
		"interact_radius": 1.5,
		"collider_radius":1,
		"target_priority" : 1,
		"interact_type": InteractType.PRESS,
		"mushroom": true,
		"drop_weight": 0,
	},
	"heal_mushroom":{
		"scene": "res://Scenes/POI/heal_mushroom.tscn",
		"interact_radius": 1.5,
		"collider_radius":1,
		"target_priority" : 1,
		"interact_type": InteractType.PRESS,
		"mushroom": true,
		"drop_weight": 10,
	},	
	"damage_for_current_hp_mushroom":{
		"scene": "res://Scenes/POI/damage_for_current_hp_mushroom.tscn",
		"interact_radius": 1.5,
		"collider_radius":1,
		"target_priority" : 1,
		"interact_type": InteractType.PRESS,
		"mushroom": true,
		"drop_weight": 10,
	},
}

	

@export var char_configs = {
	"Rigman": {
		"scene": "res://Scenes/Player/character.tscn",
		"hp": 10,
		"damage":0,
		"attack_speed":5.0,
		"attack_speed_mult":1,
		"collider_radius": 0.5,
		"movespeed": 7,
		"projectile_speed" : 1.0,
		"projectile_radius": 1.0,
		"pickup_range": 1.5,
		"weapons" :[
			"fire_shard",],
		"weapon_radius": 1.0,
		"duration": 1.0,
		"slots": 3,
		"pierce": 3,
		"bounce":0,
		"jumps":1,
		"jump_height": 10.0,
		"merchant_discount": 0,
		"items":[
			"prickly_bundle"
			
		],
		"xp_gain": 1.0,
		"damage_mult" :1.0,
		"armor": 3.0
	}
}
	
	
@export var weapon_configs = {

	"fire_shard":{
		"proj_scene": "res://Scenes/Weapons/Projectiles/fire_shard.tscn",
		"cd": 0.3,
		"damage" : 5,
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
		"proj_scene": "res://Scenes/Weapons/Projectiles/ice_shard.tscn",
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
	"prickly_bundle":{
		"name": "Prickly Bundle",
		"description": "A tiny hedgehog that grows tougher the more you feed it",
		"icon": "res://assets/icons/Cards/Sprite-0002.png",
		"scene": "res://Scenes/Items/prickly_bundle.tscn",
		"abilities": [
			{
				"name": "Prickly Bundle",
				"description": "Gains 0.1 Armor each time you eat a Mushroom",
				"target_stat": Stats.PlayerStats.ARMOR,
				"domain": Stats.Domain.PLAYER,
				"value": 0,
				"trigger": {
					"event":AbilityTriggers.Events.MUSHROOM_EATED,
					"action": AbilityTriggers.Actions.GAIN_VALUE,
					"value": 0.1
					}
				
				
			}
		],
		"cost": 4,
		"drop_weight": 1
	},
	"jump_item": {
		"name": "Jump Item",
		"description": "+ 1 JUMP",
		"icon": "res://assets/icons/Cards/Sprite-0002.png",
		"scene": "res://Scenes/Items/prickly_bundle.tscn",
		"abilities": [
			{
				"name": "extra_jump",
				"target_stat": Stats.PlayerStats.JUMPS_COUNT,
				"domain": Stats.Domain.PLAYER,
				"value": 1
			}
		],
		"cost": 3,
		"drop_weight": 1
	},

	"jump_scale_for_phase": {
		"name": "Jump x Phase",
		"description": "+ JUMP for current PHASE",
		"icon": "res://assets/icons/Cards/Diamonds.png",
		"scene": "res://Scenes/Items/prickly_bundle.tscn",
		"abilities": [
			{
				"name": "jump_scale_for_phase",
				"scaling": {
					"per": 1,
					"source_stat": Stats.GameStats.CURRENT_PHASE,
					"domain": Stats.Domain.GAME,
				},
				"target_stat": Stats.PlayerStats.JUMPS_COUNT,
				"domain": Stats.Domain.PLAYER,
				"value": 1
			}
		],
		"cost": 2,
		"drop_weight": 1
	},

	"LogDiscount": {
		"name": "LogDiscount",
		"description": "Merchant discount 1 LOG",
		"icon": "res://assets/icons/Cards/Spades.png",
		"scene": "res://Scenes/Items/prickly_bundle.tscn",
		"abilities": [
			{
				"name": "log_discount",
				"target_stat": Stats.PlayerStats.MERCHANT_DISCOUNT,
				"domain": Stats.Domain.PLAYER,
				"value": 1
			}
		],
		"cost": 3,
		"drop_weight": 1
	},

	"LogFueledDamage": {
		"name": "LogFueledDamage",
		"description": "+10% DAMAGE for each LOG",
		"icon": "res://assets/icons/Cards/Clubs.png",
		"scene": "res://Scenes/Items/prickly_bundle.tscn",
		"abilities": [
			{
				"name": "log_fueled_damage",
				"target_stat": Stats.PlayerStats.DAMAGE_MULT,
				"domain": Stats.Domain.PLAYER,
				"value": 0.1,
				"scaling": {
					"per": 1,
					"source_stat": Stats.GameStats.LOG_BALANCE,
					"domain": Stats.Domain.GAME,
				}
			}
		],
		"cost": 3,
		"drop_weight": 1
	},

	"LowHPFlex": {
		"name": "LowHPFlex",
		"description": "+2 Jump when Hp below 50%",
		"icon": "res://assets/icons/Cards/Clubs.png",
		"scene": "res://Scenes/Items/mushrooms.tscn",
		"abilities": [
			{
				"name": "low_hp_flex",
				"target_stat": Stats.PlayerStats.JUMPS_COUNT,
				"domain": Stats.Domain.PLAYER,
				"value": 2,
				"condition": {
					"type": ConditionType.BELOW,
					"source_stat": Stats.PlayerStats.CURRENT_HP_RATIO,
					"domain": Stats.Domain.PLAYER,
					"value": 0.5
				}
			}
		],
		"cost": 3,
		"drop_weight": 1
	},
	"FirstPhaseDamage": {
		"name": "FirstPhaseDamage",
		"description": "+50% for PHASE 1",
		"icon": "res://assets/icons/Cards/Clubs.png",
		"scene": "res://Scenes/Items/prickly_bundle.tscn",
		"abilities": [
			{
				"name": "FirstPhaseDamage",
				"target_stat": Stats.PlayerStats.DAMAGE_MULT,
				"domain": Stats.Domain.PLAYER,
				"value": 0.5,
				"condition": {
					"type": ConditionType.EQUAL,
					"source_stat": Stats.GameStats.CURRENT_PHASE,
					"domain": Stats.Domain.GAME,
					"value": 1
				}
			}
		],
		"cost": 3,
		"drop_weight": 1
	},
	"GreenAcorn": {
		"name": "GreenAcorn",
		"title": "Green Acorn",
		"description": "A young acorn, still full of life.",
		"icon": "res://assets/icons/Cards/Clubs.png",
		"scene": "res://Scenes/Items/mushrooms.tscn",
		"abilities": [
			{
				"name": "GreenAcorn",
				"title": "Green Acorn",
				"description":"Slightly increases maximum health.",
				"target_stat": Stats.PlayerStats.MAX_HP,
				"domain": Stats.Domain.PLAYER,
				"value": 3,
				
			}
		],
		"cost": 2,
		"drop_weight": 1
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
				],
			"main_menu":
				["res://assets/sounds/non_diegetic/music/days_passed.mp3",
				],
			"death":
				[
				"res://assets/sounds/non_diegetic/music/death.mp3",
				],
				
				
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
				],
			"menu_select": 
				["res://assets/sounds/non_diegetic/ui/tap4.mp3",
				],
			"note":
				["res://assets/sounds/non_diegetic/ui/note.mp3",
				],
			"note_reward":
				["res://assets/sounds/non_diegetic/ui/reward_counted.mp3",
				],
			"strange_tap":
				["res://assets/sounds/non_diegetic/ui/strange_tap.mp3",
				],
			"settings_select":
				["res://assets/sounds/non_diegetic/ui/tap6.mp3",
				],
			"menu_back": 
				["res://assets/sounds/non_diegetic/ui/tap2.mp3",],
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
	"physics": {
		"scene" : "res://Scenes/hit_particle.tscn",
		"duration" : 0.5
	}
}

extends Node3D

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D

func shot() -> void:
	gpu_particles_3d.restart()
	

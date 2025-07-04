extends FogVolume
#skrypt do "ruchomej" mgły, nie używany w tej wersji, bo mgła jest nie używana
@export var scroll_speed: Vector3 = Vector3(1.0, 0.0, 0.0)
@onready var fog_material := material as FogMaterial
@onready var noise_texture := fog_material.density_texture as NoiseTexture3D

func _process(delta):
	if noise_texture and noise_texture.noise:
		noise_texture.noise.offset += scroll_speed * delta

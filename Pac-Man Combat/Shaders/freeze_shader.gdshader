shader_type canvas_item;

uniform vec2 old_position;
uniform sampler2D noise;

void fragment() {
	//COLOR = vec4(0, 0, 0, 1);
	float height = texture(noise, UV).r;
	//vec4 offset = noise_sample * strength;
	vec4 color = texture(TEXTURE, UV + old_position * height * 0.005);
	COLOR = color;
}

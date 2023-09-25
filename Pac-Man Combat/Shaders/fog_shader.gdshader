shader_type canvas_item;

uniform sampler2D noise_tex: filter_nearest, repeat_enable;
uniform sampler2D noise_tex_2: filter_nearest, repeat_enable;

void fragment() {
	vec2 uv = vec2(UV.x + TIME * 0.08, UV.y);
	vec2 uv_2 = vec2(UV.x - TIME * 0.01, UV.y);
	float a = texture(noise_tex, uv).r;
	a += texture(noise_tex_2, uv_2).r * 0.2;
	a *= clamp(sin(TIME / 2.0) / 4.0 + 1.0, 0.4, 1.0);
	vec4 color = texture(TEXTURE, UV);
	a = round(a * 16.0) / 16.0;
	color.a = smoothstep(0.25, 0.9, a * 0.46) + 0.2;
	COLOR = color;
}

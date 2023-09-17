shader_type canvas_item;

uniform sampler2D noise_tex;

void fragment()
{
	float offset = (sin((UV.y + (TIME * 0.8)) * 25.0)) * (0.006 / 1.0);
	
	float a = clamp(sin(TIME * 3.0) * 0.3 + 1.0, 0.2, 2.0);
	vec4 col = texture(TEXTURE, vec2(UV.x + offset, UV.y + offset));
	col.a *= a;
	
	COLOR = col;
}
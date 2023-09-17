shader_type canvas_item;

uniform vec4 color: source_color;
uniform float strength;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	float s = clamp(strength, 0.0, 1.0);
	col = mix(col, vec4(color.r, color.g, color.b, col.a), s);
	COLOR = vec4(col.rgb, COLOR.a);
}

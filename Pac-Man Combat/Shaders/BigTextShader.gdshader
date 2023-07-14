shader_type canvas_item;

uniform vec4 new_color: source_color;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec2 uv = UV;
	float value = step(0.06, uv.y);
	vec4 replace_col = new_color + value;
	COLOR = vec4(replace_col.r, replace_col.g, replace_col.b, color.a);
}

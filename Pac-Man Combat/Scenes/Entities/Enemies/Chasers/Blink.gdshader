shader_type canvas_item;

uniform vec4 flash_color: source_color = vec4(1.0);
uniform float flash_modifier: hint_range(0.0, 1.0, 0.05);

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	col.rgb = mix(col.rgb, flash_color.rgb, flash_modifier);
	COLOR = col;
}

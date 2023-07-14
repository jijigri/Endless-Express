shader_type canvas_item;

uniform vec4 flash_color: source_color = vec4(1.0);
uniform float flash_modifier: hint_range(0.0, 1.0, 0.05);
uniform vec4 color1: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 color2: source_color = vec4(1.0);

bool colorMatch(vec4 c1, vec4 c2, float maxDiff) {
    return (
        abs(c1.r - c2.r) < maxDiff
        && abs(c1.g - c2.g) < maxDiff
        && abs(c1.b - c2.b) < maxDiff
		&& abs(c1.a - c2.a) < maxDiff
    );
}

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	if (colorMatch(col, vec4(0.0, 0.0, 0.0, 1.0), 0.01))
	{
		col = color2;
	}
	else
	{
		col = color1;
	}


	vec4 modulate = COLOR;
	col.rgb = mix(col.rgb, flash_color.rgb, flash_modifier);
	col.a = modulate.a;
	COLOR = col;
}

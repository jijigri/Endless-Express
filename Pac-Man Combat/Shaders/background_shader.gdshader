shader_type canvas_item;

uniform sampler2D SCREEN_TEXT: hint_screen_texture, filter_linear_mipmap;

uniform vec4 BG_COLOR_1: source_color;
uniform vec4 BG_COLOR_2: source_color;
uniform vec4 BG_COLOR_3: source_color;

uniform vec4 NEW_COLOR: source_color;

uniform float STRENGTH;

bool colorMatch(vec4 c1, vec4 c2, float maxDiff) {
    return (
        abs(c1.r - c2.r) < maxDiff
        && abs(c1.g - c2.g) < maxDiff
        && abs(c1.b - c2.b) < maxDiff
		&& abs(c1.a - c2.a) < maxDiff
    );
}

void fragment() {
	vec4 screen = texture(SCREEN_TEXT, SCREEN_UV);
	
	if (colorMatch(screen, BG_COLOR_1, 0.01))
	{
		COLOR = mix(screen, NEW_COLOR, STRENGTH);
	}
	else if (colorMatch(screen, BG_COLOR_2, 0.01))
	{
		COLOR = mix(screen, NEW_COLOR, STRENGTH);
	}
	else if (colorMatch(screen, BG_COLOR_3, 0.01))
	{
		COLOR = mix(screen, NEW_COLOR, STRENGTH);
	}
	else
	{
		COLOR = screen;
	}
}

shader_type canvas_item;

uniform float STRENGTH;

uniform vec4 OLD_COLOR1 : source_color;
uniform vec4 OLD_COLOR2 : source_color;
uniform vec4 OLD_COLOR3 : source_color;
uniform vec4 OLD_COLOR4 : source_color;

uniform vec4 NEW_COLOR1 : source_color;
uniform vec4 NEW_COLOR2 : source_color;
uniform vec4 NEW_COLOR3 : source_color;
uniform vec4 NEW_COLOR4 : source_color;

bool colorMatch(vec4 c1, vec4 c2, float maxDiff) {
    return (
        abs(c1.r - c2.r) < maxDiff
        && abs(c1.g - c2.g) < maxDiff
        && abs(c1.b - c2.b) < maxDiff
		&& abs(c1.a - c2.a) < maxDiff
    );
}

void fragment() {
	vec4 curr_color = texture(TEXTURE, UV);
	
	if (colorMatch(curr_color, OLD_COLOR1, 0.01))
	{
		COLOR = mix(curr_color, NEW_COLOR1, STRENGTH);
	}
	if (colorMatch(curr_color, OLD_COLOR2, 0.01))
	{
		COLOR = mix(curr_color, NEW_COLOR2, STRENGTH);
	}
	if (colorMatch(curr_color, OLD_COLOR3, 0.01))
	{
		COLOR = mix(curr_color, NEW_COLOR3, STRENGTH);
	}
	if (colorMatch(curr_color, OLD_COLOR4, 0.01))
	{
		COLOR = mix(curr_color, NEW_COLOR4, STRENGTH);
	}
}
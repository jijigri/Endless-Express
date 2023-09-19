shader_type canvas_item;

uniform float strength;

void fragment() {
	COLOR = texture(TEXTURE, UV);
    float avg = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
	vec3 col = mix(COLOR.rgb, vec3(avg), clamp(strength, 0.0, 1.0));
    COLOR.rgb = col;
}

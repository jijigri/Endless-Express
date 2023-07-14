shader_type canvas_item;

uniform float size;
uniform float force;
uniform float thickness;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 vecToCenter = vec2(1, 1) - UV;
	float mask = (1.0 - smoothstep(size-0.05, size, length(UV - vecToCenter)))
	* smoothstep(size-thickness-0.05, size-thickness, length(UV - vecToCenter));;
	vec2 disp = normalize(SCREEN_UV - vecToCenter) * force * mask;
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - disp);
}

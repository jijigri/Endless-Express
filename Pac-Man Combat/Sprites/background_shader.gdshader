shader_type canvas_item;

uniform sampler2D SCREEN_TEXT: hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 screen = texture(SCREEN_TEXT, SCREEN_UV);
	COLOR = screen;
	}

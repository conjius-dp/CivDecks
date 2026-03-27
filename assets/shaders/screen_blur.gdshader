shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 8.0) = 3.0;
uniform vec4 tint_color : source_color = vec4(0.0, 0.0, 0.0, 0.5);

void fragment() {
	vec2 ps = SCREEN_PIXEL_SIZE * blur_amount;
	vec4 c = vec4(0.0);
	c += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-ps.x, -ps.y));
	c += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, -ps.y));
	c += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(ps.x, -ps.y));
	c += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-ps.x, 0.0));
	c += texture(SCREEN_TEXTURE, SCREEN_UV);
	c += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(ps.x, 0.0));
	c += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-ps.x, ps.y));
	c += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, ps.y));
	c += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(ps.x, ps.y));
	c /= 9.0;
	COLOR = mix(c, tint_color, tint_color.a);
}

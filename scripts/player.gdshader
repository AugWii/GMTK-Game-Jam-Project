shader_type canvas_item;

uniform bool is_vulnerable = false;

uniform vec4 tint_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float tint_amount : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	if (is_vulnerable) {
		vec4 tex_color = texture(TEXTURE, UV);
		vec4 final_color = mix(tex_color, tint_color, tint_amount);
		COLOR = vec4(final_color.rgb, tex_color.a);
	}
}

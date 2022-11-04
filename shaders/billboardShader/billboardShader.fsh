//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 final_color = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
    if (final_color.a < 0.1) discard;
    gl_FragColor = v_vColour;
}

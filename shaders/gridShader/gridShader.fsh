//
// Simple passthrough fragment shader
//
varying vec4 v_vColour;
varying vec3 v_vWorldPosition;

void main()
{
    gl_FragColor = v_vColour;
}

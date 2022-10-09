//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)

varying vec4 v_vColour;
varying vec3 v_vWorldPosition;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
	v_vWorldPosition = (gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos).xyz;
	
    v_vColour = vec4(.25, .25, .25, 1.);
}

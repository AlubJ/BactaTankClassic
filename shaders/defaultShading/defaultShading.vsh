// Lighting

// Attributes
attribute vec3 in_Position;                  // (x,y,z)
attribute vec3 in_Normal;                    // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

// Out to Fragment Shader
varying vec2 v_Texcoord;
varying vec4 v_Colour;
varying vec3 v_worldNormal;
varying vec4 v_viewNorm;
varying vec4 v_viewPos;
varying vec4 v_normal;

void main() {
	// Default
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
	
	// Attributes
    v_Colour = in_Colour;
    v_Texcoord = in_TextureCoord;
	
	// Out to Fragment Shader
	v_worldNormal = normalize(gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.)).xyz;
    v_viewNorm = gm_Matrices[MATRIX_WORLD_VIEW] * vec4(in_Normal, 0.0);
    v_viewPos = gm_Matrices[MATRIX_WORLD_VIEW] * object_space_pos;
    v_normal = gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0);
}

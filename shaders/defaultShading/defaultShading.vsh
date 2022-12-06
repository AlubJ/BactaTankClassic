// Lighting

// Attributes
attribute vec3 in_Position;                  // (x,y,z)
attribute vec3 in_Normal;                    // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)
attribute vec2 in_index;

// Out to Fragment Shader
varying vec2 v_Texcoord;
varying vec3 v_position;
varying vec4 v_Colour;
varying vec3 v_worldNormal;
varying vec4 v_viewNorm;
varying vec4 v_viewPos;
varying vec4 v_normal;

uniform vec3 dynamicBuffer[4000];

void main() {
	// Default
	vec3 pos = in_Position + dynamicBuffer[int(in_index.x)];
    vec4 object_space_pos = vec4( pos.x, pos.y, pos.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
	
	// Attributes
    v_Colour = in_Colour;
    v_Texcoord = in_TextureCoord;
	v_position = (gm_Matrices[MATRIX_WORLD] * vec4(in_Position, 1.0)).xyz;
	
	// Out to Fragment Shader
	v_worldNormal = normalize(gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.)).xyz;
    v_viewNorm = gm_Matrices[MATRIX_WORLD_VIEW] * vec4(in_Normal, 0.0);
    v_viewPos = gm_Matrices[MATRIX_WORLD_VIEW] * object_space_pos;
    v_normal = gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0);
}

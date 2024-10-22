//
// Simple passthrough fragment shader
//

// Uniforms
uniform vec3 lightDirection;
uniform vec4 lightColour;
uniform vec4 colour;
uniform float shiny;
uniform float useTexture;
uniform float useLighting;
uniform float useNormalMap;

// Load Cubemap Textures
uniform sampler2D cubeMap0;
uniform sampler2D cubeMap1;
uniform sampler2D normalMap;

// View Matrix
uniform mat4 invView;

// In from Vertex Shader
varying vec2 v_Texcoord;
varying vec3 v_position;
varying vec4 v_Colour;
varying vec3 v_worldNormal;
varying vec4 v_viewNorm;
varying vec4 v_viewPos;
varying vec4 v_normal;

//Function to find largest component of vec3. returns 0 for x, 1 for y, 2 for z
int argmax3 (vec3 v){
    return v.y > v.x ? ( v.z > v.y ? 2 : 1 ) : ( v.z > v.x ? 2 : 0 );
}

/* Sample cube map:
    dir is the vector (in world space) from the center of the cube that will be extended.
    The point at which this extended vector "intersects" the cube is the sampling location.
*/
vec4 getCubeMapColor(vec3 dir){
    vec3 absDir = abs(dir);
    vec3 dirOnCube; //Scaled version of dir to land on unit cube.
    vec2 uv; //Texture coordinates on the corresponding surface
    
    int samplerIndex; //What surface to sample, i.e. which face of the cube do we land on?
    
    /* Therefor we simply check which entry of dir is the largest.
        This corresponds to the axis of (i.e. perpendicular to) the cube face the vector will land on.
    */
    int maxInd = argmax3(absDir); 
    if (maxInd == 0){ //x
        //Rescale dir to land on unit cube
        dirOnCube = dir / dir.x;
        
        //Calculate location on the face from remaining vector components and rescale them to fit surface orientation.
        uv = vec2(dirOnCube.y, -sign(dir.x) * dirOnCube.z);
        
        //Select cube map surface sampler from max component's sign (i.e. do we hit the face in fron or behind?)
        samplerIndex = dir.x < 0.0 ? 1 : 0;
    }else if (maxInd == 1){ //y
        //Rescale dir to land on unit cube
        dirOnCube = dir / dir.y;
        
        //Calculate location on the face from remaining vector components and rescale them to fit surface orientation.
        uv = vec2(sign(dir.y) * dirOnCube.x, -sign(dir.y) * dirOnCube.z);
        
        //Select cube map surface sampler from max component's sign (i.e. do we hit the face in fron or behind?)
        samplerIndex = dir.y < 0.0 ? 3 : 2;
    }else{ //z
        //Rescale dir to land on unit cube
        dirOnCube = dir / dir.z;
        
        //Calculate location on the face from remaining vector components and rescale them to fit surface orientation.
        uv = vec2(-dirOnCube.x, sign(dir.z) * dirOnCube.y);
        
        //Select cube map surface sampler from max component's sign (i.e. do we hit the face in fron or behind?)
        samplerIndex = dir.z < 0.0 ? 5 : 4;
    }
    
    //Rescale surface coords from [-1,1] to [0,1]
    uv = (uv + vec2(1.0)) * 0.5;
    
    //Read color value from corresponding surface
    if (samplerIndex == 0){
        return texture2D(cubeMap1, uv);
    }else if (samplerIndex == 1){
        return texture2D(cubeMap1, uv);
    }else if (samplerIndex == 2){
        return texture2D(cubeMap0, uv);
    }else if (samplerIndex == 3){
        return texture2D(cubeMap1, uv);
    }else if (samplerIndex == 4){
        return texture2D(cubeMap1, uv);
    }else {
        return texture2D(cubeMap1, uv);
    }
}

void main()
{
	// Original Colour
    vec4 startColour = colour * texture2D(gm_BaseTexture, v_Texcoord);
	
	// Discard Alpha
	if (startColour.a < 0.5) discard;
	
	// Ambiant
    vec4 ambient = vec4(0.5, 0.5, 0.5, 1.);
	
	// Default Normal
	vec3 normal = v_worldNormal;
	vec3 viewNormal = v_viewNorm.xyz;
	
	// Normal Map
	if (useNormalMap == 4.)
	{
		vec4 normalTexture = texture2D(normalMap, v_Texcoord);
		normal = vec3(normalTexture.a, normalTexture.g, normalTexture.b);
		normal = -normalize(normal * 2.0 - 1.0);
		normal = v_worldNormal * normal;
		viewNormal = -v_viewNorm.xyz * normal;
	}
	
	// Diffuse Lighting
    vec3 lightDir = normalize(-lightDirection);
	vec4 diffuse = lightColour * max(dot(vec3(normal.x, normal.y, normal.z), lightDir), 0.);
	
	// Cubemap Reflections
    // (View space) vector from camera to fragment (cam pos in view space is (0,0,0))
    vec3 d = v_viewPos.xyz;
    
    // Normal
	vec3 norm = vec3(-viewNormal.x, -viewNormal.y, -viewNormal.z);
    vec3 n = normalize(norm.xyz);
    
    // Reflect d around normal n
    vec3 view_r = d - 2.0 * dot(d, n) * n;
    
    // Transform reflection vector to world space using inverse view matrix
    vec4 world_r = invView * vec4(view_r.xyz, 0.0);
    
    //Read cube map color from reflection vector and interpolate between reflected color and texture color.
	vec4 cubeMap = getCubeMapColor(world_r.xyz);
	
	// Output
    vec4 fragColour = startColour;
	
	// Lighting
	if (useLighting == .0) fragColour *= vec4((ambient + diffuse).rgb, startColour.a);

	// Shiny
	//if (shiny == 1.) fragColour += (cubeMap * vec4((vec4(0., 0., 0., 1.) + diffuse).rgb, startColour.a));
	if (shiny == 1.)
	{
		// Specular
		float specularLight = .3;
		vec3 viewDirection = -normalize(v_viewPos.xyz - v_position);
		vec3 reflectionDirection = reflect(lightDir, viewNormal);
	
		float specularAmount = pow(max(dot(viewDirection, reflectionDirection), 0.0), 16.);
		
		vec3 specular = specularAmount * specularLight * lightColour.rgb;
		
		fragColour += vec4(specular * (vec4(0.) + diffuse).rgb, startColour.a);
	}
	
	gl_FragColor = fragColour;
}

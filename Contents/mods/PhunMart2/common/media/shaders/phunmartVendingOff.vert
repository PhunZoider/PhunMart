#version 330

layout (location = 0) in vec4 vertex;
layout (location = 1) in vec4 normal;
layout (location = 2) in vec4 boneWeights;
layout (location = 3) in vec4 boneIndices;
layout (location = 4) in vec2 uv;

out vec3 vertColour;
out vec3 vertNormal;
out vec2 texCoords;

uniform mat4 ModelViewProjection;
uniform float targetDepth = 0.5;
uniform float DepthBias;
uniform mat4 MatrixPalette[60];
uniform vec2 UVScale = vec2(1,1);
uniform float HighResDepthMultiplier = 0.0; // 0.5 when drawing models to double-sized chunk textures
uniform float FinalScale = 1.0;

void main()
{
	vec4 position = vec4(vertex.xyz, 1.0);
	vec4 normal = vec4(normal.xyz, 0.0);

	texCoords = uv * UVScale.xy;

	mat4 boneEffect = mat4(0.0);
	if(boneWeights.x > 0.0)
		boneEffect += MatrixPalette[int(boneIndices.x)] * boneWeights.x;
	if(boneWeights.y > 0.0)
		boneEffect += MatrixPalette[int(boneIndices.y)] * boneWeights.y;
	if(boneWeights.z > 0.0)
		boneEffect += MatrixPalette[int(boneIndices.z)] * boneWeights.z;
	if(boneWeights.w > 0.0)
		boneEffect += MatrixPalette[int(boneIndices.w)] * boneWeights.w;

	normal = boneEffect * normal;
	vertNormal = normal.xyz;

#if 1
	vertColour = vec3(1.0);
#else
	vec3 scalevec;
	mat4 m = boneEffect;

    scalevec.x = length(vec3(m[0][0], m[0][1], m[0][2]));
    scalevec.y = length(vec3(m[1][0], m[1][1], m[1][2]));
    scalevec.z = length(vec3(m[2][0], m[2][1], m[2][2]));
    float scale = length(scalevec);
	float blood = scale;
	blood = clamp(blood, 0.0, 0.01)  * 100.0;
	vertColour = vec3(1.0,blood,blood);


#endif

	vec4 positionScaled = boneEffect * position;
	positionScaled.xyz *= FinalScale;
	vec4 o = ModelViewProjection * positionScaled;

	vec4 origin = ModelViewProjection * vec4(0, 0, 0, 1);
	o.z += (origin.z - o.z) * HighResDepthMultiplier;

//	o.z -= DepthBias;
//	o.z /= 16.0f;
	float clip = ((o.z+1.0) / 2.0); // -1,+1 -> 0,2 -> 0,1
	clip += targetDepth - 0.5;
	o.z = (clip*2)-1; // 0-1 -> 0-2 -> -1,+1

	gl_Position = o;
}

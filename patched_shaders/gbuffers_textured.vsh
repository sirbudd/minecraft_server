#version 150 core
#define varying out
#define attribute in
#define gl_Vertex vec4(Position, 1.0)
#define gl_ModelViewProjectionMatrix (gl_ProjectionMatrix * gl_ModelViewMatrix)
#define gl_ModelViewMatrix (iris_ModelViewMat * _iris_internal_translate(iris_ChunkOffset))
#define gl_NormalMatrix mat3(transpose(inverse(gl_ModelViewMatrix)))
#define gl_Normal vec3(0.0, 0.0, 1.0)
#define gl_Color iris_ColorModulator
#define gl_MultiTexCoord7  vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord6  vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord5  vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord4  vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord3  vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord2  vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord1 vec4(240.0, 240.0, 0.0, 1.0)
#define gl_MultiTexCoord0 vec4(UV0, 0.0, 1.0)
#define gl_ProjectionMatrix iris_ProjMat
#define gl_FrontColor iris_FrontColor
#define gl_FogFragCoord iris_FogFragCoord
uniform mat4 iris_LightmapTextureMatrix;
uniform mat4 iris_TextureMat;
uniform float iris_FogDensity;
uniform float iris_FogStart;
uniform float iris_FogEnd;
uniform vec4 iris_FogColor;

struct iris_FogParameters {
    vec4 color;
    float density;
    float start;
    float end;
    float scale;
};

iris_FogParameters iris_Fog = iris_FogParameters(iris_FogColor, iris_FogDensity, iris_FogStart, iris_FogEnd, 1.0 / (iris_FogEnd - iris_FogStart));

#define gl_Fog iris_Fog
out float iris_FogFragCoord;
vec4 iris_FrontColor;
uniform mat4 iris_ProjMat;
in vec2 UV0;
uniform vec4 iris_ColorModulator;
uniform mat4 iris_ModelViewMat;
uniform vec3 iris_ChunkOffset;
mat4 _iris_internal_translate(vec3 offset) {
    // NB: Column-major order
    return mat4(1.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 0.0, 0.0,
                0.0, 0.0, 1.0, 0.0,
                offset.x, offset.y, offset.z, 1.0);
}
in vec3 Position;
vec4 ftransform() { return gl_ModelViewProjectionMatrix * gl_Vertex; }
vec4 texture2D(sampler2D sampler, vec2 coord) { return texture(sampler, coord); }
vec4 texture2DLod(sampler2D sampler, vec2 coord, float lod) { return textureLod(sampler, coord, lod); }
vec4 shadow2D(sampler2DShadow sampler, vec3 coord) { return vec4(texture(sampler, coord)); }
vec4 shadow2DLod(sampler2DShadow sampler, vec3 coord, float lod) { return vec4(textureLod(sampler, coord, lod)); }














































































































































































































































































































































































































/*
Sildur's Enhanced Default:
https://www.patreon.com/Sildur
https://sildurs-shaders.github.io/
https://twitter.com/Sildurs_shaders
https://www.curseforge.com/minecraft/customization/sildurs-enhanced-default

Permissions:
You are not allowed to edit, copy code or share my shaderpack under a different name or claim it as yours.
*/


/*
Sildur's Enhanced Default:
https://www.patreon.com/Sildur
https://sildurs-shaders.github.io/
https://twitter.com/Sildurs_shaders
https://www.curseforge.com/minecraft/customization/sildurs-enhanced-default

Permissions:
You are not allowed to edit, copy code or share my shaderpack under a different name or claim it as yours.
*/

    
    

    

    
    
    

    
    
    

    
    
    



    
    

    
    



    

    
	
        
	    
	    
	
    
	    

    
        



    



    //#define Colorboost                        //Gives default colors a little kick

    

    

    
        
        

    
    
    
    
    
    const int 	shadowMapResolution = 1024;		//Shadows resolution. [512 1024 2048 3072 4096 8192]
    const float shadowDistance = 90.0;			//Draw distance of shadows.[60.0 90.0 120.0 150.0 180.0 210.0]
    const float shadowDistanceRenderMul = 1.0f;
    const bool 	shadowHardwareFiltering0 = true;
    const bool 	shadowHardwareFiltering1 = true;
    
    const float	sunPathRotation	= -40.0f;		//[-10.0 -20.0 -30.0 -40.0f -50.0 -60.0 -70.0 -80.0 -0.15f -0.0 10.0 20.0 30.0 40.0 50.0 60.0 70.0 80.0]

    

    
    
    
    
    //#define draw_bmap                         //Draw bmap normals

    //#define customLight                       //Toggle custom light support for emissive blocks.
    
    
    

    
    
    
    
    
    
    
    
    
    
    

    //#define TAA



    
    
    


//Moving entities IDs
//See block.properties for mapped ids


















varying vec4 color;
varying vec3 vworldpos;
varying mat3 tbnMatrix;
varying vec2 texcoord;
varying vec2 lmcoord;
varying float iswater;
varying float mat;

attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;
attribute vec4 at_tangent;                      //xyz = tangent vector, w = handedness, added in 1.7.10

uniform vec3 cameraPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

//moving stuff
uniform float frameTimeCounter;
const float PI = 3.14;
float pi2wt = (150.79*frameTimeCounter) * 1.0;

vec3 calcWave(in vec3 pos, in float fm, in float mm, in float ma, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5) {
	float magnitude = sin(pi2wt*fm + dot(pos, vec3(0.5))) * mm + ma;
	vec3 d012 = sin(vec3(f0, f1, f2)*pi2wt);
	
    vec3 ret;
		 ret.x = pi2wt*f3 + d012.x + d012.y - pos.x + pos.z + pos.y;
		 ret.z = pi2wt*f4 + d012.y + d012.z + pos.x - pos.z + pos.y;
		 ret.y = pi2wt*f5 + d012.z + d012.x + pos.z + pos.y - pos.y;
		 ret = sin(ret)*magnitude;
	
    return ret;
}

vec3 calcMove(in vec3 pos, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5, in vec3 amp1, in vec3 amp2) {
    vec3 move1 = calcWave(pos      , 0.0027, 0.0400, 0.0400, 0.0127, 0.0089, 0.0114, 0.0063, 0.0224, 0.0015) * amp1;
	vec3 move2 = calcWave(pos+move1, 0.0348, 0.0400, 0.0400, f0, f1, f2, f3, f4, f5) * amp2;
    return move1+move2;
}/*---*/


varying float NdotL;
varying vec3 getShadowpos;
uniform vec3 shadowLightPosition;
uniform mat4 shadowProjection;
uniform mat4 shadowModelView;


vec3 calcShadows(in vec3 shadowpos, in vec3 norm){
	shadowpos = mat3(shadowModelView) * shadowpos + shadowModelView[3].xyz;
	shadowpos = vec3((shadowProjection)[0].x, (shadowProjection)[1].y, (shadowProjection)[2].z) * shadowpos + shadowProjection[3].xyz;

	float distortion = ((1.0 - 0.80) + length(shadowpos.xy * 1.25) * 0.80) * 0.85;
	shadowpos.xy /= distortion;
	
	NdotL = clamp(dot(norm, normalize(shadowLightPosition))*1.02-0.02,0.0,1.0);	
	float bias = distortion*distortion*(0.0046*tan(acos(NdotL)));
	
	//Certain things shouldn't be diffused, also adjust bias for cheap self shadowing fix
	if (mc_Entity.x == 10031.0
	|| mc_Entity.x == 10175.0
	|| mc_Entity.x == 10176.0
	|| mc_Entity.x == 10059.0
	|| mc_Entity.x == 10018.0
	|| mc_Entity.x == 10106.0
	|| mc_Entity.x == 10111.0
	|| mc_Entity.x == 10051.0
	|| mc_Entity.x == 10090.0	
	|| mc_Entity.x == 10089.0	
	|| mc_Entity.x == 10030.0	//cobweb	
	|| mc_Entity.x == 10115.0 //nether wart
	|| mc_Entity.x == 10576.0 //spore blossom	
	|| mc_Entity.x == 10006.0) {
		NdotL = 0.75;
		bias = 0.0010;
	}
	shadowpos.xyz = shadowpos.xyz * 0.5 + 0.5;
	shadowpos.z -= bias;

	return shadowpos.xyz;
}
















								
								
								
								
								
								
								


void main() {

	//Positioning
	texcoord = (iris_TextureMat * gl_MultiTexCoord0).xy;
	lmcoord = (iris_LightmapTextureMatrix * gl_MultiTexCoord1).xy;
	vec3 position = mat3(gbufferModelViewInverse) * (gl_ModelViewMatrix * gl_Vertex).xyz + gbufferModelViewInverse[3].xyz;

	vworldpos = position.xyz + cameraPosition;
	bool istopv = gl_MultiTexCoord0.t < mc_midTexCoord.t;


if (mc_Entity.x == 10175.0 && istopv || mc_Entity.x == 10176.0)
			position.xyz += calcMove(vworldpos.xyz,
			0.0041,
			0.0070,
			0.0044,
			0.0038,
			0.0240,
			0.0000,
			vec3(0.8,0.0,0.8),
			vec3(0.4,0.0,0.4));


if (istopv) {

	if ( mc_Entity.x == 10031.0)
			position.xyz += calcMove(vworldpos.xyz,
				0.0041,
				0.0070,
				0.0044,
				0.0038,
				0.0063,
				0.0000,
				vec3(3.0,1.6,3.0),
				vec3(0.0,0.0,0.0));


	if (mc_Entity.x == 10059.0)
			position.xyz += calcMove(vworldpos.xyz,
			0.0041,
			0.0070,
			0.0044,
			0.0038,
			0.0240,
			0.0000,
			vec3(0.8,0.0,0.8),
			vec3(0.4,0.0,0.4));


	if ( mc_Entity.x == 10051.0)
			position.xyz += calcMove(vworldpos.xyz,
			0.0105,
			0.0096,
			0.0087,
			0.0063,
			0.0097,
			0.0156,
			vec3(1.2,0.4,1.2),
			vec3(0.8,0.8,0.8));

}


	if ( mc_Entity.x == 10018.0)
			position.xyz += calcMove(vworldpos.xyz,
			0.0040,
			0.0064,
			0.0043,
			0.0035,
			0.0037,
			0.0041,
			vec3(1.0,0.2,1.0),
			vec3(0.5,0.1,0.5));


	if ( mc_Entity.x == 10106.0)
			position.xyz += calcMove(vworldpos.xyz,
			0.0040,
			0.0064,
			0.0043,
			0.0035,
			0.0037,
			0.0041,
			vec3(0.5,1.0,0.5),
			vec3(0.25,0.5,0.25));

	if (mc_Entity.x == 10177.0 && gl_MultiTexCoord0.t > mc_midTexCoord.t)
			position.xyz += calcMove(vworldpos.xyz,
			0.0041,
			0.0070,
			0.0044,
			0.0038,
			0.0240,
			0.0000,
			vec3(0.8,0.0,0.8),
			vec3(0.4,0.0,0.4));				


	if(mc_Entity.x == 10010.0){
		float fy = fract(vworldpos.y + 0.001);
		float wave = 0.05 * sin(2 * PI * (frameTimeCounter*0.2 + vworldpos.x /  7.0 + vworldpos.z / 13.0))
				   + 0.05 * sin(2 * PI * (frameTimeCounter*0.15 + vworldpos.x / 11.0 + vworldpos.z /  5.0));
		position.y += clamp(wave, -fy, 1.0-fy)*0.5;
	}

	iswater = 0.0;
	if(mc_Entity.x == 10008.0)iswater = 0.95;	//don't fully remove shadows on water plane

	if(mc_Entity.x == 10008.0 || mc_Entity.x == 10111.0) { //water, lilypads
		float fy = fract(vworldpos.y + 0.001);
		float wave = 0.05 * sin(2 * PI * (frameTimeCounter*0.8 + vworldpos.x /  2.5 + vworldpos.z / 5.0))
				   + 0.05 * sin(2 * PI * (frameTimeCounter*0.6 + vworldpos.x / 6.0 + vworldpos.z /  12.0));
		position.y += clamp(wave, -fy, 1.0-fy)*0.65;
	}



	if(mc_Entity.x == 10090.0){
		vec3 fxyz = fract(vworldpos.xyz + 0.001);
		float wave = 0.025 * sin(2 * PI * (frameTimeCounter*0.4 + vworldpos.x * 0.5 + vworldpos.z * 0.5));
					//+ 0.025 * sin(2 * PI * (frameTimeCounter*0.4 + worldpos.y *0.25 + worldpos.z *0.25));
		float waveY = 0.05 * cos(frameTimeCounter*2.0 + vworldpos.y);
		position.x -= clamp(wave, -fxyz.x, 1.0-fxyz.x);
		position.y += clamp(waveY*0.25, -fxyz.y, 1.0-fxyz.y)+0.015;		
		position.z += clamp(wave*0.45, -fxyz.z, 1.0-fxyz.z);
	}


mat = 0.0;


	if(mc_Entity.x == 10008.0)mat = 1.0;


	if(mc_Entity.x == 10079.0)mat = 2.0; //various ids are mapped to ice in block.properties



	gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(position, 1.0);


	


	//Fog
	gl_FogFragCoord = length(position.xyz);

	color = gl_Color;

	//Fix colors on emissive blocks
	if(mc_Entity.x == 10089.0 || mc_Entity.x == 10010.0 || mc_Entity.x == 10051.0 ||  mc_Entity.x == 10090.0 || mc_Entity.x == 10300.0)color = vec4(1.0);

	//Bump & Parallax mapping
	vec3 normal = normalize(gl_NormalMatrix * gl_Normal);	
	vec3 tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
	vec3 binormal = normalize(gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);
	tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
					 tangent.y, binormal.y, normal.y,
					 tangent.z, binormal.z, normal.z);


	
	
	
	
	
	
	
	
	
	

	

	getShadowpos = calcShadows(position, normal);

}



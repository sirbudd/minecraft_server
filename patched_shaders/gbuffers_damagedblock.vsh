#version 150 core
#define varying out
#define attribute in
#define gl_Vertex vec4(Position, 1.0)
#define gl_ModelViewProjectionMatrix (gl_ProjectionMatrix * gl_ModelViewMatrix)
#define gl_ModelViewMatrix (iris_ModelViewMat * _iris_internal_translate(iris_ChunkOffset))
#define gl_NormalMatrix mat3(transpose(inverse(gl_ModelViewMatrix)))
#define gl_Normal Normal
#define gl_Color (Color * iris_ColorModulator)
#define gl_MultiTexCoord7  vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord6  vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord5  vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord4  vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord3  vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord2  vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord1 vec4(UV2, 0.0, 1.0)
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
in ivec2 UV2;
uniform vec4 iris_ColorModulator;
in vec4 Color;
in vec3 Normal;
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
Thank you for downloading Sildur's vibrant shaders, make sure you got it from the official source found here:
https://sildurs-shaders.github.io/
*/

    
    
    
    
    
    
    
    
    
    
    
    
        
    
    



    
    
    
    
    
    
    
    
    
    
        

    
        
    

    

    
        
	    

    

    

    

    
    
    
    
    
    
        
    

    
    
    
    



	
    
	
		
	

	
	
	
		
        
    
		
		

	
		
		
		
        

	
	
	
    
    
    
    

    
    
    
    

	
	
	

	

    
    

	
	
	

    
        
    
    
        
    



    //#define TAA							        //Toggle temporal anti-aliasing (TAA)
    

    //#define Adaptive_sharpening			    //Toggle adaptive sharpening. Recommended to use with TAA. Disabling TAA also disables adaptive sharpening.
    



    



    
    



    

    

    

    
	    
        

    

    
	
    
    
    
    
    
	

    

 

    



    
    
    
    

    //#define metallicRefl        //Toggle reflections for blocks defined in block.properties
    //#define polishedRefl        //Toggle reflections for polished blocks defined in block.properties

    
    
    
    
    
    
    
    
    
    



    
    
    
    
    



    
    
    

    
    
    
    

    
    
    
    

    
    
    



    



	
    
	
	


//Moving entities IDs
//See block.properties for mapped ids















varying vec4 color;
varying vec4 texcoord;

varying vec4 normal;
varying vec3 worldpos;

attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;

uniform vec3 cameraPosition;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform float frameTimeCounter;
const float PI = 3.1415927;
const float PI48 = 150.796447372;
float pi2wt = (PI48*frameTimeCounter) * 1.0;











vec3 calcWave(in vec3 pos, in float fm, in float mm, in float ma, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5) {
    vec3 ret;
    float magnitude,d0,d1,d2,d3;
    magnitude = sin(pi2wt*fm + pos.x*0.5 + pos.z*0.5 + pos.y*0.5) * mm + ma;
    d0 = sin(pi2wt*f0);
    d1 = sin(pi2wt*f1);
    d2 = sin(pi2wt*f2);
    ret.x = sin(pi2wt*f3 + d0 + d1 - pos.x + pos.z + pos.y) * magnitude;
    ret.z = sin(pi2wt*f4 + d1 + d2 + pos.x - pos.z + pos.y) * magnitude;
	ret.y = sin(pi2wt*f5 + d2 + d0 + pos.z + pos.y - pos.y) * magnitude;
    return ret;
}

vec3 calcMove(in vec3 pos, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5, in vec3 amp1, in vec3 amp2) {
    vec3 move1 = calcWave(pos      , 0.0027, 0.0400, 0.0400, 0.0127, 0.0089, 0.0114, 0.0063, 0.0224, 0.0015) * amp1;
	vec3 move2 = calcWave(pos+move1, 0.0348, 0.0400, 0.0400, f0, f1, f2, f3, f4, f5) * amp2;
    return move1+move2;
}







								
								
								
								
								
								
								


void main() {
	
	texcoord.xy = (gl_MultiTexCoord0).xy;
	texcoord.zw = gl_MultiTexCoord1.xy/255.0;

	vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;
		 worldpos = position.xyz + cameraPosition;
	bool istopv = gl_MultiTexCoord0.t < mc_midTexCoord.t;
	/*
	bool entities = (mc_Entity.x == ENTITY_VINES || mc_Entity.x == ENTITY_SMALLENTS || mc_Entity.x == 10030.0 || mc_Entity.x == 10031.0 || mc_Entity.x == 10115.0 || mc_Entity.x == ENTITY_LILYPAD 
					|| mc_Entity.x == ENTITY_LAVA || mc_Entity.x == ENTITY_LEAVES || mc_Entity.x == ENTITY_SMALLGRASS || mc_Entity.x == ENTITY_UPPERGRASS || mc_Entity.x == ENTITY_LOWERGRASS);
	*/
	normal.a = 0.02;
	normal.xyz = normalize(gl_NormalMatrix * gl_Normal);


if (mc_Entity.x == 10175.0 && istopv || mc_Entity.x == 10176.0)
			position.xyz += calcMove(worldpos.xyz,
			0.0041,
			0.0070,
			0.0044,
			0.0038,
			0.0240,
			0.0000,
			vec3(0.8,0.0,0.8),
			vec3(0.4,0.0,0.4));


if (istopv) {
	
	if (mc_Entity.x == 10031.0)
			position.xyz += calcMove(worldpos.xyz,
				0.0041,
				0.0070,
				0.0044,
				0.0038,
				0.0063,
				0.0000,
				vec3(3.0,1.6,3.0),
				vec3(0.0,0.0,0.0));
	
	
	if (mc_Entity.x == 10059.0)
			position.xyz += calcMove(worldpos.xyz,
			0.0041,
			0.0070,
			0.0044,
			0.0038,
			0.0240,
			0.0000,
			vec3(0.8,0.0,0.8),
			vec3(0.4,0.0,0.4));
	
	
	if (mc_Entity.x == 10051.0)
			position.xyz += calcMove(worldpos.xyz,
			0.0105,
			0.0096,
			0.0087,
			0.0063,
			0.0097,
			0.0156,
			vec3(1.2,0.4,1.2),
			vec3(0.8,0.8,0.8));
	
}

	
	if (mc_Entity.x == 10018.0)
			position.xyz += calcMove(worldpos.xyz,
			0.0040,
			0.0064,
			0.0043,
			0.0035,
			0.0037,
			0.0041,
			vec3(1.0,0.2,1.0),
			vec3(0.5,0.1,0.5));
	
	
	if ( mc_Entity.x == 10106.0)
			position.xyz += calcMove(worldpos.xyz,
			0.0040,
			0.0064,
			0.0043,
			0.0035,
			0.0037,
			0.0041,
			vec3(0.5,1.0,0.5),
			vec3(0.25,0.5,0.25));

	if (mc_Entity.x == 10177.0 && gl_MultiTexCoord0.t > mc_midTexCoord.t)
			position.xyz += calcMove(worldpos.xyz,
			0.0041,
			0.0070,
			0.0044,
			0.0038,
			0.0240,
			0.0000,
			vec3(0.8,0.0,0.8),
			vec3(0.4,0.0,0.4));		
	

	
	if(mc_Entity.x == 10010.0){
		float fy = fract(worldpos.y + 0.001);
		float wave = 0.05 * sin(2 * PI * (frameTimeCounter*0.2 + worldpos.x /  7.0 + worldpos.z / 13.0))
				   + 0.05 * sin(2 * PI * (frameTimeCounter*0.15 + worldpos.x / 11.0 + worldpos.z /  5.0));
		position.y += clamp(wave, -fy, 1.0-fy)*0.5;
	}
	
	
	
	if(mc_Entity.x == 10111.0){
		float fy = fract(worldpos.y + 0.001);
		float wave = 0.05 * sin(2 * PI * (frameTimeCounter*0.8 + worldpos.x /  2.5 + worldpos.z / 5.0))
				   + 0.05 * sin(2 * PI * (frameTimeCounter*0.6 + worldpos.x / 6.0 + worldpos.z /  12.0));
		position.y += clamp(wave, -fy, 1.0-fy)*1.05;
	}
	
	
	
	if(mc_Entity.x == 10090.0){
		vec3 fxyz = fract(worldpos.xyz + 0.001);
		float wave = 0.025 * sin(2 * PI * (frameTimeCounter*0.4 + worldpos.x * 0.5 + worldpos.z * 0.5));
					//+ 0.025 * sin(2 * PI * (frameTimeCounter*0.4 + worldpos.y *0.25 + worldpos.z *0.25));
		float waveY = 0.05 * cos(frameTimeCounter*2.0 + worldpos.y);
		position.x -= clamp(wave, -fxyz.x, 1.0-fxyz.x);
		position.y += clamp(waveY*0.25, -fxyz.y, 1.0-fxyz.y)+0.015;		
		position.z += clamp(wave*0.45, -fxyz.z, 1.0-fxyz.z);
	}
	

	color = gl_Color;

	if(mc_Entity.x == 10080.0) normal.a = 0.4;
	if(mc_Entity.x == 10081.0) normal.a = 0.5;

	//Fix colors on emissive blocks, removed lava as it might cause issues with custom optifine color maps.
	if (mc_Entity.x == 10051.0
	|| mc_Entity.x == 10089.0
	|| mc_Entity.x == 10090.0){
	normal.a = 0.6;	
	color = vec4(1.0);
	}

	if(mc_Entity.x == 10010.0) normal.a = 0.6;

	//Translucent blocks
	if (mc_Entity.x == 10106.0
	|| mc_Entity.x == 10059.0
	|| mc_Entity.x == 10030.0 //Cobweb
	|| mc_Entity.x == 10031.0 //Dead shrub+Dead Bush
	|| mc_Entity.x == 10115.0 //nether wart
	|| mc_Entity.x == 10576.0 //spore blossom
	|| mc_Entity.x == 10111.0
	|| mc_Entity.x == 10010.0
	|| mc_Entity.x == 10018.0
	|| mc_Entity.x == 10031.0
	|| mc_Entity.x == 10176.0
	|| mc_Entity.x == 10175.0){
	normal.a = 0.7;
	}

	if(mc_Entity.x == 10300.0) color = vec4(1.0); //fix lecterns

	gl_Position = gl_ProjectionMatrix * gbufferModelView * position;

	



	
	
	
	
	
	
	
	
	
	
	
	
					 
					 
	

	
	
	
	

}



#version 150 core
#define gl_FragData iris_FragData
#define varying in
#define gl_ModelViewProjectionMatrix (gl_ProjectionMatrix * gl_ModelViewMatrix)
#define gl_ModelViewMatrix (iris_ModelViewMat * _iris_internal_translate(iris_ChunkOffset))
#define gl_NormalMatrix mat3(transpose(inverse(gl_ModelViewMatrix)))
#define gl_Color iris_ColorModulator
#define gl_ProjectionMatrix iris_ProjMat
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
in float iris_FogFragCoord;
uniform mat4 iris_ProjMat;
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
out vec4 iris_FragData[8];
vec4 texture2D(sampler2D sampler, vec2 coord) { return texture(sampler, coord); }
vec4 texture2D(sampler2D sampler, vec2 coord, float bias) { return texture(sampler, coord, bias); }
vec4 texture2DLod(sampler2D sampler, vec2 coord, float lod) { return textureLod(sampler, coord, lod); }
vec4 shadow2D(sampler2DShadow sampler, vec3 coord) { return vec4(texture(sampler, coord)); }
vec4 shadow2DLod(sampler2DShadow sampler, vec3 coord, float lod) { return vec4(textureLod(sampler, coord, lod)); }














































































































































































































































































































































































































/* DRAWBUFFERS:02 */ //0=gcolor, 2=gnormal for normals
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



    
    
    


//Setup constants
const int	noiseTextureResolution = 128;
//----------------------------------------------------------------

/* Don't remove me
const int gcolorFormat = RGBA8;
const int gnormalFormat = RGB10_A2;
const int compositeFormat = RGBA8;
-----------------------------------------*/

varying vec4 color;
varying vec3 vworldpos;
varying mat3 tbnMatrix;
varying vec2 texcoord;
varying vec2 lmcoord;
varying float iswater;
varying float mat;
uniform sampler2D normals;
uniform sampler2D texture;
uniform sampler2D lightmap;
uniform float rainStrength;
uniform vec4 entityColor;
uniform int isEyeInWater;
uniform int entityId;
uniform ivec2 eyeBrightnessSmooth;
uniform vec3 shadowLightPosition;


const int GL_LINEAR = 9729;
const int GL_EXP = 2048;
uniform int fogMode;



uniform sampler2D noisetex;
uniform float frameTimeCounter;

mat2 rmatrix(float rad){
	return mat2(vec2(cos(rad), -sin(rad)), vec2(sin(rad), cos(rad)));
}

float calcWaves(vec2 coord){
	vec2 movement = abs(vec2(0.0, -frameTimeCounter * 0.31365*iswater));
		 
	coord *= 0.262144;
	vec2 coord0 = coord * rmatrix(1.0) - movement * 4.0;
		 coord0.y *= 3.0;
	vec2 coord1 = coord * rmatrix(0.5) - movement * 1.5;
		 coord1.y *= 3.0;		 
	vec2 coord2 = coord + movement * 0.5;
		 coord2.y *= 3.0;
	
	float wave = 1.0 - texture2D(noisetex,coord0 * 0.005).x * 10.0;		//big waves
		  wave += texture2D(noisetex,coord1 * 0.010416).x * 7.0;		//small waves
		  wave += sqrt(texture2D(noisetex,coord2 * 0.045).x * 6.5) * 1.33;//noise texture
		  wave *= 0.0157;
	
	return wave;
}

vec3 calcBump(vec2 coord){
	const vec2 deltaPos = vec2(0.25, 0.0);

	float h0 = calcWaves(coord);
	float h1 = calcWaves(coord + deltaPos.xy);
	float h2 = calcWaves(coord - deltaPos.xy);
	float h3 = calcWaves(coord + deltaPos.yx);
	float h4 = calcWaves(coord - deltaPos.yx);

	float xDelta = ((h1-h0)+(h0-h2));
	float yDelta = ((h3-h0)+(h0-h4));

	return vec3(vec2(xDelta,yDelta)*0.45, 0.55); //z = 1.0-0.5
}



varying float NdotL;
varying vec3 getShadowpos;
uniform sampler2DShadow shadowtex0;	//normal shadows
uniform sampler2DShadow shadowtex1; //colored shadows
uniform sampler2D shadowcolor0;

//Hacky lightmap setup for emissive blocks, todo
float modlmap = 13.0-lmcoord.s*12.35; 
float torch_lightmap = max(1.5/(modlmap*modlmap)-0.00945,0.0);
vec3 emissiveLight = clamp(vec3(1.25)*torch_lightmap, 0.0, 1.0); //emissive lightmap

float shadowfilter(sampler2DShadow shadowtexture){
	vec2 offset = vec2(0.25, -0.25) / shadowMapResolution;	
	return clamp(dot(vec4(shadow2D(shadowtexture,vec3(getShadowpos.xy + offset.xx, getShadowpos.z)).x,
						  shadow2D(shadowtexture,vec3(getShadowpos.xy + offset.yx, getShadowpos.z)).x,
						  shadow2D(shadowtexture,vec3(getShadowpos.xy + offset.xy, getShadowpos.z)).x,
						  shadow2D(shadowtexture,vec3(getShadowpos.xy + offset.yy, getShadowpos.z)).x),vec4(0.25))*NdotL,0.0,1.0);
}

vec3 calcShadows(vec3 c){
	vec3 finalShading = vec3(0.0);

if(NdotL > 0.0 && rainStrength < 0.9){ //optimization, disable shadows during rain for performance boost
		float shading = shadowfilter(shadowtex0);
	
		float cshading = shadowfilter(shadowtex1);
		finalShading = texture2D(shadowcolor0, getShadowpos.xy).rgb*(cshading-shading) + shading;
	
		
	
	
	//avoid light leaking underground
	finalShading *= mix(max(lmcoord.t-2.0/16.0,0.0)*1.14285714286,1.0,clamp((eyeBrightnessSmooth.y/255.0-2.0/16.)*4.0,0.0,1.0));
	
	finalShading *= (1.0 - rainStrength);		//smoother transition while disabling shadows during rain
	finalShading *= (1.0 - iswater);			//disable shadows on water plane(not fully, 1.0-0.95)
}
	
return c * (1.0+finalShading+emissiveLight) * 0.55;
}
















	



	
	

	
		
		
		
		
		
	
		
	
	

	
	
	
	
		
	
		
	
	
		
	
	
	



vec4 encode (vec3 n){
    return vec4(n.xy*inversesqrt(n.z*8.0+8.0) + 0.5, mat/2.0, 1.0);
}

void irisMain() {


	vec4 tex = texture2D(texture, texcoord.st) * texture2D(lightmap, lmcoord.xy) * color;

	
	
	


	vec4 normal = vec4(0.0); //fill the buffer with 0.0 if not needed, improves performance


	
	
	
		
	
		
	
	
		
	

	



	tex.rgb = calcShadows(tex.rgb);



	



	tex.rgb = mix(tex.rgb,entityColor.rgb,entityColor.a);



	vec2 waterpos = (vworldpos.xz - vworldpos.y);
	if(mat > 0.9)normal = vec4(normalize(calcBump(waterpos) * tbnMatrix), 1.0); //mat > 0.9 so that only reflective blocks alter normals, boosts performance by about 30%. mat=reflective


if(iswater > 0.1){
	if(isEyeInWater > 0.9)tex.a = 0.9;	//improve alpha underwater, default is 1 (opaque)

	tex.rgb *= 1.25;					//improve colors on water

	
		
	
		
	

}

	//Fix lightning bolts
	if(entityId == 11000.0) tex = texture2D(lightmap, lmcoord.xy)*color;

	gl_FragData[0] = tex;
	gl_FragData[1] = encode(normal.xyz);
	

	if (fogMode == GL_EXP) {
		gl_FragData[0].rgb = mix(gl_FragData[0].rgb, gl_Fog.color.rgb, 1.0 - clamp(exp(-gl_Fog.density * gl_FogFragCoord), 0.0, 1.0));
	} else if (fogMode == GL_LINEAR) {
		gl_FragData[0].rgb = mix(gl_FragData[0].rgb, gl_Fog.color.rgb, clamp((gl_FogFragCoord - gl_Fog.start) * gl_Fog.scale, 0.0, 1.0));
	} else if (isEyeInWater == 1.0 || isEyeInWater == 2.0){
		gl_FragData[0].rgb = mix(gl_FragData[0].rgb, gl_Fog.color.rgb, 1.0 - clamp(exp(-gl_Fog.density * gl_FogFragCoord), 0.0, 1.0));
	}

}


void main() {
    irisMain();

    if (!(gl_FragData[0].a > 1.0E-4)) {
        discard;
    }
}

#version 150 core
#define gl_FragData iris_FragData
#define varying in
#define gl_ModelViewProjectionMatrix (gl_ProjectionMatrix * gl_ModelViewMatrix)
#define gl_ModelViewMatrix (iris_ModelViewMat * _iris_internal_translate(iris_ChunkOffset))
#define gl_NormalMatrix mat3(transpose(inverse(gl_ModelViewMatrix)))
#define gl_Color (Color * iris_ColorModulator)
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














































































































































































































































































































































































































/* DRAWBUFFERS:56 */
//Render entities etc in here, boost and fix enchanted armor effect in gbuffers_armor_glint


/*
Thank you for downloading Sildur's vibrant shaders, make sure you got it from the official source found here:
https://sildurs-shaders.github.io/
*/

    
    
    
    
    const float shadowDistance = 70.0;			//Render distance of shadows. 60=lite, 80=med, 80=high, 120=extreme [60.0 70.0 80.0 90.0 100.0 110.0 120.0 130.0 140.0 150.0 160.0 170.0 180.0 190.0 200.0 210.0 220.0 230.0 240.0 250.0 260.0 270.0 280.0 290.0 300.0 310.0 320.0 330.0 340.0 350.0 360.0 370.0 380.0 390.0 400.0]
    const int shadowMapResolution = 512;		//Shadows resolution. [256 512 1024 2048 3072 4096 6144 8192 16384] 512=lite, 1024=med, 2048=high, 3072=extreme 
    const float k = 1.8;
    
    
    float a = exp(0.05);
    float b = (exp(1.4)-a)*shadowDistance/128.0;
    float calcDistortion(vec2 worldpos){
        return 1.0/(log(length(worldpos)*b+a)*k);
    }
    



    
    
    
    
    
    
    
    
    
    
        

    
        
    

    

    
        
	    

    

    

    

    
    
    
    
    
    
        
    

    
    
    
    



	
    
	
		
	

	
	
	
		
        
    
		
		

	
		
		
		
        

	
	
	
    
    
    
    

    
    
    
    

	
	
	

	

    
    

	
	
	

    
        
    
    
        
    



    
    

    
    



    



    
    



    

    

    

    
	    
        

    

    
	
    
    
    
    
    
	

    

 

    



    
    
    
    

    
    

    
    
    
    
    
    
    
    
    
    



    
    
    
    
    



    
    
    

    
    
    
    

    
    
    
    

    
    
    



    



	
    
	
	


varying vec4 color;
varying vec2 texcoord;
varying vec3 normal;
varying vec3 ambientNdotL;
varying vec3 finalSunlight;
varying float skyL;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowModelView;
uniform sampler2DShadow shadowtex0;

vec3 toScreenSpace(vec3 pos) {
	vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
	if(gl_ProjectionMatrix[2][2] > -0.5) pos.z += 0.38;		//hand
	vec3 p3 = pos * 2.0 - 1.0;
    vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return fragposition.xyz / fragposition.w;
}

float shadowfilter(vec3 shadowpos, float dif){
	vec2 offset = vec2(0.65, -0.65) / shadowMapResolution;	
	return clamp(dot(vec4(shadow2D(shadowtex0,vec3(shadowpos.xy + offset.xx, shadowpos.z)).x,
						  shadow2D(shadowtex0,vec3(shadowpos.xy + offset.yx, shadowpos.z)).x,
						  shadow2D(shadowtex0,vec3(shadowpos.xy + offset.xy, shadowpos.z)).x,
						  shadow2D(shadowtex0,vec3(shadowpos.xy + offset.yy, shadowpos.z)).x),vec4(0.25))*dif,0.0,1.0);
}

uniform sampler2D texture;

uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;

uniform vec3 shadowLightPosition;
uniform int worldTime;
uniform ivec2 eyeBrightnessSmooth;

void irisMain() {

	float diffuse = clamp(dot(normalize(shadowLightPosition),normal),0.0,1.0);
	vec4 albedo = texture2D(texture, texcoord.xy)*color;



//don't do shading if transparent/translucent (not opaque)
if (diffuse > 0.0 && rainStrength < 0.9 && albedo.a > 0.01){
	vec3 fragposition = toScreenSpace(vec3(gl_FragCoord.xy/vec2(viewWidth,viewHeight),gl_FragCoord.z));

	vec3 worldposition = mat3(gbufferModelViewInverse) * fragposition.xyz + gbufferModelViewInverse[3].xyz;
		 worldposition = mat3(shadowModelView) * worldposition.xyz + shadowModelView[3].xyz;
		 worldposition = vec3((shadowProjection)[0].x, (shadowProjection)[1].y, (shadowProjection)[2].z) * worldposition.xyz + shadowProjection[3].xyz;
	
	float distortion = calcDistortion(worldposition.xy);
	float threshMul = max(2048.0/shadowMapResolution*shadowDistance/128.0,1.5); //increased offset to fix self shadowing on armor
	float distortThresh = (sqrt(1.0-diffuse*diffuse)/diffuse+0.7)/distortion;	
	float bias = distortThresh/6000.0*threshMul;

		worldposition.xy *= distortion;
		worldposition.xyz = worldposition.xyz * vec3(0.5,0.5,0.5/6.0) + vec3(0.5,0.5,0.5);
		worldposition.z -= bias;

	//Fast and simple shadow drawing for proper rendering of entities etc
	diffuse *= shadowfilter(worldposition, diffuse);
	diffuse *= (1.0 - rainStrength);
	diffuse *= mix(skyL,1.0,clamp((eyeBrightnessSmooth.y/255.0-2.0/16.)*4.0,0.0,1.0)); //avoid light leaking underground	
}

	


	vec3 finalColor = pow(albedo.rgb,vec3(2.2)) * (finalSunlight*diffuse+ambientNdotL.rgb);

	gl_FragData[0] = vec4(finalColor, albedo.a);
	gl_FragData[1] = vec4(normalize(albedo.rgb+0.00001), albedo.a);		
}


void main() {
    irisMain();

    if (!(gl_FragData[0].a > 0.1)) {
        discard;
    }
}

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
    



    
    
    
    
    
    
    
    
    
    
        

    
        
    

    

    
        
	    

    

    

    

    
    
    
    
    
    
        
    

    
    
    
    



	
    
	
		
	

	
	
	
		
        
    
		
		

	
		
		
		
        

	
	
	
    
    
    
    

    
    
    
    

	
	
	

	

    
    

	
	
	

    
        
    
    
        
    



    
    

    
    



    



    
    



    

    

    

    
	    
        

    

    
	
    
    
    
    
    
	

    

 

    



    
    
    
    

    
    

    
    
    
    
    
    
    
    
    
    



    
    
    
    
    



    
    
    

    //#define watertex
    
    //#define WaterParallax
    

    
    
    
    

    
    
    



    



	
    
	
	


varying vec4 color;
varying vec4 ambientNdotL;
varying vec2 texcoord;
varying vec2 lmcoord;
varying vec3 getSunlight;

varying vec3 viewVector;
varying vec3 worldpos;
varying vec3 getShadowPos;
varying float diffuse;
varying mat3 tbnMatrix;

uniform sampler2D noisetex;
uniform sampler2D texture;
uniform vec3 shadowLightPosition;

uniform float rainStrength;
uniform float frameTimeCounter;


uniform sampler2DShadow shadowtex0;
float shadowfilter(){
	vec2 offset = vec2(0.65, -0.65) / shadowMapResolution;	
	return dot(vec4(shadow2D(shadowtex0,vec3(getShadowPos.xy + offset.xx, getShadowPos.z)).x,
						  shadow2D(shadowtex0,vec3(getShadowPos.xy + offset.yx, getShadowPos.z)).x,
						  shadow2D(shadowtex0,vec3(getShadowPos.xy + offset.xy, getShadowPos.z)).x,
						  shadow2D(shadowtex0,vec3(getShadowPos.xy + offset.yy, getShadowPos.z)).x),vec4(0.25));
}


vec4 encode (vec3 n,float dif){
    float p = sqrt(n.z*8+8);
	
	float vis = lmcoord.t;
	if (ambientNdotL.a > 0.9) vis = vis * 0.25;
	if (ambientNdotL.a > 0.4 && ambientNdotL.a < 0.6) vis = vis*0.25+0.25;
	if (ambientNdotL.a < 0.1) vis = vis*0.25+0.5;
		
    return vec4(n.xy/p + 0.5,vis,1.0);
}

mat2 rmatrix(float rad){
	return mat2(vec2(cos(rad), -sin(rad)), vec2(sin(rad), cos(rad)));
}

float calcWaves(vec2 coord, float iswater){
	
	if(iswater > 0.9){
	vec2 movement = abs(vec2(0.0, -frameTimeCounter * 0.31365));

	coord *= 0.262144;
	vec2 coord0 = coord * rmatrix(1.0) - movement * 4.0;
		 coord0.y *= 3.0;
	vec2 coord1 = coord * rmatrix(0.5) - movement * 1.5;
		 coord1.y *= 3.0;		 
	vec2 coord2 = coord + movement * 0.5;
		 coord2.y *= 3.0;
	
	coord0 *= 1.0;
	coord1 *= 1.0;

	float wave = 1.0 - texture2D(noisetex,coord0 * 0.005).x * 10.0;			//big waves
		  wave += texture2D(noisetex,coord1 * 0.010416).x * 7.0;			//small waves
		  wave += sqrt(texture2D(noisetex,coord2 * 0.045).x * 6.5) * 1.33;	//noise texture
		  wave *= 0.0157;
	return wave;
	} else return sqrt(texture2D(noisetex,coord * 0.5).x) * 0.035;			//translucent noise, non water

}

vec3 calcBump(vec2 coord, float iswater){
	const vec2 deltaPos = vec2(0.25, 0.0);

	float h0 = calcWaves(coord, iswater);
	float h1 = calcWaves(coord + deltaPos.xy, iswater);
	float h2 = calcWaves(coord - deltaPos.xy, iswater);
	float h3 = calcWaves(coord + deltaPos.yx, iswater);
	float h4 = calcWaves(coord - deltaPos.yx, iswater);

	float xDelta = ((h1-h0)+(h0-h2));
	float yDelta = ((h3-h0)+(h0-h4));

	return vec3(vec2(xDelta,yDelta)*0.5, 0.5); //z = 1.0-0.5
}

vec3 calcParallax(vec3 pos, float iswater){
	float getwave = calcWaves(pos.xz - pos.y, iswater);

	pos.xz += (getwave * viewVector.xy) * 1.0;
	
	return pos;
}

void irisMain() {

	float iswater = clamp(ambientNdotL.a*2.0-1.0,0.0,1.0);

	vec4 albedo = texture2D(texture, texcoord.xy)*color;
		 albedo.rgb = pow(albedo.rgb,vec3(2.2));
	float texvis = 0.12;


texvis = 0.11;
if(iswater > 0.9)albedo.rgb = vec3(0.0,0.175,0.2);


	//Bump and parallax mapping
	vec3 waterpos = worldpos;

		 

	vec3 bump = calcBump(waterpos.xz - waterpos.y, iswater);

	vec3 newnormal = normalize(bump * tbnMatrix);
	//---

	//fast shading for translucent blocks
	float NdotL = diffuse;

	if(NdotL > 0.001 && (abs(getShadowPos.x) < 1.0-1.5/shadowMapResolution && abs(getShadowPos.y) < 1.0-1.5/shadowMapResolution && abs(getShadowPos.z) < 6.0) && rainStrength < 0.9)NdotL *= shadowfilter();
	NdotL *= (1.0 - iswater);
	NdotL *= (1.0 - rainStrength);

	vec3 sunlight = getSunlight.rgb*NdotL*(1.0-rainStrength*0.99)*0.85;
	//---

	//vec3 fColor = albedo.rgb*(0.002+sunlight+ambientNdotL.rgb); //add a min value for water color in caves, makes water a tiny bit brighter, WIP
	vec3 fColor = albedo.rgb*(sunlight+ambientNdotL.rgb);	
	float alpha = mix(albedo.a,texvis,iswater);
	if(iswater > 0.9)alpha *= 6.0;

/* DRAWBUFFERS:526 */
	gl_FragData[0] = vec4(fColor,alpha);
	gl_FragData[1] = encode(newnormal.xyz, NdotL);
	gl_FragData[2] = vec4(normalize(albedo.rgb+0.00001),alpha);
}


void main() {
    irisMain();

// alpha test disabled
}

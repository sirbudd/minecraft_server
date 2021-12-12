#version 150 core
#define gl_FragData iris_FragData
#define varying in
#define gl_ModelViewProjectionMatrix (gl_ProjectionMatrix * gl_ModelViewMatrix)
#define gl_ModelViewMatrix mat4(1.0)
#define gl_NormalMatrix mat3(1.0)
#define gl_Color vec4(1.0, 1.0, 1.0, 1.0)
#define gl_ProjectionMatrix mat4(vec4(2.0, 0.0, 0.0, 0.0), vec4(0.0, 2.0, 0.0, 0.0), vec4(0.0), vec4(-1.0, -1.0, 0.0, 1.0))
#define gl_FogFragCoord iris_FogFragCoord
#extension  GL_ARB_shader_texture_lod : enable














































































































































































































































































































































































































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
out vec4 iris_FragData[8];
vec4 texture2D(sampler2D sampler, vec2 coord) { return texture(sampler, coord); }
vec4 texture2D(sampler2D sampler, vec2 coord, float bias) { return texture(sampler, coord, bias); }
vec4 texture2DLod(sampler2D sampler, vec2 coord, float lod) { return textureLod(sampler, coord, lod); }
vec4 shadow2D(sampler2DShadow sampler, vec3 coord) { return vec4(texture(sampler, coord)); }
vec4 shadow2DLod(sampler2DShadow sampler, vec3 coord, float lod) { return vec4(textureLod(sampler, coord, lod)); }
const bool gaux1MipmapEnabled = true;
/* DRAWBUFFERS:3 */



/*
Thank you for downloading Sildur's vibrant shaders, make sure you got it from the official source found here:
https://sildurs-shaders.github.io/
*/

    
    
    
    
    
    
    
    
    
    
    
    
        
    
    



    
    
    
    
    
    
    
    
    
    
        

    
        
    

    

    
        
	    

    

    

    

    
    
    
    
    
    
        
    

    
    
    
    



	const int noiseTextureResolution = 128;     //must be in composite1 for 2d clouds
    
	
		
	//#define Lens_Flares

	//#define Volumetric_Lighting               //Disable godrays before enabling volumetric lighting.
	
	
		
        //#define morningFog                    //Toggle dynamic fog during sunrise.
    
		
		

	
		
		
		//#define Cloud_reflection              //Toggle clouds reflection in water	
        

	//#define waterRefl                           //Toggle water reflections
	//#define iceRefl                             //Toggle stained glass and ice reflections
	
    //#define Refraction                          //Toggle water refractions.
    //#define Caustics                            //Toggle water caustics.
    
    

    //#define metallicRefl                        //Toggle reflections for metallic blocks defined in block.properties
    //#define polishedRefl                        //Toggle reflections for polished blocks defined in block.properties   
    
    

	//#define RainReflections                   //Toggle rain reflections, wetness
	
	

	

    //#define defskybox                         //Toggle support for the default skybox, including custom skies from resourcepacks. If no resourcepack is present this will only enable the default sun and moon texture. This option also auto disables the custom shader sun and moon.
    

	
	
	

    
        
    
    
        
    



    //#define TAA							        //Toggle temporal anti-aliasing (TAA)
    

    //#define Adaptive_sharpening			    //Toggle adaptive sharpening. Recommended to use with TAA. Disabling TAA also disables adaptive sharpening.
    



    



    
    



    

    

    

    
	    
        

    

    
	
    
    
    
    
    
	

    

 

    



    
    
    
    

    
    

    
    
    
    
    
    
    
    
    
    



    
    
    
    
    



    
    
    

    
    
    
    

    
    
    
    

    
    
    



    



	
    
	
	


//custom uniforms defined in shaders.properties
uniform float inSwamp;
uniform float BiomeTemp;

varying vec2 texcoord;
varying vec2 lightPos;

varying vec3 sunVec;
varying vec3 upVec;
varying vec3 lightColor;
varying vec3 sky1;
varying vec3 sky2;
varying vec3 nsunlight;
varying vec3 sunlight;
const vec3 moonlight = vec3(0.0025, 0.0045, 0.007);
varying vec3 rawAvg;
varying vec3 avgAmbient2;
varying vec3 cloudColor;
varying vec3 cloudColor2;

varying float fading;
varying float tr;
varying float eyeAdapt;
varying float SdotU;
varying float sunVisibility;
varying float moonVisibility;

uniform sampler2D composite;
uniform sampler2D gaux1;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;

uniform sampler2D noisetex;
uniform sampler2D gaux3;
uniform sampler2D gaux2;
uniform sampler2D gaux4;

uniform vec3 cameraPosition;
uniform vec3 sunPosition;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform ivec2 eyeBrightness;
uniform ivec2 eyeBrightnessSmooth;
uniform int isEyeInWater;
uniform int worldTime;
uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;
uniform float frameTimeCounter;
uniform float blindness;

/*------------------------------------------*/
float comp = 1.0-near/far/far;
float tmult = mix(min(abs(worldTime-6000.0)/6000.0,1.0),1.0,rainStrength);
float night = clamp((worldTime-13000.0)/300.0,0.0,1.0)-clamp((worldTime-22800.0)/200.0,0.0,1.0);

//Draw sun and moon
vec3 drawSun(vec3 fposition, vec3 color, float vis) {
	vec3 sVector = normalize(fposition);
	float angle = (1.0-max(dot(sVector,sunVec),0.0))* 650.0;
	float sun = exp(-angle*angle*angle);
			sun *= (1.0-rainStrength*1.0)*sunVisibility;

	vec3 sunlightB = mix(pow(sunlight,vec3(1.0))*44.0,vec3(0.25,0.3,0.4),rainStrength*0.8);
if(isEyeInWater	== 1.0)sunlightB = mix(pow(moonlight*40.0,vec3(1.0))*44.0,vec3(0.25,0.3,0.4),rainStrength*0.8);	//lets just render the moon underwater, it has the perfect color

	return mix(color,sunlightB,sun*vis);
}
vec3 drawMoon(vec3 fposition, vec3 color, float vis) {
	vec3 sVector = normalize(fposition);
	float angle = (1.0-max(dot(sVector,-sunVec),0.0))* 2000.0;
	float moon = exp(-angle*angle*angle);
			moon *= (1.0-rainStrength*1.0)*moonVisibility;
	vec3 moonlightC = mix(pow(moonlight*40.0,vec3(1.0))*44.0,vec3(0.25,0.3,0.4),rainStrength*0.8);

	return mix(color,moonlightC,moon*vis);
}/**--------------------------------------*/


float getAirDensity (float h) {
	return max(h/10.,6.0);
}

float calcFog(vec3 fposition) {
	float density = 100.0*(1.0-rainStrength*0.115);


	
	

	vec3 worldpos = (gbufferModelViewInverse*vec4(fposition,1.0)).rgb+cameraPosition;
	float height = mix(getAirDensity (worldpos.y),6.,rainStrength);
	float d = length(fposition);

	return pow(clamp((2.625+rainStrength*3.4)/exp(-60/10./density)*exp(-getAirDensity (cameraPosition.y)/density) * (1.0-exp( -pow(d,2.712)*height/density/(6000.-tmult*tmult*2000.)/13))/height,0.0,1.),1.0-rainStrength*0.63)*clamp((eyeBrightnessSmooth.y/255.-2/16.)*4.,0.0,1.0);
}


	



//Skycolor
vec3 getSkyc(vec3 fposition) {
vec3 sVector = normalize(fposition);

float invRain07 = 1.0-rainStrength*0.6;
float cosT = dot(sVector,upVec);
float mCosT = max(cosT,0.0);
float absCosT = 1.0-max(cosT*0.82+0.26,0.2);
float cosY = dot(sunVec,sVector);
float Y = acos(cosY);

const float a = -1.;
const float b = -0.22;
const float c = 8.0;
const float d = -3.5;
const float e = 0.3;

//luminance
float L =  (1.0+a*exp(b/(mCosT)));
float A = 1.0+e*cosY*cosY;

//gradient
vec3 grad1 = mix(sky1,sky2,absCosT*absCosT);
float sunscat = max(cosY,0.0);
vec3 grad3 = mix(grad1,nsunlight,sunscat*sunscat*(1.0-mCosT)*(0.9-rainStrength*0.5*0.9)*(clamp(-(SdotU)*4.0+3.0,0.0,1.0)*0.65+0.35)+0.1);

float Y2 = 3.14159265359-Y;
float L2 = L * (8.0*exp(d*Y2)+A);

const vec3 moonlight2 = pow(normalize(moonlight),vec3(3.0))*length(moonlight);
const vec3 moonlightRain = normalize(vec3(0.25,0.3,0.4))*length(moonlight);
vec3 gradN = mix(moonlight,moonlight2,1.-L2/2.0);
gradN = mix(gradN,moonlightRain,rainStrength);

return pow(L*(c*exp(d*Y)+A),invRain07)*sunVisibility *length(rawAvg) * (0.85+rainStrength*0.425)*grad3+ 0.2*pow(L2*1.2+1.2,invRain07)*moonVisibility*gradN;
}/*---------------------------------*/







    


    


	



    
    
	
    
	
    

    
        
        
        
        
        
		
                
                
					
                    
					
					
					
                
				
                


        
        
		
    
    



	
	
	
	

    
    
	
    
	
    

    
        
        
        
        
        
		
                
                
					
                    
					
					
                
				
                


        
        
		
    
    





	



	














	




	
	
	
	
	
							
							
							

	
	
	
	
	
							 
							 
							 

	
	

	

	
	
	
	
	





float maxHeight = (256.0+200.0);

float densityAtPos(in vec3 pos){
	pos /= 18.0;
	pos.xz *= 0.5;

	vec3 p = floor(pos);
	vec3 f = fract(pos);
	
	f = (f*f) * (3.0-2.0*f);
	f = sqrt(f);
	vec2 uv = p.xz + f.xz + p.y * 17.0;

	vec2 coord =  uv / 64.0;
	vec2 coord2 =  uv / 64.0 + 17.0 / 64.0;
	float xy1 = texture2D(noisetex, coord).x;
	float xy2 = texture2D(noisetex, coord2).x;
	return mix(xy1, xy2, f.y);
}

float cloudPlane(in vec3 pos){
	float center = 256.0*0.5+maxHeight*0.5;
	float difcenter = maxHeight-center;	
	float mult = (pos.y-center)/difcenter;
	
	vec3 samplePos = pos*vec3(0.5,0.5,0.5)*0.35+frameTimeCounter*vec3(0.5,0.,0.5);
	float noise = 0.0;
	float tot = 0.0;
	for(int i=0 ; i < 4; i++){
		noise += densityAtPos(samplePos*exp(i*1.05)*0.6+frameTimeCounter*i*vec3(0.5,0.,0.5)*0.6)*exp(-i*0.8);
		tot += exp(-i*0.8);
	}

return 1.0-pow(0.4,max(noise/tot-0.56-mult*mult*0.3+rainStrength*0.16,0.0)*2.2);
}

vec3 renderClouds(in vec3 pos, in vec3 color, const int cloudIT) {
	float dither = fract(0.75487765 * gl_FragCoord.x + 0.56984026 * gl_FragCoord.y);	
	
		  
	
		
	//setup
	vec3 dV_view = pos.xyz;
	vec3 progress_view = vec3(0.0);
	pos = pos*2200.0 + cameraPosition; //makes max cloud distance not dependant of render distance	
	
	//3 ray setup cases : below cloud plane, in cloud plane and above cloud plane
	if (cameraPosition.y <= 256.0){
		float maxHeight2 = min(maxHeight, pos.y);	//stop ray when intersecting before cloud plane end
		
		//setup ray to start at the start of the cloud plane and end at the end of the cloud plane
		dV_view *= -(maxHeight2-256.0)/dV_view.y/cloudIT;
		progress_view = dV_view*dither + cameraPosition + dV_view*(maxHeight2-cameraPosition.y)/(dV_view.y);
		if (pos.y < 256.0) return color;	//don't trace if no intersection is possible
	}
	if (cameraPosition.y > 256.0 && cameraPosition.y < maxHeight){
		if (dV_view.y <= 0.0) {	
		float maxHeight2 = max(256.0, pos.y);	//stop ray when intersecting before cloud plane end
		
		//setup ray to start at eye position and end at the end of the cloud plane
		dV_view *= abs(maxHeight2-cameraPosition.y)/abs(dV_view.y)/cloudIT;
		progress_view = dV_view*dither + cameraPosition + dV_view*cloudIT;
		dV_view *= -1.0;
		}
else if (dV_view.y > 0.0) {		
		float maxHeight2 = min(maxHeight, pos.y);	//stop ray when intersecting before cloud plane end
		
		//setup ray to start at eye position and end at the end of the cloud plane
		dV_view *= -abs(maxHeight2-cameraPosition.y)/abs(dV_view.y)/cloudIT;
		progress_view = dV_view*dither + cameraPosition - dV_view*cloudIT;
		}
	}
	if (cameraPosition.y >= maxHeight){			
		float maxHeight2 = max(256.0, pos.y);	//stop ray when intersecting before cloud plane end

		//setup ray to start at eye position and end at the end of the cloud plane
		dV_view *= -abs(maxHeight2-maxHeight)/abs(dV_view.y)/cloudIT;
		progress_view = dV_view*dither + cameraPosition + dV_view*(maxHeight2-cameraPosition.y)/dV_view.y;
		if (pos.y > maxHeight) return color;	//don't trace if no intersection is possible
	}

	float mult = length(dV_view)/256.0;

	for (int i=0;i<cloudIT;i++) {
		float cloud = cloudPlane(progress_view)*40.0;
		float lightsourceVis = pow(clamp(progress_view.y-256.0,0.,200.)/200.,2.3);
		color = mix(color,mix(cloudColor2*0.05, cloudColor*0.15, lightsourceVis),1.0-exp(-cloud*mult));

		progress_view += dV_view;
	}

	return color;	
}



float calcStars(vec3 pos){
 	vec3 p = pos * 256.0;
	vec3 flr = floor(p);
	float fr = length((p - flr) - 0.5);
	flr = fract(flr * 443.8975);
    flr += dot(flr, flr.xyz + 19.19);

 	float intensity = step(fract((flr.x + flr.y) * flr.z), 0.0025) * (1.0 - rainStrength);
	float stars = clamp((fr - 0.5) / (0.0 - 0.5), 0.0, 1.0);	//recreate smoothstep for opengl 120
    	  stars = stars * stars * (3.0 - 2.0 * stars);			//^

 	return stars * intensity;
}




	



	

	
	
		 
	
		 
	
	
	
	

	
		  
		  
		  

	



	

	
	
	
	
	

	
	

	



uniform float wetness;





	   
	   




	
		  

	



vec3 decode (vec2 enc){
    vec2 fenc = enc*4-2;
    float f = dot(fenc,fenc);
    float g = sqrt(1-f/4.0);
    vec3 n;
    n.xy = fenc*g;
    n.z = 1-f/2;
    return n;
}

/*
vec2 texelSize = vec2(1.0/viewWidth,1.0/viewHeight);
uniform int framemod8;
const vec2[8] offsets = vec2[8](vec2(1./8.,-3./8.),
								vec2(-1.,3.)/8.,
								vec2(5.0,1.)/8.,
								vec2(-3,-5.)/8.,
								vec2(-5.,5.)/8.,
								vec2(-7.,-1.)/8.,
								vec2(3,7.)/8.,
								vec2(7.,-7.)/8.);

vec3 toScreenSpace(vec3 p) {
	vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
    vec3 p3 = p * 2.0 - 1.0;
    vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return fragposition.xyz / fragposition.w;
}

vec2 newTC = gl_FragCoord.xy*texelSize;
vec3 TAAfragpos = toScreenSpace(vec3(newTC-offsets[framemod8]*texelSize*0.5, texture2D(depthtex0, newTC).x));

#if defined waterRefl || defined iceRefl
vec3 toClipSpace(vec3 viewSpacePosition) {
	return (vec3(gbufferProjection[0].x, gbufferProjection[1].y, gbufferProjection[2].z) * viewSpacePosition + gbufferProjection[3].xyz) / -viewSpacePosition.z * 0.5 + 0.5;
}
float ld(float dist) {
    return (2.0 * near) / (far + near - dist * (far - near));
}

vec3 newTrace(vec3 dir, vec3 position, float dither, float fresnel){
	#define SSR_STEPS 40 //[10 15 20 25 30 35 40 50 100 200 400]
    float quality = mix(15.0,SSR_STEPS,fresnel);

    vec3 clipPosition = toClipSpace(position);
	float rayLength = ((position.z + dir.z * far*1.732) > -near) ? (-near -position.z) / dir.z : far*1.732;
    vec3 direction = normalize(toClipSpace(position+dir*rayLength)-clipPosition);  //convert to clip space

    //get at which length the ray intersects with the edge of the screen
    vec3 maxLengths = (step(0.0,direction)-clipPosition) / direction;
    float mult = min(min(maxLengths.x,maxLengths.y),maxLengths.z);
	
    vec3 stepv = direction * mult / quality;

	vec3 spos = clipPosition + stepv*dither;
	float minZ = clipPosition.z;
	float maxZ = spos.z+stepv.z*0.5;
	spos.xy+=offsets[framemod8]*texelSize*0.5;
	//raymarch on a quarter res depth buffer for improved cache coherency

    for (int i = 0; i < int(quality+1); i++) {
		//float sp = texelFetch2D(depthtex1, ivec2(spos.xy/texelSize), 0).x;
		float sp = texture2D(depthtex1, spos.xy).x;		//might be slower then texelfetch but doesn't require shader4 extension
        if(sp <= max(maxZ,minZ) && sp >= min(maxZ,minZ)) return vec3(spos.xy,sp);

        spos += stepv;
		//small bias
		minZ = maxZ-0.00004/ld(spos.z);
		maxZ += stepv.z;
    }

    return vec3(1.1);
}
#endif
*/
vec2 decodeVec2(float a){
    const vec2 constant1 = 65535. / vec2( 256., 65536.);
    const float constant2 = 256. / 255.;
    return fract( a * constant1 ) * constant2 ;
}

float ld(float depth) {
    return 1.0 / (far+near - depth * far-near);
}

void main() {

vec3 c = pow(texture2D(gaux1,texcoord).xyz,vec3(2.2))*257.;
vec3 hr = texture2D(composite,(floor(texcoord*vec2(viewWidth,viewHeight)/2.0)*2.0+1.0)/vec2(viewWidth,viewHeight)/2.0).rgb*30.0;
vec2 lightmap = texture2D(colortex1, texcoord.xy).zw;

//Depth and fragpos
float depth0 = texture2D(depthtex0, texcoord).x;
vec4 fragpos0 = gbufferProjectionInverse * (vec4(texcoord, depth0, 1.0) * 2.0 - 1.0);
fragpos0 /= fragpos0.w;
vec3 normalfragpos0 = normalize(fragpos0.xyz);

float depth1 = texture2D(depthtex1, texcoord).x;
vec4 fragpos1 = gbufferProjectionInverse * (vec4(texcoord, depth1, 1.0) * 2.0 - 1.0);
	 fragpos1 /= fragpos1.w;
vec3 normalfragpos1 = normalize(fragpos1.xyz);
/*--------------------------------------------------------------------------------------------*/
float mats = texture2D(colortex0,texcoord).b;

vec4 trp = texture2D(gaux3,texcoord.xy);

bool transparency = dot(trp.xyz,trp.xyz) > 0.000001;
bool isMetallic = mats > 0.39 && mats < 0.41;
bool isPolished = mats > 0.49 && mats < 0.51;

	isPolished = false;


	isMetallic = false;




	
	
	

	
	
	
	
	
	
	
	

	
	
	
		
		
	
	




bool island = !(dot(texture2D(colortex0,texcoord).rgb,vec3(1.0))<0.00000000001 || (depth1 > comp)); //must be depth1 > comp for transparency

if (!island){ //breaks transparency rendering against the sky
vec3 cpos = normalize(gbufferModelViewInverse*fragpos1).xyz;

	

	c = hr.rgb;


	c += calcStars(cpos)*moonVisibility;


	


	c = drawSun(fragpos1.xyz, c, 1.0);
	c = drawMoon(fragpos1.xyz, c, 1.0);


float cheight = (256.0-32.0);
if (dot(fragpos1.xyz, upVec) > 0.0 || cameraPosition.y > cheight)c = renderClouds(cpos, c, 6);

}/*--------------------------------------*/

	//Draw fog
	vec3 fogC = hr.rgb*(0.7+0.3*tmult)*(1.33-rainStrength*0.67);
	float fogF = calcFog(fragpos0.xyz);
	/*----------------------------------------------------------------*/

//Render before transparency

	
		
		
		
		
		
			  
	
		
		

		
		
	


	//Draw entities etc
	//c = c*(1.0-texture2D(colortex2, texcoord).a)+texture2D(colortex2, texcoord).rgb;

if (transparency) {
	vec3 normal = texture2D(colortex2,texcoord).xyz;
	float sky = normal.z;

	bool reflectiveWater = sky < 0.2499 && dot(normal,normal) > 0.0;
	bool reflectiveIce = sky > 0.2499 && sky < 0.4999 && dot(normal,normal) > 0.0;

	bool iswater = sky < 0.2499;
	bool isice = sky > 0.2499 && sky < 0.4999;

	if (iswater) sky *= 4.0;
	if (isice) sky = (sky - 0.25)*4.0;
	if (!iswater && !isice) sky = (sky - 0.5)*4.0;

	sky = clamp(sky*1.2-2./16.0*1.2,0.,1.0);
	sky *= sky;

	normal = normalize(decode(normal.xy));
	
	//draw fog for transparency
	float iswater2 = float(iswater);
	float skylight = pow(max(lightmap.y-2.0/16.0,0.0)*1.14285714286, 1.0);
	c = mix(c, fogC, fogF-fogF) / (1.0 + 5.0*night*iswater2*skylight);

	//Draw transparency
	vec3 finalAc = texture2D(gaux2, texcoord.xy).rgb;
	float alphaT = clamp(length(trp.rgb)*1.02,0.0,1.0);

	c = mix(c,c*(trp.rgb*0.9999+0.0001)*1.732,alphaT)*(1.0-alphaT) + finalAc;
	/*-----------------------------------------------------------------------------------------*/
/*
	#if defined waterRefl || defined iceRefl
	if (reflectiveWater || reflectiveIce) {
		vec3 wFragpos1 = normalize(TAAfragpos);	
		vec3 reflectedVector = reflect(wFragpos1, normal);

		float normalDotEye = dot(normal, wFragpos1);
		float fresnel = pow(clamp(1.0 + normalDotEye,0.0,1.0), 4.0);
			  fresnel = mix(0.09,1.0,fresnel); //F0
			  fresnel *= 0.75;

		vec3 sky_c = getSkyc(reflectedVector);
			 sky_c = (isEyeInWater == 0)? ((drawSun(reflectedVector, sky_c, 1.0)+drawMoon(reflectedVector, sky_c, 1.0)) * 0.5)*sky : pow(vec3(0.25,0.5,0.72),vec3(2.2))*rawAvg*0.1;		

	#if defined Cloud_reflection && (Clouds == 2 || Clouds == 3 || Clouds == 4)
		vec3 cloudVector = normalize(gbufferModelViewInverse*vec4(reflect(fragpos1.xyz, normal), 1.0)).xyz;
		#if Clouds == 2 || Clouds == 4
			sky_c += drawCloud(reflectedVector, vec3(0.0))*1.5;
		#endif
		#if Clouds == 3 || Clouds == 4
			sky_c += renderClouds(cloudVector, c, cloudreflIT); 
		#endif
	#endif

		vec4 reflColor = vec4(sky_c, 0.0);
		vec3 reflection = newTrace(reflectedVector, fragpos0.xyz, fract(dot(gl_FragCoord.xy, vec2(0.5, 0.25))), fresnel);

		if (reflection.z < 1.0){	
			reflColor.rgb = pow(texture2D(gaux1, reflection.xy).rgb, vec3(2.2))*257.0;
			reflColor.a = 1.0;

			bool land = texture2D(depthtex1, reflection.xy).x < comp;
			if (isEyeInWater == 0) reflColor.rgb = land ? mix(reflColor.rgb, sky_c.rgb*(0.7+0.3*tmult)*(1.33-rainStrength*0.8), calcFog(fragpos0.xyz)) : drawSun(reflectedVector.rgb, sky_c, 1.0);
		}
		#ifndef waterRefl
			if(reflectiveWater)reflColor.a = 0.0;
		#endif
		#ifndef iceRefl
			if(reflectiveIce)reflColor.a = 0.0;
		#endif
		reflColor.rgb = mix(sky_c.rgb, reflColor.rgb, reflColor.a);
		c.rgb = mix(c.rgb, reflColor.rgb, fresnel);
	}
	#endif
*/


	if (reflectiveWater || reflectiveIce) {
		vec3 reflectedVector = reflect(normalfragpos0, normal);
		
		float normalDotEye = dot(normal, normalfragpos0);
		float fresnel = pow(clamp(1.0 + normalDotEye,0.0,1.0), 4.0);
			  fresnel = mix(0.09,1.0,fresnel); //F0
	
		vec3 sky_c = getSkyc(reflectedVector);

	
		
		
			
		
		
			
		
	
	
		
	
		vec4 reflection = vec4(0.0);
	
	
		if(reflectiveWater){ reflection = vec4(0.0); fresnel *= 0.5; }
	
	
		if(reflectiveIce){ reflection = vec4(0.0); fresnel *= 0.5; }
	

		sky_c = (isEyeInWater == 0)? ((drawSun(reflectedVector, sky_c, 1.0)+drawMoon(reflectedVector, sky_c, 1.0)) * 0.5)*sky : pow(vec3(0.25,0.5,0.72),vec3(2.2))*rawAvg*0.1;
		reflection.rgb = mix(sky_c, reflection.rgb, reflection.a)*0.85;

		c = mix(c,reflection.rgb,fresnel);
	}


}
	bool land = depth0 < comp;


	

	
	

	
		
	
		
	

	
		

		
		

		
		
		
	
		
		
			 
	
		
		
	
	

	//Draw land and underwater fog
	vec3 foglandC = fogC;
		 foglandC.b *= (1.5-0.5*rainStrength);
	if(land)c = mix(c,foglandC*(1.0-isEyeInWater),fogF);

	if(!land && rainStrength > 0.01)c = mix(c,fogC,fogF*0.75);	//tint vl clouds with fog while raining


	vec3 ufogC = sky1.rgb*0.1;
		// ufogC.g *= 1.0+2.0*inSwamp; //make fog greenish in swamp biomes
		 ufogC.r *= 0.0;
		 ufogC *= (1.0-0.85*night);
	
	
	if (isEyeInWater == 1.0) c = mix(c, ufogC, 1.0-exp(-length(fragpos0.xyz)/25.0));
	
	
	if (isEyeInWater == 2.0) c = mix(c, vec3(1.0, 0.0125, 0.0), 1.0-exp(-length(fragpos0.xyz))); //lava fog
	if(blindness > 0.9) c = mix(c, vec3(0.0), 1.0-exp(-length(fragpos1.xyz)*1.125));	//blindness fog


//Draw rain
vec4 rain = texture2D(gaux4, texcoord);
if (rain.r > 0.0001 && rainStrength > 0.01 && !(depth1 < texture2D(depthtex2, texcoord).x)){
	float rainRGB = 0.25;
	float rainA = rain.r;

	float torch_lightmap = 12.0 - min(rain.g/rain.r * 12.0,11.0);
	torch_lightmap = 0.05 / torch_lightmap / torch_lightmap - 0.002595;

	vec3 rainC = rainRGB*(pow(max(dot(normalfragpos0, sunVec)*0.1+0.9,0.0),6.0)*(0.1+tr*0.9)*pow(sunlight,vec3(0.25))*sunVisibility+pow(max(dot(normalfragpos0, -sunVec)*0.05+0.95,0.0),6.0)*48.0*moonlight*moonVisibility)*0.04 + 0.05*rainRGB*length(avgAmbient2);
	rainC += torch_lightmap*vec3(1.5,0.42,0.045);
	c = c*(1.0-rainA*0.3)+rainC*1.5*rainA;
}




	float sunpos = abs(dot(normalfragpos0,normalize(sunPosition.xyz)));
	float illuminationDecay = pow(sunpos,30.0)+pow(sunpos,16.0)*0.8+pow(sunpos,2.0)*0.125;
	
	vec2 deltaTextCoord = (lightPos-texcoord)*0.01;
	vec2 textCoord = texcoord*0.5+0.5;

	float gr = texture2DLod(gaux1, textCoord + deltaTextCoord,1).a;
		  gr += texture2DLod(gaux1, textCoord + 2.0 * deltaTextCoord,1).a;
		  gr += texture2DLod(gaux1, textCoord + 3.0 * deltaTextCoord,1).a;
		  gr += texture2DLod(gaux1, textCoord + 4.0 * deltaTextCoord,1).a;
		  gr += texture2DLod(gaux1, textCoord + 5.0 * deltaTextCoord,1).a;
		  gr += texture2DLod(gaux1, textCoord + 6.0 * deltaTextCoord,1).a;
		  gr += texture2DLod(gaux1, textCoord + 7.0 * deltaTextCoord,1).a;

	vec3 finalGC = lightColor;
		if(isEyeInWater == 1.0) finalGC.rgb = ufogC*2.0; //Underwater godrays should use underwater fog color
	vec3 grC = finalGC*1.15;
	if(blindness < 1.0)c += grC*gr/7.0*illuminationDecay;










	
	














	c = (c/50.0*pow(eyeAdapt,0.88));
	gl_FragData[0] = vec4(c,1.0);
}


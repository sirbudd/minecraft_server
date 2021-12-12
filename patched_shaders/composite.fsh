#version 150 core
#define gl_FragData iris_FragData
#define varying in
#define gl_ModelViewProjectionMatrix (gl_ProjectionMatrix * gl_ModelViewMatrix)
#define gl_ModelViewMatrix mat4(1.0)
#define gl_NormalMatrix mat3(1.0)
#define gl_Color vec4(1.0, 1.0, 1.0, 1.0)
#define gl_ProjectionMatrix mat4(vec4(2.0, 0.0, 0.0, 0.0), vec4(0.0, 2.0, 0.0, 0.0), vec4(0.0), vec4(-1.0, -1.0, 0.0, 1.0))
#define gl_FogFragCoord iris_FogFragCoord
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














































































































































































































































































































































































































/* DRAWBUFFERS:34 */




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
    



    
    //#define Penumbra                            //Toggle penumbra soft shadows
    //#define raytracedShadows                  //Improves closeup and faraway shadows. Also allows shadows to be cast outside of the shadowmap, outside of your shadows render distance. Requires shadows to be enabled. Has some issues since it's raytraced in screenspace.
    const int VPS_samples = 8;                  //Used for penumbra shadows [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30]
    
    const bool 	shadowHardwareFiltering0 = true;
    const bool 	shadowHardwareFiltering1 = true;
    const float	sunPathRotation	= -40.0;		//[-10.0 -20.0 -30.0 -40.0 -50.0 -60.0 -70.0 -80.0 0.0 10.0 20.0 30.0 40.0 50.0 60.0 70.0 80.0]
    
    //#define SSDO				                //Ambient Occlusion, makes lighting more realistic. High performance impact.
        

    
        const int grays_sample = 17;            //17=lite, 17=med, 20=high, 23=extreme
    //#define Volumetric_Lighting               //Disable godrays before enabling volumetric lighting.

    //#define Lens_Flares

    //#define Celshading                        //Cel shades everything, making it look somewhat like Borderlands. Zero performance impact.
        
	    

    //#define Whiteworld                        //Makes the ground white, screenshot -> https://i.imgur.com/xziUB8O.png

    

    //#define defskybox

    
    
    
    
    
    
        
    

    //Use the same color as water for water shading, diffuse
    
    
    



	
    
	
		
	

	
	
	
		
        
    
		
		

	
		
		
		
        

	
	
	
    
    
    
    

    
    
    
    

	
	
	

	

    
    

	
	
	

    
        
    
    
        
    



    //#define TAA							        //Toggle temporal anti-aliasing (TAA)
    

    //#define Adaptive_sharpening			    //Toggle adaptive sharpening. Recommended to use with TAA. Disabling TAA also disables adaptive sharpening.
    



    



    
    



    

    

    

    
	    
        

    

    
	
    
    
    
    
    
	

    

 

    



    
    
    
    

    
    

    
    
    
    
    
    
    
    
    
    



    
    
    
    
    



    
    
    

    
    
    
    

    
    
    
    

    
    
    



    



	
    
	
	


varying vec2 texcoord;
varying vec3 lightColor;
varying vec3 sunVec;
varying vec3 upVec;
varying vec3 sky1;
varying vec3 sky2;

varying float tr;

varying vec2 lightPos;

varying vec3 sunlight;
varying vec3 nsunlight;

varying vec3 rawAvg;

varying float SdotU;
varying float sunVisibility;
varying float moonVisibility;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D composite;


uniform sampler2DShadow shadow;		//shadows
uniform sampler2DShadow shadowtex1; //colored shadows
uniform sampler2D shadowcolor0;


uniform vec3 sunPosition;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform ivec2 eyeBrightnessSmooth;
uniform int isEyeInWater;
uniform int worldTime;
uniform float aspectRatio;
uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;
uniform ivec2 eyeBrightness;
uniform float nightVision;
uniform vec3 shadowLightPosition;
uniform float frameTimeCounter;

float comp = 1.0-near/far/far;			//distance above that are considered as sky

const vec2 check_offsets[25] = vec2[25](vec2(-0.4894566f,-0.3586783f),
									vec2(-0.1717194f,0.6272162f),
									vec2(-0.4709477f,-0.01774091f),
									vec2(-0.9910634f,0.03831699f),
									vec2(-0.2101292f,0.2034733f),
									vec2(-0.7889516f,-0.5671548f),
									vec2(-0.1037751f,-0.1583221f),
									vec2(-0.5728408f,0.3416965f),
									vec2(-0.1863332f,0.5697952f),
									vec2(0.3561834f,0.007138769f),
									vec2(0.2868255f,-0.5463203f),
									vec2(-0.4640967f,-0.8804076f),
									vec2(0.1969438f,0.6236954f),
									vec2(0.6999109f,0.6357007f),
									vec2(-0.3462536f,0.8966291f),
									vec2(0.172607f,0.2832828f),
									vec2(0.4149241f,0.8816f),
									vec2(0.136898f,-0.9716249f),
									vec2(-0.6272043f,0.6721309f),
									vec2(-0.8974028f,0.4271871f),
									vec2(0.5551881f,0.324069f),
									vec2(0.9487136f,0.2605085f),
									vec2(0.7140148f,-0.312601f),
									vec2(0.0440252f,0.9363738f),
									vec2(0.620311f,-0.6673451f)
									);




	
		
		
		
	

vec2 tapLocation(int sampleNumber, int nb, float jitter){
    float alpha = (sampleNumber+jitter)/nb;
    float angle = jitter*6.28 + alpha * 4.0 * 6.28;
    return vec2(cos(angle), sin(angle))*sqrt(alpha);
}


vec3 nvec3(vec4 pos) {
    return pos.xyz/pos.w;
}



float cdist(vec2 coord) {
	vec2 vec = abs(coord*2.0-1.0);
	float d = max(vec.x,vec.y);
	return 1.0 - d*d;
}

float getnoise(vec2 pos) {
	return fract(sin(dot(pos ,vec2(18.9898f,28.633f))) * 4378.5453f);
}



vec3 getSkyColor(vec3 fposition) {
const vec3 moonlightS = vec3(0.00575, 0.0105, 0.014);
vec3 sVector = normalize(fposition);

float invRain07 = 1.0-rainStrength*0.4;
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
vec3 grad3 = mix(grad1,nsunlight*(1.0-isEyeInWater),sunscat*sunscat*(1.0-mCosT)*(0.9-rainStrength*0.5*0.9)*(clamp(-(SdotU)*4.0+3.0,0.0,1.0)*0.65+0.35)+0.1);

float Y2 = 3.14159265359-Y;
float L2 = L * (8.0*exp(d*Y2)+A);

const vec3 moonlight2 = pow(normalize(moonlightS),vec3(3.0))*length(moonlightS);
const vec3 moonlightRain = normalize(vec3(0.25,0.3,0.4))*length(moonlightS);

vec3 gradN = mix(moonlightS,moonlight2,1.-L2/2.0);
gradN = mix(gradN,moonlightRain,rainStrength);
return pow(L*(c*exp(d*Y)+A),invRain07)*sunVisibility *length(rawAvg) * (0.85+rainStrength*0.425)*grad3+ 0.2*pow(L2*1.2+1.2,invRain07)*moonVisibility*gradN;
}

vec3 decode (vec2 enc){
    vec2 fenc = enc*4-2;
    float f = dot(fenc,fenc);
    float g = sqrt(1-f/4.0);
    vec3 n;
    n.xy = fenc*g;
    n.z = 1-f/2;
    return n;
}




	
	
	  
	
		  

	
	
	
	
	
	
	


	
		
		
		

		
              
              
              
              

              

			  
			  
			  

			  
			  
			  


	

















	
		
		
		
		
		

		
              
              
              
              
              

              

	
		
		
		
		
		

		
              
              
              
              
              

              

              

              
              
              
	

	
		
		
		
		
		


		
              
              
              

              

              

	
		
		
		
		
		

		
              
              
              
              

              

              
              

              
              
              
	

	
		
		
		
		
		


		
              
              
              
              
              

              

              
              
              
	

	
		
		
		
		
		

		
              
              
              
              
              

              

              
              
              
	

	
		
		
		
		
		

		
              
              
              
              
              

              

              
              
              
	
			  
	
		
		
		
		
		

		
			  
              
              
              
              

              

			  
			  
			  
	

	
		
		
		
		
		

		
              
              
              
              
              

			  

			  
			  
			  
	

	
		
		
		
		
		

		
              
              
              
              

              

			  
			  
			  
	
	
	
		
		
		
		

		
			  
			  
			  
			  
			  

			  
			  
			  
	

	
		
		
		
		
		


		
              
              
              
              
              

              

		
		
		
		
		
		

		
              
              
              
              
              

              

              

			  
			  
			  
	

	
		
		
		
		
		


		
              
              
              
              
              

              


		
		
		
		
		
		


		
			  
			  
			  
			  
			  

			  

			  

			  
			  
			  
	

	
		
		
		
		
		

		
              
              
              
              
              

              

		
		
		
		
		
		

		
			  
			  
			  
			  
			  

			  

			  

			  
			  
			  
	

	
		
		
		
		
		


		
              
              
              
              
              

              

		
		
		
		
		
		

		
              
              
              
              
              

              

              

			  
			  
			  
	

	
		
		
		
		
		

		
              
              
              
              
              

              

		
		
		
		
		
		

			
			  
			  
			  
			  
			  

			  

			  

			  
			  
			  
	
        
	
        
        
        
        
        

        
              
              
              
              

              

              
              
              
	
		
	
        
        
        
        
        

        
              
              
              
              

              

              
              
              
	

	
        
        
        
        
		

        
              
              
              
              

              

              
              
              
	
   





    







	
	



	
		
		
		
		
		
		
		
		
		
	

	
	
	
		
		
		
		
		
		
		
		
		
	
	
	
	

	
		
		
	
	
	
	



		
		
			  
		
		
	
		

		
		
		
		
	
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		

		
		
		
			
			
			

			
			

			
			
	
		
	





	



	
	
	
	
	
		 		   
		 		   
		 		   

	
	
		 		   
		 		   
		 		   

	
		 

	
	







								
								
								
								
								
								
								


vec3 toScreenSpace(vec3 pos) {
	vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
	vec3 p3 = pos * 2.0 - 1.0;
    vec4 fragposition = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return fragposition.xyz / fragposition.w;
}





	

	
	
	
	
	
	
		  
	
	
	

	
	    
		
	
		
	
		
	
		

		

		
		
		

		
		
	
	







    



	
	
    
    	 

	

	

	

	
		
		
    	
			
			
		
	
    



uniform float sunElevation;
vec3 YCoCg2RGB(vec3 c){
	c.y-=0.5;
	c.z-=0.5;
	return vec3(c.r+c.g-c.b, c.r + c.b, c.r - c.g - c.b);
}

void main() {

//sample half-resolution buffer with correct texture coordinates
vec4 hr = pow(texture2D(composite,(floor(gl_FragCoord.xy/2.)*2+1.0)/vec2(viewWidth,viewHeight)/2.0),vec4(2.2,2.2,2.2,1.0))*vec4(257.,257,257,1.0);

//Setup depth
float depth0 = texture2D(depthtex0, texcoord).x;	//everything
float depth1 = texture2D(depthtex1, texcoord).x;	//transparency

bool sky = (depth0 >= 1.0);

vec4 albedo = texture2D(colortex0,texcoord);
vec3 normal = decode(texture2D(colortex1, texcoord).xy);
vec2 lightmap = texture2D(colortex1, texcoord.xy).zw;
bool translucent = albedo.b > 0.69 && albedo.b < 0.71;
bool emissive = albedo.b > 0.59 && albedo.b < 0.61;
vec3 color = vec3(albedo.rg,0.0);

vec2 a0 = texture2D(colortex0,texcoord + vec2(1.0/viewWidth,0.0)).rg;
vec2 a1 = texture2D(colortex0,texcoord - vec2(1.0/viewWidth,0.0)).rg;
vec2 a2 = texture2D(colortex0,texcoord + vec2(0.0,1.0/viewHeight)).rg;
vec2 a3 = texture2D(colortex0,texcoord - vec2(0.0,1.0/viewHeight)).rg;
vec4 lumas = vec4(a0.x,a1.x,a2.x,a3.x);
vec4 chromas = vec4(a0.y,a1.y,a2.y,a3.y);

vec4 w = 1.0-step(0.1176, abs(lumas - color.x));
float W = dot(w,vec4(1.0));
w.x = (W==0.0)? 1.0:w.x;  W = (W==0.0)? 1.0:W;

bool pattern = (mod(gl_FragCoord.x,2.0)==mod(gl_FragCoord.y,2.0));
color.b= dot(w,chromas)/W;
color.rgb = (pattern)?color.rbg:color.rgb;
color.rgb = YCoCg2RGB(color.rgb);
color = pow(color,vec3(2.2));

if (!sky){
//Water and Ice
vec3 Wnormal = texture2D(colortex2,texcoord).xyz;
bool iswater = Wnormal.z < 0.2499 && dot(Wnormal,Wnormal) > 0.0;
bool isice = Wnormal.z > 0.2499 && Wnormal.z < 0.4999 && dot(Wnormal,Wnormal) > 0.0;
bool isnsun = (iswater||isice) || ((!iswater||!isice) && isEyeInWater == 1);
/*--------------------------------------------------------------------------------------*/





vec3 TAAfragpos = toScreenSpace(vec3(texcoord,depth1));	//was depth0 before, might cause issues



	



	


float ao = 1.0;

	
	

	
	//Emissive blocks lighting and colors
	float torch_lightmap = 16.0-min(15.0,(lightmap.x-0.5/16.0)*16.0*16.0/15.0);
	float fallof1 = clamp(1.0 - pow(torch_lightmap/16.0,4.0),0.0,1.0);
	torch_lightmap = fallof1*fallof1/(torch_lightmap*torch_lightmap+1.0);
	float c_emitted = dot((color.rgb),vec3(1.0,0.6,0.4))/2.0;
	float emitted 		= emissive? clamp(c_emitted*c_emitted,0.0,1.0)*torch_lightmap : 0.0;
	vec3 emissiveLightC = vec3(1.5,0.42,0.045);
	/*------------------------------------------------------------------------------------------*/
	
	//Lighting and colors
	float NdotL = dot(normal,sunVec);
	float NdotU = dot(normal,upVec);
	
	const vec3 moonlight = vec3(0.5, 0.9, 1.8) * 0.003;

	vec2 visibility = vec2(sunVisibility,moonVisibility);

	float skyL = max(lightmap.y-2./16.0,0.0)*1.14285714286;	
	float SkyL2 = skyL*skyL;
	float skyc2 = mix(1.0,SkyL2,skyL);

	vec4 bounced = vec4(NdotL,NdotL,NdotL,NdotU) * vec4(-0.14*skyL*skyL,0.33,0.7,0.1) + vec4(0.6,0.66,0.7,0.25);
		 bounced *= vec4(skyc2,skyc2,visibility.x-tr*visibility.x,0.8);

	vec3 sun_ambient = bounced.w * (vec3(0.1, 0.5, 1.1)*2.4+rainStrength*2.3*vec3(0.05,-0.33,-0.9))+ 1.6*sunlight*(sqrt(bounced.w)*bounced.x*2.4 + bounced.z)*(1.0-rainStrength*0.99);
	vec3 moon_ambient = (moonlight*0.7 + moonlight*bounced.y)*4.0;

	//vec3 LightC = mix(sunlight,moonlight,moonVisibility)*tr*(1.0-rainStrength*0.99);
	vec3 LightC = mix(sunlight,moonlight,moonVisibility)*(1.0-rainStrength*0.99); //remove time check to smooth out day night transition
	vec3 amb1 = (sun_ambient*visibility.x + moon_ambient*visibility.y)*SkyL2*(0.03*0.65+tr*0.17*0.65);
	float finalminlight = (nightVision > 0.9)? 0.15 : 0.002; //add nightvision support but make sure minlight is still adjustable.	
	vec3 ambientC = ao*amb1 + emissiveLightC*(emitted*15.*color + torch_lightmap*ao)*0.66 + ao*finalminlight*min(skyL+6/16.,9/16.)*normalize(amb1+0.0001);
	/*----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

	//vec3 shadowLightpos = float(sunElevation > 1e-5)*2.0-1.0*normalize(mat3(gbufferModelViewInverse) *shadowLightPosition); //improves lighting but currently causes shadow acne
	//vec3 shadowLightpos = normalize(mat3(gbufferModelViewInverse) *shadowLightPosition);	
	float diffuse = translucent? 0.75 : clamp(dot(normal, normalize(shadowLightPosition)),0.0,1.0);	
	vec3 finalShading = vec3(diffuse);


	
	
		  
	
	float noise = fract(dot(gl_FragCoord.xy, vec2(0.5, 0.25))); //Use different dithering if TAA is disabled, because it looks better at low sample rate.
	
if (diffuse > 0.001) {
	vec3 shadowpos = mat3(gbufferModelViewInverse) * TAAfragpos.xyz + gbufferModelViewInverse[3].xyz;
		 shadowpos = mat3(shadowModelView) * shadowpos + shadowModelView[3].xyz;
		 shadowpos = vec3((shadowProjection)[0].x, (shadowProjection)[1].y, (shadowProjection)[2].z) * shadowpos + shadowProjection[3].xyz;
	float distortion = calcDistortion(shadowpos.xy);
		 shadowpos.xy *= distortion;
	vec2 shading = vec2(1.0); //set to 1.0 for raytraced shadows outside of shadowmap
	//only if on shadowmap
	if (abs(shadowpos.x) < 1.0-1.5/shadowMapResolution && abs(shadowpos.y) < 1.0-1.5/shadowMapResolution && abs(shadowpos.z) < 6.0){
		float pdepth = 1.412;	//fallback if penumbra shadows are disabled
		const float threshMul = max(2048.0/shadowMapResolution*shadowDistance/128.0,0.95);
		float distortThresh = (sqrt(1.0-diffuse*diffuse)/diffuse+0.7)/distortion;
		shadowpos = shadowpos * vec3(0.5,0.5,0.5/6.0) + vec3(0.5,0.5,0.5);

	
		
		
		
		
		
			

			
			

			
			
		
		
		
	

		//Setup shadows
		float rdMul = pdepth*distortion*0.05*k/shadowMapResolution;
		float bias = translucent? 0.00014 : distortThresh/6000.0*threshMul;
		shading = vec2(0.0); //set to 0.0 for shadowmap shadows
		for(int i = 0; i < 10; i++){
			vec2 offsetS = tapLocation(i,10,noise);

			float weight = 1.0+(i+noise)*rdMul/10*shadowMapResolution;
			shading.x += shadow2D(shadow,vec3(shadowpos + vec3(rdMul*offsetS,-bias*weight))).x/10;
		
			shading.y += shadow2D(shadowtex1,vec3(shadowpos + vec3(rdMul*offsetS,-bias*weight))).x/10;
		
		}
	}
	
	
		
	

	
		finalShading = texture2D(shadowcolor0, shadowpos.xy).rgb*(shading.y-shading.x) + shading.x;
		finalShading *= diffuse;
	
		
	

	//Prevent light leakage
	finalShading *= mix(skyL,1.0,clamp((eyeBrightnessSmooth.y/255.0-2.0/16.)*4.0,0.0,1.0));
}

	
	


	vec3 waterC = vec3(0.0,0.175,0.2);
	if(iswater || isEyeInWater == 1.0) LightC = mix(waterC,waterC*0.0125,moonVisibility)*(1.0-rainStrength*0.99); //water shading, wip
	color *= (finalShading*LightC*(isnsun?SkyL2*skyL:1.0)*2.15+ambientC*(isnsun?1.0/(SkyL2*skyL*0.5+0.5):1.0)*1.4)*0.63;
}

//Sky
vec2 ntc = texcoord*2.0;
vec2 ntc2 = texcoord*2.0-1.0;
vec3 c = vec3(0.0);

if (ntc.x < 1.0 && ntc.y < 1.0 && ntc.x > 0.0 && ntc.y > 0.0) {
	float depth1 = texture2D(depthtex1, ntc).x;
	float sky = 0.950-near/far/far;
		if (depth1 > sky) {
			vec4 fragpos = gbufferProjectionInverse * (vec4(ntc, depth1, 1.0) * 2.0 - 1.0);
			fragpos /= fragpos.w;
			//Draw sky
			c = getSkyColor(fragpos.xyz);
		}
}


	
		  

	float gr = 0.0;


//Godrays and lens flares
if (ntc2.x < 1.0 && ntc2.y < 1.0 && ntc2.x > 0.0 && ntc2.y > 0.0){


	vec2 deltatexcoord = vec2(lightPos - ntc2) * 0.04;
	vec2 noisetc = ntc2 + deltatexcoord*getnoise(ntc2) + deltatexcoord; //maybe doesnt need to be filtered
	bool underwater = (isEyeInWater == 1.0);

	for (int i = 0; i < grays_sample; i++) {
		float depth = underwater? texture2D(depthtex1, noisetc).x : texture2D(depthtex0, noisetc).x; //swap depth for now, wip
		noisetc += deltatexcoord;
		gr += dot(step(comp, depth), 1.0)*cdist(noisetc);
	}
	gr /= grays_sample;






}




	
		
		
		
		
		
	
	



//Draw sky (color)

	

	if (sky)color = hr.rgb;


gl_FragData[0] = vec4(c/30.0, 1.0);
gl_FragData[1] = vec4(pow(color/257.0,vec3(0.454)), gr);
}



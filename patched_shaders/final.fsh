#version 150 core
#define gl_FragData iris_FragData
#define gl_FragColor iris_FragData[0]
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
















































































































































































































































































































































































































/*
Thank you for downloading Sildur's vibrant shaders, make sure you got it from the official source found here:
https://sildurs-shaders.github.io/
*/

    
    
    
    
    
    
    
    
    
    
    
    
        
    
    



    
    
    
    
    
    
    
    
    
    
        

    
        
    

    

    
        
	    

    

    

    

    
    
    
    
    
    
        
    

    
    
    
    



	
    
	
		
	

	
	
	
		
        
    
		
		

	
		
		
		
        

	
	
	
    
    
    
    

    
    
    
    

	
	
	

	

    
    

	
	
	

    
        
    
    
        
    



    
    

    
    



    



    
    



    //#define Bloom

    

    //#define Refraction

    //#define Depth_of_Field	                //Simulates eye focusing on objects. Low performance impact
	    //#define Distance_Blur	                //Requires Depth of Field to be enabled. Replaces eye focusing effect with distance being blurred instead.
        

    //#define Motionblur		                //Blurres your view/camera during movemenent. Low performance impact. Doesn't work with Depth of Field.

    
	
    //Defined values for Optifine
    
    
    
    
	

    

 

    



    
    
    
    

    
    

    
    
    
    
    
    
    
    
    
    



    
    
    
    
    



    
    
    

    
    
    
    

    
    
    
    

    
    
    



    



	
    
	
	


varying vec2 texcoord;

uniform sampler2D gaux4;	//final image














uniform int isEyeInWater;

uniform float aspectRatio;
uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;
uniform float frameTimeCounter;


varying vec2 rainPos1;
varying vec2 rainPos2;
varying vec2 rainPos3;
varying vec2 rainPos4;
varying vec4 weights;



uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;










uniform mat4 gbufferModelViewInverse;


uniform float near;
uniform float far;
float ld(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));
}









	
	
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											



float comp = 1.0-near/far/far;
vec3 cblur(vec2 tc){
	float pw = 1.0 / viewWidth;
	float getdist = 1.0-(exp(-pow(ld(texture2D(depthtex1, tc).r)/256.0*far,4.0)*4.0));
	float pcoc = min(getdist*pw*20.0,pw*20.0);
	vec2 fast_blur[4] = vec2[4](vec2(0.0, -0.1),
								vec2(-0.1, 0.0),
								vec2(0.1, 0.0),
								vec2(0.0, 0.1));
	vec3 blurC = vec3(0.0);
	for (int i = 0; i < 4; i++) {
		blurC += texture2D(gaux4, tc + fast_blur[i]*pcoc*vec2(1.0,aspectRatio)).rgb;
	}
		blurC = blurC/4.0*50.0;

	return blurC;
}



float distratio(vec2 pos, vec2 pos2) {
	return distance(pos*vec2(aspectRatio,1.0),pos2*vec2(aspectRatio,1.0));
}
float gen_circular_lens(vec2 center, float size) {
	float dist=distratio(center,texcoord.xy)/size;
	return exp(-dist*dist);
}


vec3 Uncharted2Tonemap(vec3 x) {
	x*= 1.0;
	float A = 0.28;
	float B = 0.29;		
	float C = 0.10;
	float D = 0.2;
	float E = 0.025;
	float F = 0.35;
	return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}



    
    
    
    
    
    
    


	
	
	



void main() {


//Setup depths, do it here because amd drivers suck and texture reads outside of void main or functions are broken, thanks amd
float depth1 = texture2D(depthtex1, texcoord).x;
bool hand = !(depth1 < texture2D(depthtex2, texcoord).x); //is not hand cuz ! 


//Rainlens
float rainlens = 0.0;

	if (rainStrength > 0.02) {
		rainlens += gen_circular_lens(rainPos1,0.1)*weights.x;
		rainlens += gen_circular_lens(rainPos2,0.07)*weights.y;
		rainlens += gen_circular_lens(rainPos3,0.086)*weights.z;
		rainlens += gen_circular_lens(rainPos4,0.092)*weights.w;
	}/*----------------------------------------------------------*/


	vec2 fake_refract = vec2(0.0);

		

	vec2 newTC = clamp(texcoord + fake_refract * 0.01 * (rainlens+isEyeInWater*0.2),1.0/vec2(viewWidth,viewHeight),1.0-1.0/vec2(viewWidth,viewHeight));
	vec3 color = texture2D(gaux4, newTC.xy).rgb*50.0;



	

	if(depth1 > comp)color.rgb = cblur(newTC.xy);





	
	
	
	
	
	
	
	

	
	

	
		
			
			
		


	


	
	
	
		 
		 
		 
	
	
		 
		 
		 
		 

	
	

	
	
		
		
		
	
	




	

	color.rgb += rainlens*0.01; //draw rainlens
	
	vec3 curr = Uncharted2Tonemap(color*4.7);
	color = pow(curr/Uncharted2Tonemap(vec3(15.2)),vec3(1.0/2.2));


	

	
	
	
	
	
	

	
	
	

	
	
	
	
	


	


	


	


	


	


	


	


	


	


	gl_FragColor = vec4(color,1.0);
}



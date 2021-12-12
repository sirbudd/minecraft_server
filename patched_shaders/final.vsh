#version 150 core
#define varying out
#define attribute in
#define gl_Vertex vec4(Position, 1.0)
#define gl_ModelViewProjectionMatrix (gl_ProjectionMatrix * gl_ModelViewMatrix)
#define gl_ModelViewMatrix mat4(1.0)
#define gl_NormalMatrix mat3(1.0)
#define gl_Normal vec3(0.0, 0.0, 1.0)
#define gl_Color vec4(1.0, 1.0, 1.0, 1.0)
#define gl_MultiTexCoord7 vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord6 vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord5 vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord4 vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord3 vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord2 vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord1 vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord0 vec4(UV0, 0.0, 1.0)
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
out float iris_FogFragCoord;
in vec2 UV0;
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

    
    
    
    
    
    
    
    
    
    
    
    
        
    
    



    
    
    
    
    
    
    
    
    
    
        

    
        
    

    

    
        
	    

    

    

    

    
    
    
    
    
    
        
    

    
    
    
    



	
    
	
		
	

	
	
	
		
        
    
		
		

	
		
		
		
        

	
	
	
    
    
    
    

    
    
    
    

	
	
	

	

    
    

	
	
	

    
        
    
    
        
    



    
    

    
    



    



    
    



    //#define Bloom

    

    //#define Refraction

    //#define Depth_of_Field	                //Simulates eye focusing on objects. Low performance impact
	    //#define Distance_Blur	                //Requires Depth of Field to be enabled. Replaces eye focusing effect with distance being blurred instead.
        

    //#define Motionblur		                //Blurres your view/camera during movemenent. Low performance impact. Doesn't work with Depth of Field.

    
	
    //Defined values for Optifine
    
    
    
    
	

    

 

    



    
    
    
    

    
    

    
    
    
    
    
    
    
    
    
    



    
    
    
    
    



    
    
    

    
    
    
    

    
    
    
    

    
    
    



    



	
    
	
	


varying vec2 texcoord;


varying vec2 rainPos1;
varying vec2 rainPos2;
varying vec2 rainPos3;
varying vec2 rainPos4;
varying vec4 weights;
uniform ivec2 eyeBrightnessSmooth;
uniform float rainStrength;
uniform float frameTimeCounter;

vec2 noisepattern(vec2 pos) {
	return vec2(abs(fract(sin(dot(pos, vec2(83147.6995379f, 125370.887575f))))));
}


void main() {

	gl_Position = ftransform();
	texcoord = (gl_MultiTexCoord0).xy;


	const float lifetime = 4.0;		//water drop lifetime in seconds
	float ftime = frameTimeCounter*2.0/lifetime;  
	vec2 drop = vec2(0.0,fract(frameTimeCounter/20.0));
	rainPos1 = fract((noisepattern(vec2(-0.94386347*floor(ftime*0.5+0.25),floor(ftime*0.5+0.25))))*0.8+0.1 - drop);
	rainPos2 = fract((noisepattern(vec2(0.9347*floor(ftime*0.5+0.5),-0.2533282*floor(ftime*0.5+0.5))))*0.8+0.1- drop);
	rainPos3 = fract((noisepattern(vec2(0.785282*floor(ftime*0.5+0.75),-0.285282*floor(ftime*0.5+0.75))))*0.8+0.1- drop);
	rainPos4 = fract((noisepattern(vec2(-0.347*floor(ftime*0.5),0.6847*floor(ftime*0.5))))*0.8+0.1- drop);
	weights.x = 1.0-fract((ftime+0.5)*0.5);
	weights.y = 1.0-fract((ftime+1.0)*0.5);
	weights.z = 1.0-fract((ftime+1.5)*0.5);
	weights.w = 1.0-fract(ftime*0.5);
	weights *= rainStrength*clamp((eyeBrightnessSmooth.y-220)/15.0,0.0,1.0);

}



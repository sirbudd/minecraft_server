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

    //#define SSAO                              //Toggle custom ambient occlusion, work in progress.
    const float ambientOcclusionLevel = 1.0f;   //Adjust minecrafts inbuild ambient occlusion. [0.0f 0.1f 0.2f 0.3f 0.4f 0.5f 0.6f 0.7f 0.8f 0.9f 1.0f]

    //#define Celshading						//Cel shades everything, making it look somewhat like Borderlands.

    
    //#define Refractions						//Toggle refractions / distortion caused by waves.
    //#define skyReflection						//Reflect and blend the default skycolor. Makes water waves more visible. WIP

    //#define Godrays							//Toggle godrays
    
    

    //Debugging stuff
    //#define depthbuffer						//Draw depth buffer
    //#define draw_refnormals					//Draw reflection normals, actually composite normals but only reflections are stored in the buffer.



    
    

    
    



    

    
	
        
	    
	    
	
    
	    

    
        



    



    

    

    

    
        
        

    
    
    
    
    
    
    
    
    
    
    
    

    

    
    
    
    
    

    
    
    
    

    
    
    
    
    
    
    
    
    
    
    

    



    
    
    


varying vec2 texcoord;
varying vec4 color;



uniform vec3 sunPosition;
uniform mat4 gbufferProjection;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_MultiTexCoord0).xy;

	
	
	
	


	color = gl_Color;
}



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
uniform vec3 shadowLightPosition;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D texture;
uniform sampler2D gnormal; //used by reflections and celshading
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform float viewWidth;
uniform float viewHeight;
uniform float near;
uniform float far;
uniform int isEyeInWater;

vec3 decode (vec2 enc){
    vec2 fenc = enc*4-2;
    float f = dot(fenc,fenc);
    float g = sqrt(1-f/4.0);
    vec3 n;
    n.xy = fenc*g;
    n.z = 1-f/2;
    return n;
}

float cdist(vec2 coord) {
	return clamp(1.0 - max(abs(coord.s-0.5),abs(coord.t-0.5))*2.0, 0.0, 1.0);
}

vec3 screenSpace(vec2 coord, float depth){
	vec4 pos = gbufferProjectionInverse * (vec4(coord, depth, 1.0) * 2.0 - 1.0);
	return pos.xyz/pos.w;
}




									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									


	
	
    
    




	
	
	
	
	

	
	    
		

		

		

		

		
		
		

		
		
	
	




uniform mat4 gbufferProjection;
uniform ivec2 eyeBrightnessSmooth;

vec3 nvec3(vec4 pos) {
    return pos.xyz/pos.w;
}

vec4 raytrace(vec4 color, vec3 normal) {
	vec3 fragpos0 = screenSpace(texcoord.xy, texture2D(depthtex0, texcoord.xy).x);
	vec3 rvector = reflect(fragpos0.xyz, normal.xyz);
		 rvector = normalize(rvector);
	
	vec3 start = fragpos0 + rvector;
	vec3 tvector = rvector;
    int sr = 0;
	const int maxf = 3;				//number of refinements
	const float ref = 0.2;			//refinement multiplier
	const int rsteps = 15;
	const float inc = 2.2;			//increasement factor at each step	
    for(int i=0;i<rsteps;i++){
        vec3 pos = nvec3(gbufferProjection * vec4(start, 1.0)) * 0.5 + 0.5;
        if(pos.x < 0 || pos.x > 1 || pos.y < 0 || pos.y > 1 || pos.z < 0 || pos.z > 1.0) break;
        vec3 fragpos1 = screenSpace(pos.xy, texture2D(depthtex1, pos.st).x);
        float err = distance(start, fragpos1);
		if(err < pow(length(rvector),1.35)){
                sr++;
                if(sr >= maxf){
                    color = texture2D(texture, pos.st);
					color.a = cdist(pos.st);
					break;
                }
				tvector -= rvector;
                rvector *= ref;

}
        rvector *= inc;
        tvector += rvector;
		start = fragpos0 + tvector;
	}

    return color;
}/*--------------------------------------*/









	


	

	
	
		 
	
		 
	
	
		  
		  
	
	


	

	
	
	
	
	

	
	

	







	


	
	
	

	
				   
				   
				   
	
	
	
				   
				   
				   

	
		 

	
	







	


	

	

	


	
	
		
		
		
	
	

	
	
	







void main() {

	vec4 tex = texture2D(texture, texcoord.xy)*color;
	vec3 normal = texture2D(gnormal, texcoord.xy).xyz; //vec2 for normals, z=mat
	vec3 newnormal = decode(normal.xy);

	float getmat = normal.z*2.0;
	//bool iswater = getmat > 0.9 && getmat < 1.1;
	bool isreflective = getmat > 0.9 && getmat < 2.1;
	bool isice = getmat > 1.9 && getmat < 2.1;


	
	



	



if(isreflective && isEyeInWater < 0.9){
	
		
		
	
		vec4 relfcolor = tex;
	
	vec4 reflection = raytrace(relfcolor, newnormal.xyz);	
	//tex.rgb = mix(tex.rgb, reflection.rgb, tex.a*reflection.a);

 	vec3 normfrag1 = normalize(screenSpace(texcoord.xy, texture2D(depthtex1, texcoord.xy).x));

	vec3 rVector = reflect(normfrag1, normalize(newnormal.xyz));
	vec3 hV= normalize(rVector - normfrag1);
	
	float normalDotEye = dot(hV, normfrag1);
	float F0 = 0.09;
	float fresnel = pow(clamp(1.0 + normalDotEye,0.0,1.0), 4.0) ;
		  fresnel = fresnel+F0*(1.0-fresnel);
		

	
		 
	
		 


		 reflection.rgb = mix(relfcolor.rgb, reflection.rgb, reflection.a); //maybe change tex with skycolor
		 tex.rgb = mix(tex.rgb, reflection.rgb, fresnel*1.25);
}



	













	gl_FragData[0] = tex;
	gl_FragData[1] = vec4(0.0); //improves performance
}



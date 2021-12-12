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














































































































































































































































































































































































































/* DRAWBUFFERS:01 */


/*
Thank you for downloading Sildur's vibrant shaders, make sure you got it from the official source found here:
https://sildurs-shaders.github.io/
*/

    
    
    
    
    
    
    
    
    
    
    
    
        
    
    



    
    
    
    
    
    
    
    
    
    
        

    
        
    

    

    
        
	    

    

    

    

    
    
    
    
    
    
        
    

    
    
    
    



	
    
	
		
	

	
	
	
		
        
    
		
		

	
		
		
		
        

	
	
	
    
    
    
    

    
    
    
    

	
	
	

	

    
    

	
	
	

    
        
    
    
        
    



    
    

    
    



    



    
    



    

    

    

    
	    
        

    

    
	
    
    
    
    
    
	

    

 

    



    
    
    
    

    //#define metallicRefl        //Toggle reflections for blocks defined in block.properties
    //#define polishedRefl        //Toggle reflections for polished blocks defined in block.properties

    
    
    
    
    
    
    
    
    
    



    
    
    
    
    



    
    
    

    
    
    
    

    
    
    
    

    
    
    



    



	
    
	
	


/* Don't remove me
const int colortex0Format = RGBA16;
const int colortex1Format = RGBA16;
const int colortex2Format = RGBA16; //Entities etc
const int colortex3Format = R11F_G11F_B10F;
const int gaux1Format = RGBA16;
const int gaux2Format = R11F_G11F_B10F;
const int gaux3Format = R11F_G11F_B10F;		
const int gaux4Format = R11F_G11F_B10F;	
-----------------------------------------*/

varying vec4 color;
varying vec4 texcoord;
varying vec4 normal;
varying vec3 worldpos;
varying vec3 viewVector;
varying mat3 tbnMatrix;

uniform sampler2D texture;
//uniform sampler2D specular;
uniform sampler2D noisetex;

//encode normal in two channel (xy), emissive lightmap (z) and sky lightmap (w), blend mode must be disabled in shaders.properties for this to work without issues.
vec4 encode (vec3 n){
    return vec4(n.xy*inversesqrt(n.z*8.0+8.0) + 0.5, texcoord.zw);
}

vec3 RGB2YCoCg(vec3 c){
	return vec3( 0.25*c.r+0.5*c.g+0.25*c.b, 0.5*c.r-0.5*c.b +0.5, -0.25*c.r+0.5*c.g-0.25*c.b +0.5);
}
vec3 newnormal = normal.xyz;














	



	
	
	
		
		
		
		
		
	
		
	
	
	
	
	

	





	



	

	
	
	
	
	

	
	

	



	
	

	
	
	



void irisMain() {

	vec4 albedo = texture2D(texture, texcoord.xy)*color;
	
 	
	

	
	
	
	
		
	
	
		
	
	
		
		 	 
		
		
	
	

	vec4 cAlbedo = vec4(RGB2YCoCg(albedo.rgb),albedo.a);

	bool pattern = (mod(gl_FragCoord.x,2.0)==mod(gl_FragCoord.y,2.0));
	cAlbedo.g = (pattern)?cAlbedo.b: cAlbedo.g;
	cAlbedo.b = normal.a;

	gl_FragData[0] = cAlbedo;
	gl_FragData[1] = encode(newnormal.xyz);

}


void main() {
    irisMain();

    if (!(gl_FragData[0].a > 0.1)) {
        discard;
    }
}

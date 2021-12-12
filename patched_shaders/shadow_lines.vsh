#version 150 core
#define varying out
#define attribute in
#define gl_Vertex vec4(Position + iris_vertex_offset, 1.0)
#define gl_ModelViewProjectionMatrix (gl_ProjectionMatrix * gl_ModelViewMatrix)
#define gl_ModelViewMatrix (iris_ModelViewMat * _iris_internal_translate(iris_ChunkOffset))
#define gl_NormalMatrix mat3(transpose(inverse(gl_ModelViewMatrix)))
#define gl_Normal vec3(0.0, 0.0, 1.0)
#define gl_Color (Color * iris_ColorModulator)
#define gl_MultiTexCoord7  vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord6  vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord5  vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord4  vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord3  vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord2  vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord1 vec4(240.0, 240.0, 0.0, 1.0)
#define gl_MultiTexCoord0 vec4(0.5, 0.5, 0.0, 1.0)
#define gl_ProjectionMatrix iris_ProjMat
#define gl_FrontColor iris_FrontColor
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
out float iris_FogFragCoord;
vec4 iris_FrontColor;
uniform mat4 iris_ProjMat;
uniform vec4 iris_ColorModulator;
in vec4 Color;
in vec3 Normal;
uniform mat4 iris_ModelViewMat;
uniform vec3 iris_ChunkOffset;
mat4 _iris_internal_translate(vec3 offset) {
    // NB: Column-major order
    return mat4(1.0, 0.0, 0.0, 0.0,
                0.0, 1.0, 0.0, 0.0,
                0.0, 0.0, 1.0, 0.0,
                offset.x, offset.y, offset.z, 1.0);
}
vec3 iris_vertex_offset = vec3(0.0);
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

    
    
    
    
    const float shadowDistance = 70.0;			//Render distance of shadows. 60=lite, 80=med, 80=high, 120=extreme [60.0 70.0 80.0 90.0 100.0 110.0 120.0 130.0 140.0 150.0 160.0 170.0 180.0 190.0 200.0 210.0 220.0 230.0 240.0 250.0 260.0 270.0 280.0 290.0 300.0 310.0 320.0 330.0 340.0 350.0 360.0 370.0 380.0 390.0 400.0]
    const int shadowMapResolution = 512;		//Shadows resolution. [256 512 1024 2048 3072 4096 6144 8192 16384] 512=lite, 1024=med, 2048=high, 3072=extreme 
    const float k = 1.8;
    
    
    float a = exp(0.05);
    float b = (exp(1.4)-a)*shadowDistance/128.0;
    float calcDistortion(vec2 worldpos){
        return 1.0/(log(length(worldpos)*b+a)*k);
    }
    



    
    
    
    
    
    
    
    
    
    
        

    
        
    

    

    
        
	    

    

    

    

    
    
    
    
    
    
        
    

    
    
    
    



	
    
	
		
	

	
	
	
		
        
    
		
		

	
		
		
		
        

	
	
	
    
    
    
    

    
    
    
    

	
	
	

	

    
    

	
	
	

    
        
    
    
        
    



    
    

    
    



    



    
    



    

    

    

    
	    
        

    

    
	
    
    
    
    
    
	

    

 

    



    
    
    
    

    
    

    
    
    
    
    
    
    
    
    
    



    
    
    
    
    



    
    
    

    
    
    
    

    
    
    
    

    
    
    



    



	
    
	
	



varying vec4 texcoord;
attribute vec4 mc_Entity;

vec2 calcShadowDistortion(in vec2 shadowpos) {
  float distortion = log(length(shadowpos.xy)*b+a)*k;
  return shadowpos.xy / distortion;
}


void irisMain() {

vec4 position = gl_ModelViewProjectionMatrix * gl_Vertex;


	position.xy = calcShadowDistortion(position.xy);
	position.z /= 6.0;

	texcoord.xy = (gl_MultiTexCoord0).xy;
	texcoord.z = 0.0;
	texcoord.w = 0.0;
	if(mc_Entity.x == 10008.0) texcoord.z = 1.0;
	
	
	

	gl_Position = position;
}


uniform vec2 iris_ScreenSize;
uniform float iris_LineWidth;

// Widen the line into a rectangle of appropriate width
// Isolated from Minecraft's rendertype_lines.vsh
// Both arguments are positions in NDC space (the same space as gl_Position)
void iris_widen_lines(vec4 linePosStart, vec4 linePosEnd) {
    vec3 ndc1 = linePosStart.xyz / linePosStart.w;
    vec3 ndc2 = linePosEnd.xyz / linePosEnd.w;

    vec2 lineScreenDirection = normalize((ndc2.xy - ndc1.xy) * iris_ScreenSize);
    vec2 lineOffset = vec2(-lineScreenDirection.y, lineScreenDirection.x) * iris_LineWidth / iris_ScreenSize;

    if (lineOffset.x < 0.0) {
        lineOffset *= -1.0;
    }

    if (gl_VertexID % 2 == 0) {
        gl_Position = vec4((ndc1 + vec3(lineOffset, 0.0)) * linePosStart.w, linePosStart.w);
    } else {
        gl_Position = vec4((ndc1 - vec3(lineOffset, 0.0)) * linePosStart.w, linePosStart.w);
    }
}

void main() {
    iris_vertex_offset = Normal;
    irisMain();
    vec4 linePosEnd = gl_Position;
    gl_Position = vec4(0.0);

    iris_vertex_offset = vec3(0.0);
    irisMain();
    vec4 linePosStart = gl_Position;

    iris_widen_lines(linePosStart, linePosEnd);
}

#version 420
#extension GL_EXT_gpu_shader4 : enable

// Phong Vertex shader obtained from Richard Southern

//#extension GL_ARB_shading_language_420pack: enable    // Use for GLSL versions before 420.

// The modelview and projection matrices are no longer given in OpenGL 4.2
uniform mat4 MVP;
uniform mat4 MV;
//uniform mat4 P;
uniform mat3 N; // This is the inverse transpose of the mv matrix
uniform mat4 textureMatrix;
uniform vec3 LightPosition;
uniform  vec4  inColour;
// The vertex position attribute
layout (location=0) in vec3 VertexPosition;

// The texture coordinate attribute
layout (location=1) in vec2 TexCoord;

// The vertex normal attribute
layout (location=2) in vec3 VertexNormal;

// These attributes are passed onto the shader (should they all be smoothed?)
smooth out vec3 FragPosition;
smooth out vec3 WSVertexPosition;
smooth out vec3 WSVertexNormal;
smooth out vec2 WSTexCoord;

out vec4  ShadowCoord;
out vec4  Colour;

void main()
{
    vec4 ecPosition = MV * vec4(VertexPosition,1.0);
    vec3 ecPosition3 = (vec3(ecPosition)) / ecPosition.w;
    vec3 VP = LightPosition - ecPosition3;
    VP = normalize(VP);
    vec3 normal = normalize(N * VertexNormal);
    float diffuse = max(0.0, dot(normal, VP));
    vec4 texCoord = textureMatrix * vec4(VertexPosition,1.0);
    ShadowCoord   = texCoord;
    Colour  = vec4(diffuse * inColour.rgb, inColour.a);
//    gl_Position    = MVP * vec4(VertexPosition,1.0);

    // Transform the vertex normal by the inverse transpose modelview matrix
    WSVertexNormal = normalize(N * VertexNormal);

    // Compute the unprojected vertex position
    WSVertexPosition = vec3(MV * vec4(VertexPosition, 1.0) );

    // Copy across the texture coordinates
    WSTexCoord = TexCoord;

    FragPosition = VertexPosition;

    // Compute the position of the vertex
    gl_Position = MVP * vec4(VertexPosition,1.0);
}

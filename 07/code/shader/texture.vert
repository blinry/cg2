#version 330
layout(location = 0) in vec3 vertex;
layout(location = 1) in vec3 vertex_normal;
// add texture coordinates to your available vertex attributes //
layout(location = 2) in vec2 vertex_texcoord;

const int maxLightCount = 10;

// these struct help to organize all the uniform parameters //
struct LightSource {
  vec3 ambient_color;
  vec3 diffuse_color;
  vec3 specular_color;
  vec3 position;
};

uniform LightSource lightSource[maxLightCount];
uniform int usedLightCount;

// out variables to be passed to the fragment shader //
out vec3 vertexNormal;
out vec3 eyeDir;
out vec3 lightDir[maxLightCount];
// add the texture coordinate as in/out variable to be passed to the fragment program //
out vec2 texCoord;

// modelview and projection matrix //
uniform mat4 modelview;
uniform mat4 projection;

void main() {
  int lightCount = max(min(usedLightCount, maxLightCount), 0);
  
  // normal matrix //
  mat4 normalMatrix = transpose(inverse(modelview));
  
  // transform vertex position and the vertex normal using the appropriate matrices //
  vertexNormal = (normalMatrix * vec4(vertex_normal, 0)).xyz;
  gl_Position = projection * modelview * vec4(vertex, 1.0);
  
  // compute per vertex camera direction //
  vec3 vertexInCamSpace = (modelview * vec4(vertex, 1.0)).xyz;
  
  // vector from vertex to camera and from vertex to light //
  eyeDir = -vertexInCamSpace;
  
  // vertex to light for every light source! //
  for (int i = 0; i < lightCount; ++i) {
    vec3 lightInCamSpace = (modelview * vec4(lightSource[i].position, 1.0)).xyz;
    lightDir[i] = lightInCamSpace - vertexInCamSpace;
  }
  
  // write texcoord //
  texCoord = vertex_texcoord;
}

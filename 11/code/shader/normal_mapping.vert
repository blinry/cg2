#version 330
layout(location = 0) in vec3 vertex;
layout(location = 1) in vec3 vertex_normal;
layout(location = 2) in vec2 vertex_texcoord;
layout(location = 3) in vec3 vertex_tangent;
layout(location = 4) in vec3 vertex_binormal;

const int maxLightCount = 10;

// these struct help to organize all the uniform parameters //
struct LightSource {
  vec3 ambient_color;
  vec3 diffuse_color;
  vec3 specular_color;
  vec3 position;
  float power;
};

uniform LightSource lightSource[maxLightCount];
uniform int usedLightCount;

// out variables to be passed to the fragment shader //
out vec3 vertexNormal; // not needed anymore, when using normal maps //
out vec3 eyeDir;
out vec3 lightDir[maxLightCount];
out vec2 textureCoord;

// modelview and projection matrix //
uniform mat4 lightmat;
uniform mat4 modelview;
uniform mat4 projection;

void main() {
  int lightCount = max(min(usedLightCount, maxLightCount), 0);

  // normal matrix //
  mat4 normalMatrix = transpose(inverse(modelview));

  vec3 tangent = (normalMatrix * vec4(vertex_tangent, 0)).xyz;
  vec3 binormal = (normalMatrix * vec4(vertex_binormal, 0)).xyz;
  vec3 normal = (normalMatrix * vec4(vertex_normal, 0)).xyz;

  vertexNormal = normal;
  gl_Position = projection * modelview * vec4(vertex, 1.0);

  // compute tangent space conversion matrix //
  // use transpose of matrix //
  mat3 World2TangentSpace = mat3(tangent.x, binormal.x, normal.x,
                                 tangent.y, binormal.y, normal.y,
                                 tangent.z, binormal.z, normal.z);

  // compute per vertex camera direction //
  vec3 vertexInCamSpace = (modelview * vec4(vertex, 1.0)).xyz;

  // vector from vertex to camera and from vertex to light //
  eyeDir = World2TangentSpace * -vertexInCamSpace;

  // vertex to light for every light source! //
  for (int i = 0; i < lightCount; ++i) {
    vec3 lightInCamSpace = (lightmat * vec4(lightSource[i].position, 1.0)).xyz;
    lightDir[i] = World2TangentSpace * (lightInCamSpace - vertexInCamSpace);
  }

  // write texcoord //
  textureCoord = vertex_texcoord;
}
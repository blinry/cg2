#version 330
const int maxLightCount = 10;

struct LightSource {
  vec3 ambient_color;
  vec3 diffuse_color;
  vec3 specular_color;
  vec3 position;
};

struct Material {
  vec3 ambient_color;
  vec3 diffuse_color;
  vec3 specular_color;
  float specular_shininess;
};

uniform LightSource lightSource[maxLightCount];
uniform int usedLightCount;
uniform Material material;

// variables passed from vertex to fragment program //
in vec3 vertexNormal;
in vec3 eyeDir;
in vec3 lightDir[maxLightCount];
// TODO: add a texture coordinate as a vertex attribute //


// texture //
// TODO: set up a texture uniform //


// this defines the fragment output //
out vec4 color;

void main() {
  // TODO: get the texel value from your texture at the position of the passed texture coordinate //
  

  int lightCount = max(min(usedLightCount, maxLightCount), 0);
  // normalize the vectors passed from your vertex program //
  vec3 E = normalize(eyeDir);
  vec3 N = normalize(vertexNormal);
  
  // compute the ambient, diffuse and specular color terms //
  vec3 ambientTerm = vec3(0);
  vec3 diffuseTerm = vec3(0);
  vec3 specularTerm = vec3(0);
  vec3 L, H;
  for (int i = 0; i < lightCount; ++i) {
    L = normalize(lightDir[i]);
    H = normalize(E + L);
    ambientTerm += lightSource[i].ambient_color;
    diffuseTerm += lightSource[i].diffuse_color * max(dot(L, N), 0);
    specularTerm += lightSource[i].specular_color * pow(max(dot(H, N), 0), material.specular_shininess);
  }
  ambientTerm *= material.ambient_color;
  diffuseTerm *= material.diffuse_color;
  specularTerm *= material.specular_color;
  
  // assign the final color to the fragment output variable //
  // TODO: combine the light/material color and the texture color properly //
  
}
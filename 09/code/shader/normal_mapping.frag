#version 330
const int maxLightCount = 10;

struct LightSource {
  vec3 ambient_color;
  vec3 diffuse_color;
  vec3 specular_color;
  vec3 position;
  float power;
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
in vec2 textureCoord;

// texture //
uniform sampler2D diffuseTexture;
uniform sampler2D normalMap;

// this defines the fragment output //
out vec4 color;

void main() {
  // earth color //
  vec3 diffuse = texture2D(diffuseTexture, textureCoord).rgb;

  // light computation //
  int lightCount = max(min(usedLightCount, maxLightCount), 0);
  // normalize the vectors passed from your vertex program //
  vec3 E = normalize(eyeDir); // eye dir is already in tangent space, when using normal maps //
  vec3 N = normalize(texture2D(normalMap, textureCoord).rgb * 2 - 1); // get the normal from the texture //

  // compute the ambient, diffuse and specular color terms //
  vec3 ambientTerm = vec3(0);
  vec3 diffuseTerm = vec3(0);
  vec3 specularTerm = vec3(0);
  vec3 L, H;
  for (int i = 0; i < lightCount; ++i) {
    L = lightDir[i];
    float Ldist = 1.0 / pow(length(L),2);
    float Lpower = lightSource[i].power;
    H = normalize(E + normalize(L));
    ambientTerm += Ldist * Lpower * lightSource[i].ambient_color;
    diffuseTerm += Ldist * Lpower * lightSource[i].diffuse_color * max(dot(L, N), 0);
    specularTerm += Ldist * Lpower * lightSource[i].specular_color * pow(max(dot(H, N), 0), material.specular_shininess);
  }
  ambientTerm *= material.ambient_color;
  diffuseTerm *= material.diffuse_color;
  specularTerm *= material.specular_color;

  // assign the final color to the fragment output variable //
  color = vec4(diffuse, 1) * vec4(ambientTerm + diffuseTerm + specularTerm, 1);
}

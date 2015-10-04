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
in vec3 io_lightPos[maxLightCount];
in vec2 io_texCoord;

// texture //
uniform sampler2D diffuseTexture;

// pass 1 input //
uniform sampler2D def_vertexMap;
uniform sampler2D def_normalMap;
uniform sampler2D def_texCoordMap;

// this defines the fragment output //
out vec4 color;

void main() {
  // TODO?: get position in camera space //
  vec3 def_vertex = texture2D(def_vertexMap, io_texCoord).xyz;

  //discard pixels not covered by any geometry
  if(length(def_vertex) < 0.000001)
	  discard;

  // TODO?: get texture coordinates //
  vec2 textureCoord = texture2D(def_texCoordMap, io_texCoord).xy;

  // TODO?: eye vector //
  vec3 E = normalize(-def_vertex);

  // TODO?: normal in camera space normal //
  vec3 N = normalize(texture2D(def_normalMap, io_texCoord).xyz);

  // light computation //
  int lightCount = max(min(usedLightCount, maxLightCount), 0);
  // compute the ambient, diffuse and specular color terms //
  vec3 ambientTerm = vec3(0);
  vec3 diffuseTerm = vec3(0);
  vec3 specularTerm = vec3(0);
  vec3 L, H;
  for (int i = 0; i < lightCount; ++i) {
    L = io_lightPos[i] - def_vertex;
    float Ldist = 1.0 / pow(length(L), 2);
    float Lpower = Ldist * lightSource[i].power;
    H = normalize(E + normalize(L));
    ambientTerm += Lpower * lightSource[i].ambient_color;
    diffuseTerm += Lpower * lightSource[i].diffuse_color * max(dot(L, N), 0);
    specularTerm += Lpower * lightSource[i].specular_color * pow(max(dot(H, N), 0), material.specular_shininess);
  }
  ambientTerm *= material.ambient_color;
  diffuseTerm *= material.diffuse_color;
  specularTerm *= material.specular_color;

  // TODO?: get diffuse texture color //
  vec3 diffuse = texture2D(diffuseTexture, textureCoord).xyz;

  // TODO?: assign the final color to the fragment output variable //
  color = vec4(diffuse, 1) * vec4(ambientTerm + diffuseTerm + specularTerm, 1);
}

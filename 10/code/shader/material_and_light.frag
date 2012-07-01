#version 330

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

uniform LightSource lightSource;
uniform Material material;

in vec3 vertexNormal;
in vec3 eyeDir;
in vec3 lightDir;

// this defines the fragment output //
out vec4 color;

uniform int drawShadows;

void main() {
  // TODO: add an option to switch between normal lighting and shadow color (black) rendering //
  if(drawShadows == 1) {
      color = vec4(1,0,0,0.3);
      return;
  }
  
  vec3 E = normalize(eyeDir);
  vec3 N = normalize(vertexNormal);
    
  vec3 ambientTerm = vec3(0);
  vec3 diffuseTerm = vec3(0);
  vec3 specularTerm = vec3(0);
  vec3 L, H;
    
  L = normalize(lightDir);
  H = normalize(E + L);
  ambientTerm += lightSource.ambient_color;
  diffuseTerm += lightSource.diffuse_color * max(dot(L, N), 0);
  specularTerm += lightSource.specular_color * pow(max(dot(H, N), 0), material.specular_shininess);
  
  ambientTerm *= material.ambient_color;
  diffuseTerm *= material.diffuse_color;
  specularTerm *= material.specular_color;
  
  color = vec4(ambientTerm + diffuseTerm + specularTerm, 1);
}

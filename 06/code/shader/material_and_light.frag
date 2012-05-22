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

// TODO: set up uniforms for multiple light sources //

// uniform for the used material //
uniform Material material;

// fragment normal //
in vec3 vertexNormal;
// vector from fragment to camera //
in vec3 eyeDir;

// TODO: vector from fragment to light per light source //

// this defines the fragment output //
out vec4 color;

void main() {
  // normalize the vectors passed from your vertex program here //
  vec3 E = normalize(eyeDir);
  vec3 N = normalize(vertexNormal);
  
  // init the ambient, diffuse and specular color terms //
  vec3 ambientTerm = vec3(0);
  vec3 diffuseTerm = vec3(0);
  vec3 specularTerm = vec3(0);
  
  // TODO: compute the ambient, diffuse and specular color terms for every used light source //
  
  // assign the final color to the fragment output variable //
  color = vec4(ambientTerm + diffuseTerm + specularTerm, 1);
}
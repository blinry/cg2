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
uniform LightSource ls[10];
uniform int activeLightSources;

// uniform for the used material //
uniform Material material;
//uniform LightSource lightsource;

// fragment normal //
in vec3 vertexNormal;
// vector from fragment to camera //
in vec3 eyeDir;

// TODO: vector from fragment to light per light source //
in vec3 lightVec[10];

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
  for(int i = 0; i < activeLightSources; i++)
  {
	  ambientTerm += ls[i].ambient_color * material.ambient_color;
	  diffuseTerm += ls[i].diffuse_color * material.diffuse_color * clamp(dot(N, normalize(lightVec[i])), 0, 1);
	  vec3 halfway = normalize(E + normalize(lightVec[i]));
	  specularTerm += ls[i].specular_color * material.specular_color * pow(clamp(dot(halfway, N), 0, 1), material.specular_shininess);
  }
  
  // assign the final color to the fragment output variable //
  color = vec4(ambientTerm + diffuseTerm + specularTerm, 1);
}

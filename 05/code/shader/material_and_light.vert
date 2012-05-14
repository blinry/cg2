#version 330
layout(location = 0) in vec3 vertex;
layout(location = 1) in vec3 vertex_normal;

// these struct help to organize all the uniform parameters //
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

// TODO: define out variables to be passed to the fragment shader //
// - define variables for vertex normal, camera vector and light vector
// - also define variables to pass color information to the fragment shader
//   (ambient, diffuse and specular color and the shininess exponent)

// modelview and projection matrix //
uniform mat4 modelview;
uniform mat4 projection;

void main() {
  // TODO: pass the light-material color information to the fragment program
  // - as presented in the lecture, you just need to combine light and material color here
  // - assign the final values to your defined out-variables
  
  // TODO: create a normal matrix by inverting and transposing the modelview matrix //
  
  // TODO: transform vertex position and the vertex normal using the appropriate matrices //
  // - assign the transformed vertex position (modelview & projection) to 'gl_Position'
  // - assign the transformed vertex normal (normal matrix) to your out-variable as defined above
  
  // TODO: compute the vectors from the current vertex towards the camera and towards the light source //
  
}
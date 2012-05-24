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

// TODO: set up uniforms for multiple light sources //


// vertex normal //
out vec3 vertexNormal;
// vector from vertex to camera //
out vec3 eyeDir;

// TODO: vector from fragment to light per light source //

// modelview and projection matrix //
uniform mat4 modelview;
uniform mat4 projection;

void main() {
  // create a normal matrix by inverting and transposing the modelview matrix //
  mat4 normalMatrix = transpose(inverse(modelview));
  // transform vertex position and the vertex normal using the appropriate matrices //
  vertexNormal = (normalMatrix * vec4(vertex_normal, 0)).xyz;
  gl_Position = projection * modelview * vec4(vertex, 1.0);
  
  // compute per vertex camera direction //
  vec3 vertexInCamSpace = (modelview * vec4(vertex, 1.0)).xyz;
  // vector from vertex to camera and from vertex to light //
  eyeDir = -vertexInCamSpace;
  
  // TODO: compute the vectors from the current vertex towards every light source //
}
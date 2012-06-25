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

uniform LightSource lightSource;

// TODO: define out variables to be passed to the fragment shader //
// - define variables for vertex normal, camera vector and light vector
out vec3 vertexNormal;
out vec3 eyeDir;
out vec3 lightDir;

// modelview and projection matrix //
uniform mat4 modelview;
uniform mat4 projection;

void main() {
  // create a normal matrix by inverting and transposing the modelview matrix //
  mat4 normalMatrix = transpose(inverse(modelview));
  // TODO: transform vertex position and the vertex normal using the appropriate matrices //
  // - assign the transformed vertex position (modelview & projection) to 'gl_Position'
  // - assign the transformed vertex normal (normal matrix) to your out-variable as defined above
  vertexNormal = (normalMatrix * vec4(vertex_normal, 0)).xyz;
  gl_Position = projection * modelview * vec4(vertex, 1.0);
  // TODO: compute the vectors from the current vertex towards the camera and towards the light source //
  // compute per vertex camera direction //
  vec3 vertexInCamSpace = (modelview * vec4(vertex, 1.0)).xyz;
  
  // vector from vertex to camera and from vertex to light //
  eyeDir = -vertexInCamSpace;
  // vertex to light for every light source! //
  vec3 lightInCamSpace = (modelview * vec4(lightSource.position, 1.0)).xyz;
  lightDir = lightInCamSpace - vertexInCamSpace;
}
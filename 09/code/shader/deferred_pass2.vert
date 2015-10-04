#version 330
layout(location = 0) in vec3 vertex;
layout(location = 2) in vec2 vertex_texcoord;

const int maxLightCount = 10;

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
out vec3 io_lightPos[maxLightCount];
out vec2 io_texCoord;

// modelview and projection matrix //
uniform mat4 view;
uniform mat4 modelview;
uniform mat4 projection;

void main() {
  gl_Position = projection * modelview * vec4(vertex, 1.0);

  // TODO?: compute vertex to light vector for every light source! //
  for (int i = 0; i < usedLightCount; ++i) {
      vec3 lightInCamSpace = (view*vec4(lightSource[i].position,1)).xyz;
      io_lightPos[i] = lightInCamSpace;
  }

  // write texcoord //
  io_texCoord = vertex_texcoord;
}

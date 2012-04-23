#version 330
layout(location = 0) in vec3 vertex;
layout(location = 1) in vec3 normal;
out vec3 vertexColor;

uniform  mat4 modelview;
uniform  mat4 projection;

void main() {
  vertexColor = (modelview * vec4(normal, 0)).xyz;
  gl_Position = projection * modelview * vec4(vertex, 1.0);
}

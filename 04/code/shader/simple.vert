#version 330
layout(location = 0) in vec3 vertex;
layout(location = 1) in vec3 vertex_normal;
layout(location = 2) in vec4 vertex_color;

out vec3 vertexColor;

uniform  mat4 modelview;
uniform  mat4 projection;

void main() {
  vertexColor = (modelview * vec4(vertex_normal, 0)).xyz;
  gl_Position = projection * modelview * vec4(vertex, 1.0);
}

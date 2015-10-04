#version 330
in vec3 vertexColor;
out vec4 color;

uniform vec3 override_color;
uniform int use_override_color;

void main() {
  if (use_override_color == 0) {
    color = vec4(0.5 * normalize(vertexColor) + vec3(0.5, 0.5, 0.5), 1);
  } else {
    color = vec4(override_color, 1.0);
  }
}

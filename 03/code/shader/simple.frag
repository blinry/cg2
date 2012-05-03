#version 330
in vec3 vertexColor;
out vec4 color;

void main() {
  color = vec4(0.5 * normalize(vertexColor) + vec3(0.5, 0.5, 0.5), 1);  
  //color = out_vertexColor;
  //color = vec4(1, 1, 1, 1);
}

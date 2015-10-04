#version 330
layout(location = 0) in vec3 vertex;
layout(location = 1) in vec3 vertex_normal;
layout(location = 2) in vec2 vertex_texcoord;
layout(location = 3) in vec3 vertex_tangent;
layout(location = 4) in vec3 vertex_binormal;

// out variables to be passed to the fragment shader //
out vec3 io_vertex;
out vec3 io_tangent;
out vec3 io_binormal;
out vec3 io_normal;
out vec2 io_texCoord;

// modelview and projection matrix //
uniform mat4 modelview;
uniform mat4 projection;

void main() {
  gl_Position = projection * modelview * vec4(vertex, 1.0);

  // TODO: vertex position in camera space //
  io_vertex = (modelview * vec4(vertex, 1.0)).xyz;

  // normal matrix //
  mat4 normalMatrix = transpose(inverse(modelview));

  // TODO: tangent, bitangent and normal //
  io_tangent = (normalMatrix * vec4(vertex_tangent, 0.0)).xyz;
  io_binormal = (normalMatrix * vec4(vertex_binormal, 0.0)).xyz;
  io_normal = (normalMatrix * vec4(vertex_normal, 0.0)).xyz;

  // TODO: texture coord //
  io_texCoord = vertex_texcoord;
}

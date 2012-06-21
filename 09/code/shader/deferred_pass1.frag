#version 330
// variables passed from vertex to fragment program //
in vec3 io_vertex;
in vec3 io_tangent;
in vec3 io_binormal;
in vec3 io_normal;
in vec2 io_texCoord;

// TODO: define your fragment outputs here //

// normal map //
uniform sampler2D normalMap;

void main() {
  // TODO: write position in cam space //
  
  // TODO: compute modified surface normal //
  
  // TODO: write modified normal in camera space //
  
  // TODO: write texture coordinate //

}
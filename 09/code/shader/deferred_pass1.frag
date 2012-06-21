#version 330
// variables passed from vertex to fragment program //
in vec3 io_vertex;
in vec3 io_tangent;
in vec3 io_binormal;
in vec3 io_normal;
in vec2 io_texCoord;

// TODO: define your fragment outputs here //
out vec4 vertex_pos;
out vec4 vertex_normal;
out vec4 vertex_texcoord;

// normal map //
uniform sampler2D normalMap;

void main() {
	// TODO: write position in cam space //
	vertex_pos = vec4(io_vertex, 1.0);

	// TODO: compute modified surface normal //
	vec3 n = texture2D(normalMap, io_texCoord).xyz * 2 - vec3(1);

	mat3 Tangent2CamSpace = inverse(mat3(tangent.x, binormal.x, normal.x,
			tangent.y, binormal.y, normal.y,
			tangent.z, binormal.z, normal.z));

	n = (Tangent2CamSpace * n).xyz;

	// TODO: write modified normal in camera space //
	vertex_normal = vec4(n, 0);

	// TODO: write texture coordinate //
	vertex_texcoord = vec4(io_texCoord, 0, 0);

}

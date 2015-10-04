#version 330

// TODO: again define your variables passed from vertex to fragment program here
// - use 'in' as qualifier now
// - make sure to use the exakt same names

in vec3 VertNorm;
in vec3 VecToCam;
in vec3 VecToLight;
in vec3 AmbColor;
in vec3 DiffColor;
in vec3 SpecColor;
in float shiniExpo;

// this defines the fragment output //
out vec4 color;

void main() {
  // TODO: normalize the vectors passed from your vertex program here //
  // - this needs to be done, because the interpolation of these vectors is linear //

vec3 Normal   =  normalize(VertNorm);
vec3 LightDir =  normalize(VecToLight);
vec3 EyeDir   =  normalize(VecToCam);

  // TODO: compute the half-way-vector for our specular component //
vec3 HalfWay = normalize(EyeDir+LightDir);
  // TODO: compute the ambient, diffuse and specular color terms as presented in the lecture //


float NdotL = max(0.0, dot(Normal,LightDir));
float NdotH = max(0.0, dot(Normal,HalfWay));
float k     = pow(NdotH, shiniExpo);

  // TODO: assign the final color to the fragment output variable //
 color = vec4(DiffColor * NdotL,1.0)+vec4(AmbColor,0.0)+vec4(SpecColor * k, 0.0);
}
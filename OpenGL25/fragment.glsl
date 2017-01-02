#version 440

struct Light
{
    vec3 pos;
    vec3 color;
};

struct Material
{
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float shininess;
};

in vec3 fragNormal;
in vec4 fragPos;
in vec2 reflFragTexCoor; // !!!

uniform vec3 eyePos;
uniform Light light;
uniform Material material;

uniform samplerCube textureSkybox;
uniform sampler2D reflMap;

out vec4 color;

void main()
{
  vec3 I = normalize(fragPos.xyz - eyePos);
  vec3 R = reflect(I, normalize(fragNormal));

  // diffuse
  vec3 lightDir = normalize(light.pos - fragPos.xyz);
  vec3 diffuse = max(dot(fragNormal, lightDir), 0.0)*light.color*material.diffuse;

  // specular
  vec3 viewDir = normalize(eyePos - fragPos.xyz);
  vec3 reflDir = reflect(-lightDir, fragNormal);
  vec3 specular = pow(max(dot(viewDir, reflDir), 0.0), material.shininess)*light.color*material.specular;

  vec3 mirror = texture(textureSkybox, R).rgb;
  vec3 reflection = texture(reflMap, reflFragTexCoor).rgb;

  if(reflection.r >= 0.9) {
      color = vec4(material.ambient + diffuse + specular + mirror, 1.0);
  } else {
     color = vec4(material.ambient + diffuse + specular, 1.0);
  }


}

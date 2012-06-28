#include <GL/glew.h>
#include <GL/freeglut.h>
#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/matrix_inverse.hpp>
#include <glm/gtx/rotate_vector.hpp>
#include <glm/gtx/string_cast.hpp> 

#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <stack>
#include <cmath>

#include "ObjLoader.h"
#include "CameraController.h"

#include <sstream>
#include <opencv/cv.h>
#include <opencv/highgui.h>

std::stack<glm::mat4> glm_ProjectionMatrix; 
std::stack<glm::mat4> glm_ModelViewMatrix; 

// OpenGL and GLSL stuff //
void initGL();
void initShader();
bool enableShader();
void disableShader();
void deleteShader();
char* loadShaderSource(const char* fileName);
GLuint loadShaderFile(const char* fileName, GLenum shaderType);
// the used shader program //
GLuint shaderProgram = 0;
// this map stores uniform locations of our shader program //
std::map<std::string, GLint> uniformLocations;

// this struct helps to keep light source parameter uniforms together //
struct UniformLocation_Light {
  GLint ambient_color;
  GLint diffuse_color;
  GLint specular_color;
  GLint position;
};
// this map stores the light source uniform locations as 'UniformLocation_Light' structs //
std::map<std::string, UniformLocation_Light> uniformLocations_Lights;

// these structs are also used in the shader code  //
// this helps to access the parameters more easily //
struct Material {
  glm::vec3 ambient_color;
  glm::vec3 diffuse_color;
  glm::vec3 specular_color;
  float specular_shininess;
};

struct LightSource {
  LightSource() : enabled(true) {};
  bool enabled;
  glm::vec3 ambient_color;
  glm::vec3 diffuse_color;
  glm::vec3 specular_color;
  glm::vec3 position;
};

// the program uses a list of materials and light sources, which can be chosen during rendering //
unsigned int materialIndex;
unsigned int materialCount;
std::vector<Material> materials;
// #INFO# only one light source used //
LightSource light;
bool lightSourcePosUpdate = true;
glm::vec3 initialLightPos(0, 0, 0);

// window controls //
void updateGL();
void idle();
void keyboardEvent(unsigned char key, int x, int y);
void mouseEvent(int button, int state, int x, int y);
void mouseMoveEvent(int x, int y);

// camera controls //
CameraController camera(0, M_PI/4, 40);

// viewport //
GLint windowWidth, windowHeight;

// geometry //
void initScene();
void renderScene();

// OBJ import //
ObjLoader objLoader;
// local meshes //
MeshObj *screenQuad = NULL;

int CheckGLErrors() {
  int errCount = 0;
  for(GLenum currError = glGetError(); currError != GL_NO_ERROR; currError = glGetError()) {
    std::stringstream sstr;
    
    switch (currError) {
      case GL_INVALID_ENUM : sstr << "GL_INVALID_ENUM"; break;
      case GL_INVALID_VALUE : sstr << "GL_INVALID_VALUE"; break;
      case GL_INVALID_OPERATION : sstr << "GL_INVALID_OPERATION"; break;
      case GL_INVALID_FRAMEBUFFER_OPERATION : sstr << "GL_INVALID_FRAMEBUFFER_OPERATION"; break;
      case GL_OUT_OF_MEMORY : sstr << "GL_OUT_OF_MEMORY"; break;
      default : sstr << "unknown error (" << currError << ")";
    }
    std::cout << "found error: " << sstr.str() << std::endl;
    ++errCount;
  }
 
  return errCount;
}


int main (int argc, char **argv) {
  glutInit(&argc, argv);
  // Done TODO: activate stencil buffer //
  glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH | GLUT_STENCIL);
  glutInitContextVersion(3,3);
  glutInitContextFlags(GLUT_FORWARD_COMPATIBLE);
  glutInitContextProfile(GLUT_CORE_PROFILE);

  windowWidth = 512;
  windowHeight = 512;
  glutInitWindowSize(windowWidth, windowHeight);
  glutInitWindowPosition(100, 100);
  glutCreateWindow("Exercise 10 - Shadow Volumes");
  
  glutDisplayFunc(updateGL);
  glutIdleFunc(idle);
  glutKeyboardFunc(keyboardEvent);
  glutMouseFunc(mouseEvent);
  glutMotionFunc(mouseMoveEvent);
  
  glewExperimental = GL_TRUE;
  GLenum err = glewInit();
  if (GLEW_OK != err) {
    std::cout << "(glewInit) - Error: " << glewGetErrorString(err) << std::endl;
  }
  std::cout << "(glewInit) - Using GLEW " << glewGetString(GLEW_VERSION) << std::endl;
  
  // init stuff //
  initGL();
  
  // init matrix stacks with identity //
  glm_ProjectionMatrix.push(glm::mat4(1));
  glm_ModelViewMatrix.push(glm::mat4(1));
  
  initShader();
  initScene();
  
  // start render loop //
  if (enableShader()) {
    glutMainLoop();
    disableShader();
    
    // clean up allocated data //
    deleteShader();
  }
  
  return 0;
}

void initGL() {
  glClearColor(0.0, 0.0, 0.0, 0.0);
  glEnable(GL_DEPTH_TEST);
}

std::string getUniformStructLocStr(const std::string &structName, const std::string &memberName, int arrayIndex = -1) {
  std::stringstream sstr("");
  sstr << structName;
  if (arrayIndex >= 0) {
    sstr << "[" << arrayIndex << "]";
  }
  sstr << "." << memberName;
  return sstr.str();
}

// load and compile shader code //
char* loadShaderSource(const char* fileName) {
  char *shaderSource = NULL;
  
  std::ifstream file(fileName, std::ios::in);
  if (file.is_open()) {
    unsigned long srcLength = 0;
    file.tellg();
    file.seekg(0, std::ios::end);
    srcLength = file.tellg();
    file.seekg(0, std::ios::beg);
    shaderSource = new char[srcLength+1];
    file.read(shaderSource, srcLength);
    shaderSource[srcLength] = '\0';
    file.close();
  } else {
    std::cout << "(loadShaderSource) - Could not open file \"" << fileName << "\"." << std::endl;
  }
  
  return shaderSource;
}

// loads a source file and directly compiles it to a shader of 'shaderType' //
GLuint loadShaderFile(const char* fileName, GLenum shaderType) {
  GLuint shader = glCreateShader(shaderType);
  // check if operation failed //
  if (shader == 0) {
    std::cout << "(loadShaderFile) - Could not create shader." << std::endl;
    return 0;
  }
  
  // load source code from file //
  const char* shaderSrc = loadShaderSource(fileName);
  if (shaderSrc == NULL) return 0;
  // pass source code to new shader object //
  glShaderSource(shader, 1, (const char**)&shaderSrc, NULL);
  delete[] shaderSrc;
  // compile shader //
  glCompileShader(shader);
  
  // log compile messages, if any //
  int logMaxLength;
  glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logMaxLength);
  char log[logMaxLength];
  int logLength = 0;
  glGetShaderInfoLog(shader, logMaxLength, &logLength, log);
  if (logLength > 0) {
    std::cout << "(loadShaderFile) - Compiler log:\n------------------\n" << log << "\n------------------" << std::endl;
  }
  
  // return compiled shader (may have compiled WITH errors) //
  return shader;
}

bool loadShaderCode(const char* vertProgramCode, GLuint &vertProgram, const char* fragmentProgramCode, GLuint &fragProgram) {
  vertProgram = loadShaderFile(vertProgramCode, GL_VERTEX_SHADER);
  fragProgram = loadShaderFile(fragmentProgramCode, GL_FRAGMENT_SHADER);
  
  if (vertProgram == 0) {
    std::cout << "(initShader) - Could not create vertex shader." << std::endl;
    deleteShader();
    return false;
  }
  if (fragProgram == 0) {
    std::cout << "(initShader) - Could not create fragment shader." << std::endl;
    deleteShader();
    return false;
  }
  return true;
}

bool attachAndLink(GLuint shaderProgram, GLuint vertexProgram, GLuint fragmentProgram) {
  // successfully loaded and compiled shaders -> attach them to program //
  glAttachShader(shaderProgram, vertexProgram);
  glAttachShader(shaderProgram, fragmentProgram);
  
  // mark shaders for deletion after clean up (they will be deleted, when detached from all shader programs) //
  glDeleteShader(vertexProgram);
  glDeleteShader(fragmentProgram);
  
  // link shader program //
  glLinkProgram(shaderProgram);
  
  // get log //
  int logMaxLength;
  glGetProgramiv(shaderProgram, GL_INFO_LOG_LENGTH, &logMaxLength);
  char log[logMaxLength];
  int logLength = 0;
  glGetProgramInfoLog(shaderProgram, logMaxLength, &logLength, log);
  if (logLength > 0) {
    std::cout << "(initShader) - Linker log:\n------------------\n" << log << "\n------------------" << std::endl;
    return false;
  }
  
  return true;
}

GLuint createShader(const char* vertexProgramCode, const char* fragmentProgramCode) {
  GLuint program = 0;
  
  program = glCreateProgram();
  // check if operation failed //
  if (program == 0) {
    std::cout << "(initShader) - Failed creating shader program." << std::endl;
    return 0;
  }
  
  GLuint vertexShader = 0;
  GLuint fragmentShader = 0;
  if (!loadShaderCode(vertexProgramCode, vertexShader, fragmentProgramCode, fragmentShader)) {
    glDeleteProgram(program);
    return 0;
  }
  
  if (!attachAndLink(program, vertexShader, fragmentShader)) {
    glDeleteProgram(program);
    return 0;
  }
  
  return program;
}

void initShader() {
  shaderProgram = createShader("../shader/material_and_light.vert", "../shader/material_and_light.frag");
  // check if operation failed //
  if (shaderProgram == 0) {
    std::cout << "(initShader) - Failed creating shader program." << std::endl;
    return;
  }

  // set address of fragment color output //
  glBindFragDataLocation(shaderProgram, 0, "color");
  
  // get uniform locations for common variables //
  uniformLocations["projection"] = glGetUniformLocation(shaderProgram, "projection");
  uniformLocations["modelview"] = glGetUniformLocation(shaderProgram, "modelview");
  uniformLocations["drawShadows"]= glGetUniformLocation(shaderProgram, "drawShadows");
  
  // material unform locations //
  uniformLocations["material.ambient"] = glGetUniformLocation(shaderProgram, "material.ambient_color");
  uniformLocations["material.diffuse"] = glGetUniformLocation(shaderProgram, "material.diffuse_color");
  uniformLocations["material.specular"] = glGetUniformLocation(shaderProgram, "material.specular_color");
  uniformLocations["material.shininess"] = glGetUniformLocation(shaderProgram, "material.specular_shininess");
  
  // store the uniform locations for all light source properties
  UniformLocation_Light lightLocation;
  lightLocation.ambient_color = glGetUniformLocation(shaderProgram, getUniformStructLocStr("lightSource", "ambient_color").c_str());
  lightLocation.diffuse_color = glGetUniformLocation(shaderProgram, getUniformStructLocStr("lightSource", "diffuse_color").c_str());
  lightLocation.specular_color = glGetUniformLocation(shaderProgram, getUniformStructLocStr("lightSource", "specular_color").c_str());
  lightLocation.position = glGetUniformLocation(shaderProgram, getUniformStructLocStr("lightSource", "position").c_str());
  uniformLocations_Lights["light"] = lightLocation;
}

bool enableShader() {
  if (shaderProgram > 0) {
    glUseProgram(shaderProgram);
  } else {
    std::cout << "(enableShader) - Shader program not initialized." << std::endl;
  }
  return shaderProgram > 0;
}

void disableShader() {
  glUseProgram(0);
}

void deleteShader() {
  // use standard pipeline //
  glUseProgram(0);
  // delete shader program //
  glDeleteProgram(shaderProgram);
  shaderProgram = 0;
}

void initScene() {
  camera.setFar(1000.0f);
  
  // load scene.obj from disk and create renderable MeshObj //
  objLoader.loadObjFile("../meshes/testbox.obj", "sceneObject");
  
  // init materials //
  Material mat;
  mat.ambient_color = glm::vec3(1.0, 1.0, 1.0);
  mat.diffuse_color = glm::vec3(0.8, 1.0, 0.5);
  mat.specular_color = glm::vec3(1.0, 1.0, 1.0);
  mat.specular_shininess = 5.0;
  materials.push_back(mat);
  
  // save material count for later and select first material //
  materialCount = materials.size();
  materialIndex = 0;
  
  // init light //
  light.ambient_color = glm::vec3(0.05, 0.05, 0.05);
  light.diffuse_color = glm::vec3(1.0, 1.0, 1.0);
  light.specular_color = glm::vec3(1.0, 1.0, 1.0);
  light.position = initialLightPos;
}

void setupLightAndMaterial() {
  // uploads the properties of the currently active light sources here //
  UniformLocation_Light &light_uniform = uniformLocations_Lights["light"];
  glUniform3fv(light_uniform.position, 1, glm::value_ptr(light.position));
  glUniform3fv(light_uniform.ambient_color, 1, glm::value_ptr(light.ambient_color));
  glUniform3fv(light_uniform.diffuse_color, 1, glm::value_ptr(light.diffuse_color));
  glUniform3fv(light_uniform.specular_color, 1, glm::value_ptr(light.specular_color));
  
  // uploads the chosen material properties here //
  glUniform3fv(uniformLocations["material.ambient"], 1, glm::value_ptr(materials[materialIndex].ambient_color));
  glUniform3fv(uniformLocations["material.diffuse"], 1, glm::value_ptr(materials[materialIndex].diffuse_color));
  glUniform3fv(uniformLocations["material.specular"], 1, glm::value_ptr(materials[materialIndex].specular_color));
  glUniform1f(uniformLocations["material.shininess"], materials[materialIndex].specular_shininess);
}

// #INFO# creates a screen filling quad as a new MeshObj (stored in screenQuad) //
void initScreenFillingQuad(void) {
  screenQuad = new MeshObj();
  MeshData mesh;
  std::vector<glm::vec3> vertices;
  std::vector<glm::vec2> texCoords;
  std::vector<int> indices;
  
  // geometry //
  vertices.push_back(glm::vec3(0, 0, 0));
  texCoords.push_back(glm::vec2(0, 0));
  vertices.push_back(glm::vec3(1, 0, 0));
  texCoords.push_back(glm::vec2(1, 0));
  vertices.push_back(glm::vec3(1, 1, 0));
  texCoords.push_back(glm::vec2(1, 1));
  vertices.push_back(glm::vec3(0, 1, 0));
  texCoords.push_back(glm::vec2(0, 1));
  
  // two triangles //
  indices.push_back(0);
  indices.push_back(1);
  indices.push_back(2);
  indices.push_back(0);
  indices.push_back(2);
  indices.push_back(3);
  
  for (std::vector<glm::vec3>::iterator vertex = vertices.begin(); vertex != vertices.end(); ++vertex) {
    mesh.vertex_position.push_back(vertex->x);
    mesh.vertex_position.push_back(vertex->y);
    mesh.vertex_position.push_back(vertex->z);
  }
  for (std::vector<glm::vec2>::iterator texCoord = texCoords.begin(); texCoord != texCoords.end(); ++texCoord) {
    mesh.vertex_texcoord.push_back(texCoord->x);
    mesh.vertex_texcoord.push_back(texCoord->y);
  }
  for (std::vector<int>::iterator index = indices.begin(); index != indices.end(); ++index) {
    mesh.indices.push_back(*index);
  }
  
  screenQuad->setData(mesh);
}

// #INFO#: this renders the scene object usign material and lighting //
void renderScene() {
  glm_ModelViewMatrix.push(glm_ModelViewMatrix.top());
  
  glm_ModelViewMatrix.top() *= glm::scale(glm::vec3(10));
  
  glUniformMatrix4fv(uniformLocations["modelview"], 1, false, glm::value_ptr(glm_ModelViewMatrix.top()));
  
  // setup light and material in shader //
  setupLightAndMaterial();

  // render the actual object //
  MeshObj *mesh = objLoader.getMeshObj("sceneObject");
  mesh->render();
  
  // restore scene graph to previous state //
  glm_ModelViewMatrix.pop();
}

// #INFO# this renders a screen filling quad                                      //
// - note that it resets the modelview and projection to an orthogonal projection //
void renderScreenFillingQuad() {
  glDisable(GL_DEPTH_TEST);
  
  if (!screenQuad) initScreenFillingQuad();
  
  // upload transformation matrices matrix for orthogonal projection //
  glUniformMatrix4fv(uniformLocations["projection"], 1, false, glm::value_ptr(glm::ortho(0.0f, 1.0f, 0.0f, 1.0f)));
  glUniformMatrix4fv(uniformLocations["modelview"], 1, false, glm::value_ptr(glm::mat4(1)));
  screenQuad->render();
  
  glEnable(GL_DEPTH_TEST);
}

// TODO: render the shadow volume here using the chosen shadow volume rendering technique //
void renderShadow() {
  // #INFO# init shadow volume if light source position has changed //
  if (lightSourcePosUpdate) {
    objLoader.getMeshObj("sceneObject")->initShadowVolume(light.position);
    lightSourcePosUpdate = false;
  }
  
  // TODO: disable drawing to screen (we just want to change the stencil buffer) //
  
  // TODO: enable stencil test and face culling //
  // - we need face culling to separately render front facing and back facing triangles //
  
  // TODO: implement the shadow volume rendering //
  
  // TODO: final render pass -> render screen quad with current stencil buffer //
  // - disable face culling and re-enable writing to color and depth buffer    //
  
  // - set stencil operation to only execute, when stencil buffer is not equal to zero //
  
  // OPTION: enable blend function to prevent shadows from being pitch black //
  // - uses alpha of color defined when rendering the screen filling quad    //
  
  renderScreenFillingQuad();
  
  // TODO: disable stencil testing for further rendering and restore original rendering state //
}

void updateGL() {
  // TODO: also clear the stencil buffer before rendering again //
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  // set viewport dimensions //
  glViewport(0, 0, windowWidth, windowHeight);
  
  // get projection mat from camera controller //
  glm_ProjectionMatrix.top() = camera.getProjectionMat();
  // upload projection matrix //
  glUniformMatrix4fv(uniformLocations["projection"], 1, false, glm::value_ptr(glm_ProjectionMatrix.top()));
  
  // init scene graph by cloning the top entry, which can now be manipulated //
  // get modelview mat from camera controller //
  glm_ModelViewMatrix.top() = camera.getModelViewMat();
  
  // #INFO# render scene //
  renderScene();
  
  // #INFO# render shadow volume //
  renderShadow();
  
  // swap renderbuffers for smooth rendering //
  glutSwapBuffers();
}

void idle() {
  glutPostRedisplay();
}

void keyboardEvent(unsigned char key, int x, int y) {
  switch (key) {
    case 'x':
    case 27 : {
      exit(0);
      break;
    }
    case 'w': {
      // move forward //
      camera.move(CameraController::MOVE_FORWARD);
      break;
    }
    case 's': {
      // move backward //
      camera.move(CameraController::MOVE_BACKWARD);
      break;
    }
    case 'a': {
      // move left //
      camera.move(CameraController::MOVE_LEFT);
      break;
    }
    case 'd': {
      // move right //
      camera.move(CameraController::MOVE_RIGHT);
      break;
    }
    case 'z': {
      camera.setOpeningAngle(camera.getOpeningAngle() + 0.1f);
      break;
    }
    case 'h': {
      camera.setOpeningAngle(std::min(std::max(camera.getOpeningAngle() - 0.1f, 1.0f), 180.0f));
      break;
    }
    case 'r': {
      camera.setNear(std::min(camera.getNear() + 0.1f, camera.getFar() - 0.01f));
      break;
    }
    case 'f': {
      camera.setNear(std::max(camera.getNear() - 0.1f, 0.1f));
      break;
    }
    case 't': {
      camera.setFar(camera.getFar() + 0.1f);
      break;
    }
    case 'g': {
      camera.setFar(std::max(camera.getFar() - 0.1f, camera.getNear() + 0.01f));
      break;
    }
    case 'm': {
      materialIndex++;
      if (materialIndex >= materialCount) materialIndex = 0;
      break;
    }
    case '5': {
      // reset light pos //
      light.position = initialLightPos;
      lightSourcePosUpdate = true;
      break;
    }
    case '4': {
      // move light source left //
      light.position.x -= 0.05f;
      lightSourcePosUpdate = true;
      break;
    }
    case '6': {
      // move light source right //
      light.position.x += 0.05f;
      lightSourcePosUpdate = true;
      break;
    }
    case '2': {
      // move light source backward //
      light.position.z += 0.05f;
      lightSourcePosUpdate = true;
      break;
    }
    case '8': {
      // move light source forward //
      light.position.z -= 0.05f;
      lightSourcePosUpdate = true;
      break;
    }
    case '+': {
      // move light source up //
      light.position.y += 0.05f;
      lightSourcePosUpdate = true;
      break;
    }
    case '-': {
      // move light source down //
      light.position.y -= 0.05f;
      lightSourcePosUpdate = true;
      break;
    }
  }
  glutPostRedisplay();
}

void mouseEvent(int button, int state, int x, int y) {
  CameraController::MouseState mouseState;
  if (state == GLUT_DOWN) {
    switch (button) {
      case GLUT_LEFT_BUTTON : {
        mouseState = CameraController::LEFT_BTN;
        break;
      }
      case GLUT_RIGHT_BUTTON : {
        mouseState = CameraController::RIGHT_BTN;
        break;
      }
      default : break;
    }
  } else {
    mouseState = CameraController::NO_BTN;
  }
  camera.updateMouseBtn(mouseState, x, y);
  glutPostRedisplay();
}

void mouseMoveEvent(int x, int y) {
  camera.updateMousePos(x, y);
  glutPostRedisplay();
}


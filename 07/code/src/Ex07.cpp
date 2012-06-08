#include "Ex07.h"
#include <sstream>
#include <opencv\cv.h>
#include <opencv\highgui.h>

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
unsigned int lightCount;
std::vector<LightSource> lights;

// NEW: texture stuff //
// - OpenGL texture handle
GLuint texture;
// - Container for texture data
struct TextureData {
  TextureData() : data(NULL), width(0), height(0) {};
  unsigned char *data;
  unsigned int width;
  unsigned int height;
};
// - method to initialize the texture object
void initTextures();
// - method to load a texture from a given file
TextureData loadTextureData(const char *fileName);

// window controls //
void updateGL();
void idle();
void keyboardEvent(unsigned char key, int x, int y);
void mouseEvent(int button, int state, int x, int y);
void mouseMoveEvent(int x, int y);

// camera controls //
CameraController camera(0, M_PI/4, 10);

// viewport //
GLint windowWidth, windowHeight;

// geometry //
void initScene();
void renderScene();

// OBJ import //
ObjLoader objLoader;


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
  glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
  glutInitContextVersion(3,3);
  glutInitContextFlags(GLUT_FORWARD_COMPATIBLE);
  glutInitContextProfile(GLUT_CORE_PROFILE);

  windowWidth = 512;
  windowHeight = 512;
  glutInitWindowSize(windowWidth, windowHeight);
  glutInitWindowPosition(100, 100);
  glutCreateWindow("Exercise 07 - Textures");
  
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
  initTextures();
  
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

void initShader() {
  shaderProgram = glCreateProgram();
  // check if operation failed //
  if (shaderProgram == 0) {
    std::cout << "(initShader) - Failed creating shader program." << std::endl;
    return;
  }
  
  GLuint vertexShader = loadShaderFile("../shader/texture.vert", GL_VERTEX_SHADER);
  if (vertexShader == 0) {
    std::cout << "(initShader) - Could not create vertex shader." << std::endl;
    deleteShader();
    return;
  }
  GLuint fragmentShader = loadShaderFile("../shader/texture.frag", GL_FRAGMENT_SHADER);
  if (fragmentShader == 0) {
    std::cout << "(initShader) - Could not create vertex shader." << std::endl;
    deleteShader();
    return;
  }
  
  // successfully loaded and compiled shaders -> attach them to program //
  glAttachShader(shaderProgram, vertexShader);
  glAttachShader(shaderProgram, fragmentShader);
  
  // mark shaders for deletion after clean up (they will be deleted, when detached from all shader programs) //
  glDeleteShader(vertexShader);
  glDeleteShader(fragmentShader);
  
  // link shader program //
  glLinkProgram(shaderProgram);
  
  // get log //
  /*int logMaxLength;
  glGetProgramiv(shaderProgram, GL_INFO_LOG_LENGTH, &logMaxLength);
  char log[logMaxLength];
  int logLength = 0;
  glGetProgramInfoLog(shaderProgram, logMaxLength, &logLength, log);
  if (logLength > 0) {
    std::cout << "(initShader) - Linker log:\n------------------\n" << log << "\n------------------" << std::endl;
  }*/
  
  // set address of fragment color output //
  glBindFragDataLocation(shaderProgram, 0, "color");
  
  // get uniform locations for common variables //
  uniformLocations["projection"] = glGetUniformLocation(shaderProgram, "projection");
  uniformLocations["modelview"] = glGetUniformLocation(shaderProgram, "modelview");
  
  // material unform locations //
  uniformLocations["material.ambient"] = glGetUniformLocation(shaderProgram, "material.ambient_color");
  uniformLocations["material.diffuse"] = glGetUniformLocation(shaderProgram, "material.diffuse_color");
  uniformLocations["material.specular"] = glGetUniformLocation(shaderProgram, "material.specular_color");
  uniformLocations["material.shininess"] = glGetUniformLocation(shaderProgram, "material.specular_shininess");
  
  // store the uniform locations for all light source properties
  for (int i = 0; i < 10; ++i) {
    UniformLocation_Light lightLocation;
    lightLocation.ambient_color = glGetUniformLocation(shaderProgram, getUniformStructLocStr("lightSource", "ambient_color", i).c_str());
    lightLocation.diffuse_color = glGetUniformLocation(shaderProgram, getUniformStructLocStr("lightSource", "diffuse_color", i).c_str());
    lightLocation.specular_color = glGetUniformLocation(shaderProgram, getUniformStructLocStr("lightSource", "specular_color", i).c_str());
    lightLocation.position = glGetUniformLocation(shaderProgram, getUniformStructLocStr("lightSource", "position", i).c_str());
    
    std::stringstream sstr("");
    sstr << "light_" << i;
    uniformLocations_Lights[sstr.str()] = lightLocation;
  }
  uniformLocations["usedLightCount"] = glGetUniformLocation(shaderProgram, "usedLightCount");
  
  // TODO: get texture uniform location //
  
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
 /* int logMaxLength;
  glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logMaxLength);
  char log[logMaxLength];
  int logLength = 0;
  glGetShaderInfoLog(shader, logMaxLength, &logLength, log);
  if (logLength > 0) {
    std::cout << "(loadShaderFile) - Compiler log:\n------------------\n" << log << "\n------------------" << std::endl;
  }*/
  
  // return compiled shader (may have compiled WITH errors) //
  return shader;
}

void initTextures (void) {
    // generate a new OpenGL texture
    GLuint texName;
    glGenTextures(1, &texName);

    // initialize the texture properly (filtering, wrapping style, etc.)
    glBindTexture(GL_TEXTURE_2D, texName);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    // "../textures/trashbin.png" OR "../textures/ball.jpg"
    TextureData texture = loadTextureData("../textures/trashbin.png");

    // upload the imported image data to the OpenGL texture
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, texture.width, texture.height, 0, GL_RGB, GL_FLOAT, texture.data);

    // TODO: don't forget to clean up
    // clean up what??
}

// - return imported data as 'TextureData' container
// - hint: use opencv to import a image file
TextureData loadTextureData(const char *textureFile) {

    cv::Mat texture_cv;
    texture_cv = cv::imread(textureFile);

    TextureData texture;
    texture.width = texture_cv.cols;
    texture.height = texture_cv.rows;
    texture.data = texture_cv.data;
    return texture;
}

void initScene() {
  // load scene.obj from disk and create renderable MeshObj //
  // TODO: you may switch between the following mesh files //
  // - make sure to use the correct texture file for each mesh object //
  objLoader.loadObjFile("../meshes/trashbin.obj", "sceneObject");
  //objLoader.loadObjFile("../meshes/ball.obj", "sceneObject");
  
  // init materials //
  Material mat;
  mat.ambient_color = glm::vec3(1.0, 1.0, 1.0);
  mat.diffuse_color = glm::vec3(1.0, 1.0, 1.0);
  mat.specular_color = glm::vec3(1.0, 1.0, 1.0);
  mat.specular_shininess = 50.0;
  materials.push_back(mat);
  
  mat.specular_shininess = 100.0;
  materials.push_back(mat);
  
  mat.ambient_color = glm::vec3(1.0, 0.9, 0.8);
  mat.diffuse_color = glm::vec3(1.0, 0.9, 0.8);
  mat.specular_shininess = 50.0;
  materials.push_back(mat);
  
  // save material count for later and select first material //
  materialCount = materials.size();
  materialIndex = 0;
  
  // init lights //
  LightSource light;
  light.ambient_color = glm::vec3(0.001, 0.001, 0.001);
  light.diffuse_color = glm::vec3(1.0, 1.0, 1.0);
  light.specular_color = glm::vec3(1.0, 1.0, 1.0);
  
  light.position = glm::vec3(15, 15, 15);
  lights.push_back(light);
  
  light.position = glm::vec3(-15, 15, 15);
  lights.push_back(light);
  
  light.position = glm::vec3(15, 15, -15);
  lights.push_back(light);
  
  light.position = glm::vec3(-15, 15, -15);
  lights.push_back(light);
  
  // save light source count for later and select first light source //
  lightCount = lights.size();
}

void renderScene() {
  glm_ModelViewMatrix.push(glm_ModelViewMatrix.top());
  
  glUniformMatrix4fv(uniformLocations["modelview"], 1, false, glm::value_ptr(glm_ModelViewMatrix.top()));
  
  // upload the properties of the currently active light sources here //
  int shaderLightIdx = 0;
  for (unsigned int i = 0; i < lightCount; ++i) {
    if (lights[i].enabled) {
      std::stringstream sstr("");
      sstr << "light_" << shaderLightIdx;
      UniformLocation_Light &light = uniformLocations_Lights[sstr.str()];
      glUniform3fv(light.position, 1, glm::value_ptr(lights[i].position));
      glUniform3fv(light.ambient_color, 1, glm::value_ptr(lights[i].ambient_color));
      glUniform3fv(light.diffuse_color, 1, glm::value_ptr(lights[i].diffuse_color));
      glUniform3fv(light.specular_color, 1, glm::value_ptr(lights[i].specular_color));
      ++shaderLightIdx;
    }
  }
  glUniform1i(uniformLocations["usedLightCount"], shaderLightIdx);
  
  // upload the chosen material properties here //
  glUniform3fv(uniformLocations["material.ambient"], 1, glm::value_ptr(materials[materialIndex].ambient_color));
  glUniform3fv(uniformLocations["material.diffuse"], 1, glm::value_ptr(materials[materialIndex].diffuse_color));
  glUniform3fv(uniformLocations["material.specular"], 1, glm::value_ptr(materials[materialIndex].specular_color));
  glUniform1f(uniformLocations["material.shininess"], materials[materialIndex].specular_shininess);
  
  // TODO: upload texture to first texture unit //
  // - bind the texture after activating the first texture unit
  // - assign the currently active texture unit to the texture uniform of your shader
  
  // render the actual object //
  objLoader.getMeshObj("sceneObject")->render();
  
  // restore scene graph to previous state //
  glm_ModelViewMatrix.pop();
}

void updateGL() {
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
  
  // render scene //
  renderScene();
  
  // swap renderbuffers for smooth rendering //
  glutSwapBuffers();
}

void idle() {
  glutPostRedisplay();
}

// toggles a light source on or off //
void toggleLightSource(unsigned int i) {
  if (i < lightCount) {
    lights[i].enabled = !lights[i].enabled;
  }
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
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9': {
      int lightIdx;
      std::stringstream keyStr;
      keyStr << key;
      keyStr >> lightIdx;
      if (lightIdx == 0) lightIdx = 10;
      if (lightIdx > 0) toggleLightSource(lightIdx - 1);
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


#include "Ex05.h"

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

// window controls //
void updateGL();
void idle();
void keyboardEvent(unsigned char key, int x, int y);
void mouseEvent(int button, int state, int x, int y);
void mouseMoveEvent(int x, int y);

// camera controls //
CameraController camera(0, M_PI/6, 10);

// viewport //
GLint windowWidth, windowHeight;

// geometry //
void initScene();
void renderScene();

// OBJ import //
ObjLoader objLoader;

// these structs are also used in the shader code  //
// this helps to access the parameters more easily //
struct Material {
  glm::vec3 ambient_color;
  glm::vec3 diffuse_color;
  glm::vec3 specular_color;
  float specular_shininess;
};

struct LightSource {
  glm::vec3 ambient_color;
  glm::vec3 diffuse_color;
  glm::vec3 specular_color;
  glm::vec3 position;
};

// the program uses a list of materials and light sources, which can be chosen during rendering //
unsigned int materialIndex;
unsigned int materialCount;
std::vector<Material> materials;
unsigned int lightIndex;
unsigned int lightCount;
std::vector<LightSource> lights;

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
  glutCreateWindow("Exercise 05 - Per Fragment Lighting with GLSL");
  
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

void initShader() {
  shaderProgram = glCreateProgram();
  // check if operation failed //
  if (shaderProgram == 0) {
    std::cout << "(initShader) - Failed creating shader program." << std::endl;
    return;
  }
  
  GLuint vertexShader = loadShaderFile("../shader/material_and_light.vert", GL_VERTEX_SHADER);
  if (vertexShader == 0) {
    std::cout << "(initShader) - Could not create vertex shader." << std::endl;
    deleteShader();
    return;
  }
  GLuint fragmentShader = loadShaderFile("../shader/material_and_light.frag", GL_FRAGMENT_SHADER);
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
  // TODO: insert the uniform locations for all light and material properties
  // - insert then into the provided map 'uniformLocations' and give them a proper identifier
  // - when accessing a GLSL uniform within a struct (as used in the provided vertex shader),
  //   use the following technique: glGetUniformLocation(shaderID, "structName.propertyName")
  //   So, when having a struct 
  //	 struct MyStruct {vec3 MyVector};
  //   and a uniform declaration
  //     uniform MyStruct MyStructUniform;
  //   you can get the location of MyVector by passing the string "MyStructUniform.MyVector" to
  //   glGetUniformLocation(...)
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

void initScene() {
  // load scene.obj from disk and create renderable MeshObj //
  objLoader.loadObjFile("../meshes/bunny.obj", "bunny");
  
  // init materials //
  // TODO: initialize your materials here //
  // - create a new Material and insert it into the 'materials' vector
  // - set material properties for ambient, diffuse and specular color as glm::vec3
  // - set shininess exponent as float
  
  // save material count for later and select first material //
  materialCount = materials.size();
  materialIndex = 0;
  
  // init lights //
  // TODO: initialize your light sources here //
  // - set the color properties of the light source as glm::vec3
  // - set the lights position as glm::vec3
  
  // save light source count for later and select first light source //
  lightCount = lights.size();
  lightIndex = 0;
}

void renderScene() {
  glm_ModelViewMatrix.push(glm_ModelViewMatrix.top());
  glm_ModelViewMatrix.top() *= glm::scale(glm::vec3(20.0));
  
  glUniformMatrix4fv(uniformLocations["modelview"], 1, false, glm::value_ptr(glm_ModelViewMatrix.top()));
  
  // TODO: upload the properties of the currently chosen light source here //
  // - ambient, diffuse and specular color
  // - position
  // - use glm::value_ptr() to get a proper reference when uploading the values as a data vector //
  
  // TODO: upload the chosen material properties here //
  // - upload ambient, diffuse and specular color as 3d-vector
  // - upload shininess exponent as simple float value
  
  // render the actual object //
  objLoader.getMeshObj("bunny")->render();
  
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
    case 'l': {
      lightIndex++;
      if (lightIndex >= lightCount) lightIndex = 0;
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


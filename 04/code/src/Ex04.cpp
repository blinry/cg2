#include "Ex04.h"

// OpenGL and GLSL stuff //
void initGL();
void initShader();
bool enableShader();
void disableShader();
void deleteShader();
char* loadShaderSource(const char* fileName);
GLuint loadShaderFile(const char* fileName, GLenum shaderType);
GLuint shaderProgram = 0;
GLint uniform_projectionMatrix;
GLint uniform_modelViewMatrix;

// window controls //
void updateGL();
void idle();
void keyboardEvent(unsigned char key, int x, int y);
void mouseEvent(int button, int state, int x, int y);
void mouseMoveEvent(int x, int y);

// camera controls //
CameraController cameraView(0, M_PI/6, 10);
CameraController sceneView(M_PI/4, M_PI/6, 35);

// viewport //
GLint windowWidth, windowHeight;

// geometry //
void initScene();
void deleteScene();
void renderScene();
// cube representing camera frustum //
GLuint cubeVAO = 0;
GLuint cubeVBO = 0;
GLuint cubeIBO = 0;

// OBJ import //
ObjLoader objLoader;

int main (int argc, char **argv) {
  glutInit(&argc, argv);
  glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
  glutInitContextVersion(3,3);
  glutInitContextFlags(GLUT_FORWARD_COMPATIBLE);
  glutInitContextProfile(GLUT_CORE_PROFILE);

  windowWidth = 1024;
  windowHeight = 512;
  glutInitWindowSize(windowWidth, windowHeight);
  glutInitWindowPosition(100, 100);
  glutCreateWindow("Exercise 04 - Camera and Viewports");
  
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
  
  // init matrix stacks //
  glm_ProjectionMatrix.push(glm::mat4(1));
  glm_ModelViewMatrix.push(glm::mat4(1));
  
  // init cameras //
  sceneView.setFar(100);
  
  initShader();
  initScene();
  
  // start render loop //
  if (enableShader()) {
    glutMainLoop();
    disableShader();
    
    // clean up allocated data //
    deleteScene();
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
  
  GLuint vertexShader = loadShaderFile("../shader/simple.vert", GL_VERTEX_SHADER);
  if (vertexShader == 0) {
    std::cout << "(initShader) - Could not create vertex shader." << std::endl;
    deleteShader();
    return;
  }
  GLuint fragmentShader = loadShaderFile("../shader/simple.frag", GL_FRAGMENT_SHADER);
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
  int logMaxLength;
  glGetProgramiv(shaderProgram, GL_INFO_LOG_LENGTH, &logMaxLength);
  char log[logMaxLength];
  int logLength = 0;
  glGetShaderInfoLog(shaderProgram, logMaxLength, &logLength, log);
  if (logLength > 0) {
    std::cout << "(initShader) - Linker log:\n------------------\n" << log << "\n------------------" << std::endl;
  }
  
  // set address of fragment color output //
  glBindFragDataLocation(shaderProgram, 0, "color");
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

void initScene() {
  // load scene.obj from disk and create renderable MeshObj //
  objLoader.loadObjFile("../meshes/scene.obj", "scene");
  objLoader.loadObjFile("../meshes/camera.obj", "camera");
  
  // init frustum cube //
  GLfloat frustrumVertices[24] = {-1,-1,-1,
				   1,-1,-1,
				   1, 1,-1,
				  -1, 1,-1,
				  -1,-1, 1,
				   1,-1, 1,
				   1, 1, 1,
				  -1, 1, 1};
  GLuint frustumIndices[24] = {0, 1,
			       1, 2,
			       2, 3,
			       3, 0,
			       4, 5,
			       5, 6,
			       6, 7,
			       7, 4,
			       0, 4,
			       1, 5,
			       2, 6,
			       3, 7};
			       
  if (cubeVAO == 0) {
    glGenVertexArrays(1, &cubeVAO);
  }
  glBindVertexArray(cubeVAO);
  
  // create and bind VBOs and upload data (one VBO per vertex attribute -> position, normal) //
  if (cubeVBO == 0) {
    glGenBuffers(1, &cubeVBO);
  }
  glBindBuffer(GL_ARRAY_BUFFER, cubeVBO);
  glBufferData(GL_ARRAY_BUFFER, 24 * sizeof(GLfloat), &frustrumVertices[0], GL_STATIC_DRAW);
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (void*)0);
  glEnableVertexAttribArray(0);
    
  // init and bind a IBO //
  if (cubeIBO == 0) {
    glGenBuffers(1, &cubeIBO);
  }
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, cubeIBO);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, 24 * sizeof(GLuint), &frustumIndices[0], GL_STATIC_DRAW);
  
  // unbind buffers //
  glBindVertexArray(0);

}

void deleteScene() {
  glDeleteVertexArrays(1, &cubeVAO);
  glDeleteBuffers(1, &cubeVBO);
  glDeleteBuffers(1, &cubeIBO);
}

void renderScene() {
  glm_ModelViewMatrix.push(glm_ModelViewMatrix.top());
  // upload modelview matrix to shader //
  glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "modelview"), 1, false, glm::value_ptr(glm_ModelViewMatrix.top()));
  
  // render 'scene.obj' //
  objLoader.getMeshObj("scene")->render();
  
  // restore scene graph to previous state //
  glm_ModelViewMatrix.pop();
}

/** \brief This method returns the inverse of a matrix, that is not affine (like OpenGLs projection matrix).
 * \param mat Reference to the matrix to be inverted.
 * \return Inverse of provided matrix.
 */
glm::mat4 invertProjectionMat(const glm::mat4 &mat) {
  glm::mat4 inv(0);
  inv[0][0] = 1 / mat[0][0];
  inv[1][1] = 1 / mat[1][1];
  inv[2][2] = mat[3][3];
  inv[2][3] = 1 / mat[3][2];
  inv[3][2] = mat[2][3];
  inv[3][3] = mat[2][2] / mat[3][2];
  return inv;
}

void updateGL() {
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  // render left viewport -> camera view //
  // set viewport to left half of the window //
  glViewport(0,0,512,512);
  
  // disable custom color in shader //
  glUniform1i(glGetUniformLocation(shaderProgram, "use_override_color"), 0);
  
  // get projection mat from camera controller (cameraView) and set it as top value of glm_ProjectionMatrix //
  glm_ProjectionMatrix.top() = cameraView.getProjectionMat();
  
  // upload projection matrix to shader //
  glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "projection"), 1, false, glm::value_ptr(glm_ProjectionMatrix.top()));
  
  // get modelview mat from camera controller and set it as top value of glm_ModelViewMatrix //
  glm_ModelViewMatrix.top() = cameraView.getModelViewMat();
  
  // render scene //
  renderScene();
  
  // render right viewport -> scene view //
  // set viewport to right half of the window //
  glViewport(512,0,512,512);
  
  // projection matrix stays the same //
  // get projection mat from camera controller (this time it's 'sceneView') //
  glm_ProjectionMatrix.top() = sceneView.getProjectionMat();
  
  // upload projection matrix to shader //
  glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "projection"), 1, false, glm::value_ptr(glm_ProjectionMatrix.top()));
  
  // get modelview mat from camera controller //
  glm_ModelViewMatrix.top() = sceneView.getModelViewMat();
  
  // render original scene //
  renderScene();
  
  // compute matrix inverse 'cameraView's matrices           //
  //       you need to invert both modelview and projection matrix //
  //       note: glm can only invert affine matrices               //
  glm::mat4 inversedModelViewMat = glm::inverse(cameraView.getModelViewMat());
  glm::mat4 inversedProjectionMat = invertProjectionMat(cameraView.getProjectionMat());
  
  // render 'camera.obj' at the 'cameraView' camera position //
  glm_ModelViewMatrix.push(glm_ModelViewMatrix.top());
  // FIXME: transform the camera origin the the camera position of 'cameraView' //
  glm_ModelViewMatrix.top() *= inversedModelViewMat;
  glm_ModelViewMatrix.top() *= inversedProjectionMat;
  
  // upload modelview matrix configuration to shader just before rendering //
  glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "modelview"), 1, false, glm::value_ptr(glm_ModelViewMatrix.top()));
  // use custom color for camera object //
  glUniform1i(glGetUniformLocation(shaderProgram, "use_override_color"), 1);
  glUniform3f(glGetUniformLocation(shaderProgram, "override_color"), 1, 0, 1);
  // render the camera object //
  objLoader.getMeshObj("camera")->render();
  
  // restore modelview matrix //
  glm_ModelViewMatrix.pop();
  
  // render camera frustum of 'cameraView' //
  glm_ModelViewMatrix.push(glm_ModelViewMatrix.top());
  // FIXME: transform position and shape of the unit-cube in normalized device space to world coordinates //
  glm_ModelViewMatrix.top() *= cameraView.getProjectionMat();
  
  // upload modelview matrix configuration to shader just before rendering //
  glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "modelview"), 1, false, glm::value_ptr(glm_ModelViewMatrix.top()));
  // use custom color for camera object //
  glUniform1i(glGetUniformLocation(shaderProgram, "use_override_color"), 1);
  glUniform3f(glGetUniformLocation(shaderProgram, "override_color"), 1, 0, 0);
  // render the frustum unit-cube 'cubeVAO' consisting of 12 edges (draw mode: GL_LINES) //
  glBindVertexArray(cubeVAO);
  glDrawElements(GL_LINES, 12, GL_UNSIGNED_INT, 0);
  
  // restore modelview matrix //
  glm_ModelViewMatrix.pop();
  
  // swap renderbuffers for smooth rendering //
  glutSwapBuffers();
}

void idle() {
  glutPostRedisplay();
}

void keyboardEvent(unsigned char key, int x, int y) {
  CameraController *camera = &cameraView;
  if (x >= (windowWidth / 2)) {
    camera = &sceneView;
  }
  switch (key) {
    case 'x':
    case 27 : {
      exit(0);
      break;
    }
    case 'w': {
      // move forward //
      camera->move(CameraController::MOVE_FORWARD);
      break;
    }
    case 's': {
      // move backward //
      camera->move(CameraController::MOVE_BACKWARD);
      break;
    }
    case 'a': {
      // move left //
      camera->move(CameraController::MOVE_LEFT);
      break;
    }
    case 'd': {
      // move right //
      camera->move(CameraController::MOVE_RIGHT);
      break;
    }
    case 'z': {
      camera->setOpeningAngle(camera->getOpeningAngle() + 0.1f);
      break;
    }
    case 'h': {
      camera->setOpeningAngle(std::min(std::max(camera->getOpeningAngle() - 0.1f, 1.0f), 180.0f));
      break;
    }
    case 'r': {
      camera->setNear(std::min(camera->getNear() + 0.1f, camera->getFar() - 0.01f));
      break;
    }
    case 'f': {
      camera->setNear(std::max(camera->getNear() - 0.1f, 0.1f));
      break;
    }
    case 't': {
      camera->setFar(camera->getFar() + 0.1f);
      break;
    }
    case 'g': {
      camera->setFar(std::max(camera->getFar() - 0.1f, camera->getNear() + 0.01f));
      break;
    }
  }
  glutPostRedisplay();
}

void mouseEvent(int button, int state, int x, int y) {
  CameraController *camera = &cameraView;
  if (x >= (windowWidth / 2)) {
    camera = &sceneView;
  }
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
  camera->updateMouseBtn(mouseState, x, y);
  glutPostRedisplay();
}

void mouseMoveEvent(int x, int y) {
  CameraController *camera = &cameraView;
  if (x >= (windowWidth / 2)) {
    camera = &sceneView;
  }
  camera->updateMousePos(x, y);
  glutPostRedisplay();
}


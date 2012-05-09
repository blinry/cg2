#include "Ex03.h"

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

// geometry //
GLuint bunnyVAO = 0;
GLuint bunnyVBOs[2] = {0, 0};
GLuint bunnyIBO = 0;
void initScene();
void deleteScene();
void renderScene();

int main (int argc, char **argv) {
  glutInit(&argc, argv);
  glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
  glutInitContextVersion(3,3);
  glutInitContextFlags(GLUT_FORWARD_COMPATIBLE);
  glutInitContextProfile(GLUT_CORE_PROFILE);

  glutInitWindowSize (512, 512);
  glutInitWindowPosition (100, 100);
  glutCreateWindow("Exercise 03 - More Bunnies!");
  
  glutDisplayFunc(updateGL);
  glutIdleFunc(idle);
  glutKeyboardFunc(keyboardEvent);
  
  glewExperimental = GL_TRUE;
  GLenum err = glewInit();
  if (GLEW_OK != err) {
    std::cout << "(glewInit) - Error: " << glewGetErrorString(err) << std::endl;
  }
  std::cout << "(glewInit) - Using GLEW " << glewGetString(GLEW_VERSION) << std::endl;
  
  // init stuff //
  initGL();
  
  // init matrix stacks //
  glm_ProjectionMatrix.push(glm::mat4(2.414214, 0.000000, 0.000000, 0.000000, 0.000000, 2.414214, 0.000000, 0.000000, 0.000000, 0.000000, -1.002002, -1.000000, 0.000000, 0.000000, -0.020020, 0.000000));
  glm_ModelViewMatrix.push(glm::mat4(0.707107, -0.408248, 0.577350, 0.000000, 0.000000, 0.816497, 0.577350, 0.000000, -0.707107, -0.408248, 0.577350, 0.000000, 0.000000, 0.000000, -1.732051, 1.000000));
  
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
    file.seekg(0, std::ios::end);
    srcLength = file.tellg();
    file.seekg(0, std::ios::beg);
    
    shaderSource = new char[srcLength + 1];
    shaderSource[srcLength] = 0;
    file.read(shaderSource, srcLength);
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

  // return compiled shader (may have compiled WITH errors) //
  return shader;
}

ObjLoader objLoader;

void initScene() {
  // load scene.obj from disk and create renderable MeshObj //
  objLoader.loadObjFile("../meshes/scene.obj", "scene");
  
  // import data from bunny.h and create VAO //
  if (bunnyVAO == 0) {
    glGenVertexArrays(1, &bunnyVAO);
  }
  glBindVertexArray(bunnyVAO);
  
  glGenBuffers(2, bunnyVBOs);
  
  glBindBuffer(GL_ARRAY_BUFFER, bunnyVBOs[0]);
  glBufferData(GL_ARRAY_BUFFER, 3 * NUM_POINTS * sizeof(GLfloat), &bunny[0], GL_STATIC_DRAW);
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
  glEnableVertexAttribArray(0);
  
  glBindBuffer(GL_ARRAY_BUFFER, bunnyVBOs[1]);
  glBufferData(GL_ARRAY_BUFFER, 3 * NUM_POINTS * sizeof(GLfloat), &normals[0], GL_STATIC_DRAW);
  glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, 0);
  glEnableVertexAttribArray(1);
  
  // init and bind a IBO (index buffer object) //
  if (bunnyIBO == 0) {
    glGenBuffers(1, &bunnyIBO);
  }
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, bunnyIBO);
  // copy data into the IBO //
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, 3 * NUM_TRIANGLES * sizeof(GLint), triangles, GL_STATIC_DRAW);
  
  // unbind buffers //
  glBindVertexArray(0);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
}

void deleteScene() {
  glDeleteBuffers(1, &bunnyIBO);
  glDeleteBuffers(2, bunnyVBOs);
  glDeleteVertexArrays(1, &bunnyVAO);
}

void renderScene() {
  if (bunnyVAO != 0) {
    // init vertex attribute arrays //
    glBindVertexArray(bunnyVAO);
    
    // render VAO as triangles //
    glDrawElements(GL_TRIANGLES, 3 * NUM_TRIANGLES, GL_UNSIGNED_INT, (void*)0);
    
    // unbind buffers //
    glBindVertexArray(0);
  } else {
    initScene();
  }
}

GLfloat rotAngle = 0;
void updateGL() {
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  // projection matrix stays the same //
  glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "projection"), 1, false, glm::value_ptr(glm_ProjectionMatrix.top()));
  
  // init scene graph by cloning the top entry, which can now be manipulated //
  glm_ModelViewMatrix.push(glm_ModelViewMatrix.top());
  
  // TODO: create a rotating grid of rotating objects (5 x 5 grid)
  //  - alterately render a bunny and the loaded obj-File in this grid
  //    e.g.: B S B S B   (B: bunny.h, S: scene.obj)
  //          S B S B S
  //          B S B S B
  //          S B S B S
  //          B S B S B
  //  - rotate the grid clockwise about 'rotAngle'
  //  - rotate the bunnies counterclockwise about 'rotAngle'
  //  - use glm_ModelViewMatrix.push(...) and glm_ModelViewMatrix.pop()   
  //  - apply new transformations by using: glm_ModelViewMatrix.top() *= glm::some_transformation(...);
  //  - right before rendering an object, upload the current state of the modelView matrix stack:
  //    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "modelview"), 1, false, glm::value_ptr(glm_ModelViewMatrix.top()));
  
  // Variable sorgt für abwechselndes Zeichnen des Hasen und der Ringe
  bool bunny = true;

  // Wir wollen das gesamte Grid im Uhrzeigersinn um die z-Achse drehen. Diese
  // Transformation wird als "letztes" ausgeführt.
  glm_ModelViewMatrix.top() *= glm::rotate(-rotAngle, 0.f, 1.0f, 0.f);

  // Bestimmt den Abstand zwischen den Objekten
  float factor = 0.25f;

  // Zwei Schleifen, die ein 5x5-Grid erzeugen
  for(float x=-2.0f; x<3.0f; x+=1.0f) {
      for(float z=-2.0f; z<3.0f; z+=1.0f) {

          // Ab jetzt bekommt jedes Objekt eine eikene Matrix
          glm_ModelViewMatrix.push(glm_ModelViewMatrix.top());

          // Verschieben gemäß Position im Grid
          glm_ModelViewMatrix.top() *= glm::translate(factor*x, 0.0f, factor * z);

          if (bunny) {
              // Die Bunnys sollen sich GEGEN den Uhrzeigersinn um die y-Achse drehen
              glm_ModelViewMatrix.top() *= glm::rotate(rotAngle, 0.f, 1.0f, 0.f);
              // Die aktuell oberste Matrix möchten wir zur Transformation nutzen
              glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "modelview"), 1, false, glm::value_ptr(glm_ModelViewMatrix.top()));
              // Bunny zeichnen
              renderScene();
          } else {
              // Soll das andere Objekt gezeichnet werden, skaliere um Faktor 20 runter ...
              glm_ModelViewMatrix.top() *= glm::scale(1.0f/20.0f,1.0f/20.0f,1.0f/20.0f);
              glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "modelview"), 1, false, glm::value_ptr(glm_ModelViewMatrix.top()));
              // ... und zeichne das "scene"-Objekt
              objLoader.getMeshObj("scene")->render();
          }

          // Hase und Ringe wechseln sich ab
          bunny = !bunny;

          // Geh wieder einen Schritt im Szenegraph nach oben
          glm_ModelViewMatrix.pop();
      }
  }

  // restore scene graph to previous state //
  glm_ModelViewMatrix.pop();
  
  // increment rotation angle //
  rotAngle += 1.0f;
  if (rotAngle > 360.0f) rotAngle -= 360.0f;
  
  // swap renderbuffers for smooth rendering //
  
  glutSwapBuffers();
}

void idle() {
  glutPostRedisplay();
}

void keyboardEvent(unsigned char key, int x, int y) {
  if (key == 'x' || key == 27) {
    exit(0);
  }
  glutPostRedisplay();
}

#include "Ex02.h"

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
GLuint bunnyVAO;
GLuint bunnyVBO;
GLuint bunnyIBO;
void initScene();
void deleteScene();
void renderScene();

// view matrices //
glm::mat4 projectionMatrix = glm::mat4(2.414214, 0.000000, 0.000000, 0.000000, 0.000000, 2.414214, 0.000000, 0.000000, 0.000000, 0.000000, -1.002002, -1.000000, 0.000000, 0.000000, -0.020020, 0.000000);
glm::mat4 modelViewMatrix = glm::mat4(0.707107, -0.408248, 0.577350, 0.000000, 0.000000, 0.816497, 0.577350, 0.000000, -0.707107, -0.408248, 0.577350, 0.000000, 0.025249, -0.085015, -0.391099, 1.000000);


int main (int argc, char **argv) {
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
	glutInitContextVersion(3,3);
	glutInitContextFlags(GLUT_FORWARD_COMPATIBLE);
	glutInitContextProfile(GLUT_CORE_PROFILE);

	glutInitWindowSize (512, 512);
	glutInitWindowPosition (100, 100);
	glutCreateWindow("Exercise 02 - More Bunnies!");

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
	// TODO:
	//  load the vertex and fragment shader from source files attach them to a shader program
	//  - load the file "shader/simple.vert" as GL_VERTEX_SHADER
	//  - load the file "shader/simple.frag" as GL_FRAGMENT_SHADER
	//  - create a shader program "shaderProgram" (global member)
	//  - attach both shaders to this shader program
	//  - link the shader program



	// TODO: create new shader program "shaderProgram" //
	GLuint shaderProgram = glCreateProgram();		

	// check if operation failed //
	if (shaderProgram == 0) {
		std::cout << "(initShader) - Failed creating shader program." << std::endl;
		return;
	}

	// TODO: load vertex shader source //
	GLuint vertexShader = loadShaderFile("shader/simple.vert", GL_VERTEX_SHADER);

	// TODO: load fragment shader source //
	GLuint fragmentShader = loadShaderFile("shader/simple.frag", GL_FRAGMENT_SHADER);

	// successfully loaded and compiled shaders -> attach them to program //
	// TODO: attach shaders to "shaderProgram" //
	glAttachShader(shaderProgram, vertexShader);
	glAttachShader(shaderProgram, fragmentShader);

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

	// TODO:
	//  import source code from a given file
	//  - open file
	//  - read in file into char array
	//  - close file and return array

	FILE* shaderFile;	
	shaderFile = fopen(fileName, "r");

	if(shaderFile == NULL)
	{
		printf("Couldn't open file %s", fileName);
	}	
	
	size_t char_count = 0;
	int ch;
	while(1)
	{
		ch = fgetc(shaderFile);
		if(ch == EOF)
			break;
		++char_count;
	}
	char_count++;
	fseek(shaderFile, 0, SEEK_SET);
	shaderSource = (char*) malloc(char_count * sizeof(char));
	size_t readcnt = 0;
	while(1)
	{
		ch = fgetc(shaderFile);
		if(ch == EOF)
			break;
		shaderSource[readcnt] = ch;
		readcnt++;	
	}	
	shaderSource[readcnt] = 0;
	readcnt++;
	if(readcnt != char_count)
	{
		printf("This shouldn't be happening, less characters read than counted before");
	}
	fclose(shaderFile);

	return shaderSource;
}

// loads a source file and directly compiles it to a shader of 'shaderType' //
GLuint loadShaderFile(const char* fileName, GLenum shaderType) {
	// TODO:
	//  create a shader program using code from a given file
	//  - create new shader of appropriate shader type (defined by 'shaderType')
	//  - load shader source from file
	//  - load shader source into shader and compile
	//  - (check for compilation errors (shader info log) )
	//  - return compiled shader

	GLuint shader = 0;
	// TODO: create new shader of type "shaderType" //
	shader = glCreateShader(shaderType);

	// check if operation failed //
	if (shader == 0) {
		std::cout << "(loadShaderFile) - Could not create shader." << std::endl;
		return 0;
	}

	// TODO: load source code from file //
	char* source = loadShaderSource(fileName);	

	// TODO: pass source code to new shader object //
	int length[1] = {-1};
	glShaderSource(shader, 1, (const GLchar**)&source, length);

	// TODO: compile shader //
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
	// TODO: import data from bunny.h and concatenate vertex and normal data //

	// TODO: init and bind a VAO (vertex array object) //

	// TODO: init and bind a VBO (vertex buffer object) //

	// TODO: copy data into the VBO //

	// TODO: init and bind a IBO (index buffer object) //

	// TODO: copy data into the IBO //

	// unbind active buffers //
	glBindVertexArray(0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

void deleteScene() {
	if (bunnyIBO != 0) glDeleteBuffers(1, &bunnyIBO);
	if (bunnyVBO != 0) glDeleteBuffers(1, &bunnyVBO);
	if (bunnyVAO != 0) glDeleteVertexArrays(1, &bunnyVAO);
}

void renderScene() {
	if (bunnyVAO != 0) {
		// TODO: bind VAO //

		// TODO: render data as triangles //

		// unbind active buffers //
		glBindVertexArray(0);
	}
}

GLfloat rotAngle = 0;
void updateGL() {
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "projection"), 1, false, glm::value_ptr(projectionMatrix));
	glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "modelview"), 1, false, glm::value_ptr(modelViewMatrix));

	// now the scene will be rendered //
	renderScene();

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

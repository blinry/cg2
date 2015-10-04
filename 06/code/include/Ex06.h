#ifndef __EX03__
#define __EX03__
#define _USE_MATH_DEFINES

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

std::stack<glm::mat4> glm_ProjectionMatrix;
std::stack<glm::mat4> glm_ModelViewMatrix;

#endif

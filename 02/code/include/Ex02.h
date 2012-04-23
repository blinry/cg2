#ifndef __EX02__
#define __EX02__

#include <GL/glew.h>
#include <GL/glut.h>
#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtx/rotate_vector.hpp>
#include <glm/gtx/string_cast.hpp> 

#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <fstream>

// include bunny geometry //
#include "bunny.h"

struct Vertex {
  GLfloat pos[3];
  GLfloat normal[3];
};

#endif

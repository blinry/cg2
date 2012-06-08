SET(Exercise06_SRC
  Ex06.cpp
  MeshObj.cpp
  ObjLoader.cpp
  CameraController.cpp
)
ADD_EXECUTABLE(ex06 ${Exercise06_SRC})
TARGET_LINK_LIBRARIES(ex06 ${OpenGL_LIBRARIES} ${GLUT_LIBRARIES} ${GLEW_LIBRARIES})

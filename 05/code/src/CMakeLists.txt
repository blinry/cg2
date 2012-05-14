SET(Exercise05_SRC
  Ex05.cpp
  MeshObj.cpp
  ObjLoader.cpp
  CameraController.cpp
)
ADD_EXECUTABLE(ex05 ${Exercise05_SRC})
TARGET_LINK_LIBRARIES(ex05 ${OpenGL_LIBRARIES} ${GLUT_LIBRARIES} ${GLEW_LIBRARIES})
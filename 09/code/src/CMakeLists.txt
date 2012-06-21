SET(Exercise09_SRC
  Ex09.cpp
  MeshObj.cpp
  ObjLoader.cpp
  CameraController.cpp
)

ADD_EXECUTABLE(ex09 ${Exercise09_SRC})
TARGET_LINK_LIBRARIES(ex09 cv highgui ${OpenGL_LIBRARIES} ${GLUT_LIBRARIES} ${GLEW_LIBRARIES})
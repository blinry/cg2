SET(Exercise08_SRC
  Ex08.cpp
  MeshObj.cpp
  ObjLoader.cpp
  CameraController.cpp
)

ADD_EXECUTABLE(ex08 ${Exercise08_SRC})
TARGET_LINK_LIBRARIES(ex08 cv highgui ${OpenGL_LIBRARIES} ${GLUT_LIBRARIES} ${GLEW_LIBRARIES})
SET(Exercise11_SRC
  Ex11.cpp
  MeshObj.cpp
  ObjLoader.cpp
  CameraController.cpp
  Timer.cpp
  Path.cpp
)

ADD_EXECUTABLE(ex11 ${Exercise11_SRC})
TARGET_LINK_LIBRARIES(ex11 cv highgui ${OpenGL_LIBRARIES} ${GLUT_LIBRARIES} ${GLEW_LIBRARIES})
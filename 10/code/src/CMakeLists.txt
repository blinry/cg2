SET(Exercise10_SRC
  Ex10.cpp
  MeshObj.cpp
  ObjLoader.cpp
  CameraController.cpp
)

ADD_EXECUTABLE(ex10 ${Exercise10_SRC})
TARGET_LINK_LIBRARIES(ex10 cv highgui ${OpenGL_LIBRARIES} ${GLUT_LIBRARIES} ${GLEW_LIBRARIES})
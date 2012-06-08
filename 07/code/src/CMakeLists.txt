SET(Exercise07_SRC
  Ex07.cpp
  MeshObj.cpp
  ObjLoader.cpp
  CameraController.cpp
)

ADD_EXECUTABLE(ex07 ${Exercise07_SRC})
TARGET_LINK_LIBRARIES(ex07 ${OpenGL_LIBRARIES} ${GLUT_LIBRARIES} ${GLEW_LIBRARIES} ${OpenCV_LIBS})

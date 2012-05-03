#include "MeshObj.h"
#include <iostream>
#include <limits>

MeshObj::MeshObj() {
  mVAO = 0;
  mVBO_position = 0;
  mVBO_normal = 0;
  mIBO = 0;
  mIndexCount = 0;
}

MeshObj::~MeshObj() {
  glDeleteBuffers(1, &mIBO);
  glDeleteBuffers(1, &mVBO_position);
  glDeleteBuffers(1, &mVBO_normal);
  glDeleteVertexArrays(1, &mVAO);
}

void MeshObj::setData(const MeshData &meshData) {
  mIndexCount = meshData.indices.size();
  
  // TODO: create local storage arrays for vertices, normals and indices //
 // meshData.vertex_normal.
  // TODO: copy data into local arrays //
  
  // TODO: create VAO //
  
  // TODO: create and bind VBOs and upload data (one VBO per vertex attribute -> position, normal) //
  
  // TODO: init and bind a IBO //
  // unbind buffers //
  glBindVertexArray(0);
  
  // TODO: make sure to clean up temporarily allocated data, if neccessary //
}

void MeshObj::render(void) {
  if (mVAO != 0) {
    // TODO: render your VAO //
  /*  
   glBindVertexArray(mVAO);
   glDrawElements(GL_TRIANGLES, mIndexCount ,GL_UNSIGNED_INT, 0);*/


    glBindVertexArray(0);
  }
}

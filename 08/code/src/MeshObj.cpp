#include "MeshObj.h"
#include <iostream>
#include <limits>

MeshObj::MeshObj() {
  mVAO = 0;
  mVBO_position = 0;
  mVBO_normal = 0;
  mVBO_texcoord = 0;
  // #INFO# VBO locations for tangent and binormal already declared //
  mVBO_tangent = 0;
  mVBO_binormal = 0;
  mIBO = 0;
  mIndexCount = 0;
}

MeshObj::~MeshObj() {
  glDeleteBuffers(1, &mIBO);
  glDeleteBuffers(1, &mVBO_position);
  glDeleteBuffers(1, &mVBO_normal);
  glDeleteBuffers(1, &mVBO_texcoord);
  // #INFO# VBO locations for tangent and binormal already declared //
  glDeleteBuffers(1, &mVBO_tangent);
  glDeleteBuffers(1, &mVBO_binormal);
  glDeleteVertexArrays(1, &mVAO);
}

void MeshObj::setData(const MeshData &meshData) {
  mIndexCount = meshData.indices.size();
  
  // TODO: extend this method to upload tangent and binormal as VBOs //
  // - tangents location like in the shader code
  // - binormals location like in the shader code
  
  // create local storage arrays for vertices, normals and indices //
  unsigned int vertexDataSize = meshData.vertex_position.size();
  unsigned int vertexNormalSize = meshData.vertex_normal.size();
  unsigned int vertexTexcoordSize = meshData.vertex_texcoord.size();
  
  GLfloat *vertex_position = new GLfloat[vertexDataSize]();
  std::copy(meshData.vertex_position.begin(), meshData.vertex_position.end(), vertex_position);
  GLfloat *vertex_normal = NULL;
  if (vertexNormalSize > 0) {
    vertex_normal = new GLfloat[vertexNormalSize]();
    std::copy(meshData.vertex_normal.begin(), meshData.vertex_normal.end(), vertex_normal);
  }
  GLfloat *vertex_texcoord = NULL;
  if (vertexTexcoordSize > 0) {
    vertex_texcoord = new GLfloat[vertexTexcoordSize]();
    std::copy(meshData.vertex_texcoord.begin(), meshData.vertex_texcoord.end(), vertex_texcoord);
  }
  GLuint *indices = new GLuint[mIndexCount]();
  std::copy(meshData.indices.begin(), meshData.indices.end(), indices);
  
  // create VAO //
  if (mVAO == 0) {
    glGenVertexArrays(1, &mVAO);
  }
  glBindVertexArray(mVAO);
  
  // create and bind VBOs and upload data (one VBO per available vertex attribute -> position, normal) //
  if (mVBO_position == 0) {
    glGenBuffers(1, &mVBO_position);
  }
  glBindBuffer(GL_ARRAY_BUFFER, mVBO_position);
  glBufferData(GL_ARRAY_BUFFER, vertexDataSize * sizeof(GLfloat), &vertex_position[0], GL_STATIC_DRAW);
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (void*)0);
  glEnableVertexAttribArray(0);
  
  if (vertexNormalSize > 0) {
    if (mVBO_normal == 0) {
      glGenBuffers(1, &mVBO_normal);
    }
    glBindBuffer(GL_ARRAY_BUFFER, mVBO_normal);
    glBufferData(GL_ARRAY_BUFFER, vertexNormalSize * sizeof(GLfloat), &vertex_normal[0], GL_STATIC_DRAW);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, (void*)0);
    glEnableVertexAttribArray(1);
  }
  
  if (vertexTexcoordSize > 0) {
    if (mVBO_texcoord == 0) {
      glGenBuffers(1, &mVBO_texcoord);
    }
    glBindBuffer(GL_ARRAY_BUFFER, mVBO_texcoord);
    glBufferData(GL_ARRAY_BUFFER, vertexTexcoordSize * sizeof(GLfloat), &vertex_texcoord[0], GL_STATIC_DRAW);
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 0, (void*)0);
    glEnableVertexAttribArray(2);
  }
    
  // init and bind a IBO //
  if (mIBO == 0) {
    glGenBuffers(1, &mIBO);
  }
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mIBO);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, mIndexCount * sizeof(GLuint), &indices[0], GL_STATIC_DRAW);
  
  // unbind buffers //
  glBindVertexArray(0);
  
  // make sure to clean up temporarily allocated data, if neccessary //
  delete[] vertex_position;
  if (vertexNormalSize > 0) {
    delete[] vertex_normal;
  }
  if (vertexTexcoordSize > 0) {
    delete[] vertex_texcoord;
  }
  delete[] indices;
}

void MeshObj::render(void) {
  // render your VAO //
  if (mVAO != 0) {
    glBindVertexArray(mVAO);
    glDrawElements(GL_TRIANGLES, mIndexCount, GL_UNSIGNED_INT, (void*)0);
    glBindVertexArray(0);
  }
}

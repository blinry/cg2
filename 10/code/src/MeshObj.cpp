#include "MeshObj.h"
#include <iostream>
#include <limits>

MeshObj::MeshObj() {
  mVAO = 0;
  mVBO_position = 0;
  mVBO_normal = 0;
  mVBO_texcoord = 0;
  mVBO_tangent = 0;
  mVBO_binormal = 0;
  mIBO = 0;
  mIndexCount = 0;
  // shadow VBO //
  mVAO_shadow = 0;
  mVBO_shadow_position = 0;
  mIBO_shadow = 0;
  mIndexCount_shadow = 0;
}

MeshObj::~MeshObj() {
  if (mIBO) glDeleteBuffers(1, &mIBO);
  if (mVBO_position) glDeleteBuffers(1, &mVBO_position);
  if (mVBO_normal) glDeleteBuffers(1, &mVBO_normal);
  if (mVBO_texcoord) glDeleteBuffers(1, &mVBO_texcoord);
  if (mVBO_tangent) glDeleteBuffers(1, &mVBO_tangent);
  if (mVBO_binormal) glDeleteBuffers(1, &mVBO_binormal);
  if (mVAO) glDeleteVertexArrays(1, &mVAO);
  // clean up shadow volume //
  if (mIBO_shadow) glDeleteBuffers(1, &mIBO_shadow);
  if (mVBO_shadow_position) glDeleteBuffers(1, &mVBO_shadow_position);
  if (mVAO_shadow) glDeleteVertexArrays(1, &mVAO_shadow);
}

void MeshObj::setData(const MeshData &meshData) {
  // TODO: copy mesh data into local mMeshData container (only vertex positions and indices needed) // You will need the vertex data to create shadow volumes later on //
  mMeshData.vertex_position.clear();
  mMeshData.vertex_position.assign(meshData.vertex_position.begin(), meshData.vertex_position.end());
  mMeshData.indices.clear();
  mMeshData.indices.assign(meshData.indices.begin(), meshData.indices.end());
  
  mIndexCount = meshData.indices.size();
  
  // create local storage arrays for vertices, normals and indices //
  unsigned int vertexDataSize = meshData.vertex_position.size();
  unsigned int vertexNormalSize = meshData.vertex_normal.size();
  unsigned int vertexTexcoordSize = meshData.vertex_texcoord.size();
  unsigned int vertexTangentSize = meshData.vertex_tangent.size();
  unsigned int vertexBinormalSize = meshData.vertex_binormal.size();
  
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
  GLfloat *vertex_tangent = NULL;
  if (vertexTangentSize > 0) {
    vertex_tangent = new GLfloat[vertexTangentSize]();
    std::copy(meshData.vertex_tangent.begin(), meshData.vertex_tangent.end(), vertex_tangent);
  }
  GLfloat *vertex_binormal = NULL;
  if (vertexBinormalSize > 0) {
    vertex_binormal = new GLfloat[vertexBinormalSize]();
    std::copy(meshData.vertex_binormal.begin(), meshData.vertex_binormal.end(), vertex_binormal);
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
  
  if (vertexTangentSize > 0) {
    if (mVBO_tangent == 0) {
      glGenBuffers(1, &mVBO_tangent);
    }
    glBindBuffer(GL_ARRAY_BUFFER, mVBO_tangent);
    glBufferData(GL_ARRAY_BUFFER, vertexTangentSize * sizeof(GLfloat), &vertex_tangent[0], GL_STATIC_DRAW);
    glVertexAttribPointer(3, 3, GL_FLOAT, GL_FALSE, 0, (void*)0);
    glEnableVertexAttribArray(3);
  }
  
  if (vertexBinormalSize > 0) {
    if (mVBO_binormal == 0) {
      glGenBuffers(1, &mVBO_binormal);
    }
    glBindBuffer(GL_ARRAY_BUFFER, mVBO_binormal);
    glBufferData(GL_ARRAY_BUFFER, vertexBinormalSize * sizeof(GLfloat), &vertex_binormal[0], GL_STATIC_DRAW);
    glVertexAttribPointer(4, 3, GL_FLOAT, GL_FALSE, 0, (void*)0);
    glEnableVertexAttribArray(4);
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
  if (vertexTangentSize > 0) {
    delete[] vertex_tangent;
  }
  if (vertexBinormalSize > 0) {
    delete[] vertex_binormal;
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

// TODO: create a shadow volume by processing the original vertex data of this object and by projecting every vertex along the directional vector coming from the light source //
void MeshObj::initShadowVolume(glm::vec3 lightPos) {
  // TODO: create a local storage for your shadow volume vertex data and the indices used for rendering //
  // you might want to use a MeshData container //
     MeshData shadows;
  // TODO: clone existing vertex data into your local storage //
     shadows.vertex_position = mMeshData.vertex_position; // öhm ne glaube nicht das das funktioniert
     shadows.indices 		 = mMeshData.indices;
     shadows.vertex_normal   = mMeshData.vertex_normal;
  // TODO: for every vertex:                         //
  // - project vertex from lightsource to *infinity* //
  // - append vertex to local vertex data storage    //
     GLfloat farFarAway = camera.getFar()-1.0f; // TODO das gibt so probleme

     for (int i=0 ; i < shadows.indices.size() ; i+=3){

    	GLfloat x,y,z;
    	glm::vec3 lDir;

    	lDir.x = (lightPos.x - shadows.vertex_position[i]);
    	lDir.y = (lightPos.y - shadows.vertex_position[i+1]);
    	lDir.z = (lightPos.z - shadows.vertex_position[i+2]);

    	lDir = glm::normalize(lDir);
    	lDir = lDir * farFarAway;

    	shadows.vertex_position.push_back(lDir.x);
    	shadows.vertex_position.push_back(lDir.y);
    	shadows.vertex_position.push_back(lDir.z);

    	shadows.vertex_normal.push_back(-shadows.vertex_normal[i]);
    	shadows.vertex_normal.push_back(-shadows.vertex_normal[i+1]);
    	shadows.vertex_normal.push_back(-shadows.vertex_normal[i+2]);

     }

  // TODO: the vertex data is now stored as two concatenated sets in a single vector //
  // - the first set contains the original vertex data                               //
  // - the second set contains the projected vertex data *in the same order*         //
  // -> you might want to store the size of such a set to easily access              //
  //    corresponding vertices later on                                              //
    GLuint sizeOfSet = shadows.vertex_position.size();
  // TODO: project 8 (6 sides + 2 caps) shadow triangles for each mesh triangle //
  // - process every geometry face and create 6 (or 8) new faces from it        //
  // - be sure to check the face orientation and flip back facing triangles     //  
  //   when creating the shadow volume
  //
    glm::vec3 a,b,c,a1,b1,c1;
    for (int i = 0 ; i < shadows.indices.size() ; i = i + 9){
      a.x = shadows.indices[i*3];
      a.y = shadows.indices[(i+1)*3];
      a.z = shadows.indices[(i+2)*3];

      b.x = shadows.indices[i*3+3];
      b.y = shadows.indices[(i+1)*3+3];
      b.z = shadows.indices[(i+2)*3+3];

      c.x = shadows.indices[i*3+6];
      c.y = shadows.indices[(i+1)*3+6];
      c.z = shadows.indices[(i+1)*3+6];

      a1.x = sizeOfSet + i*3;
      a1.x = sizeOfSet + (i+1)*3;
      a1.x = sizeOfSet + (i+2)*3;

      b1.x = sizeOfSet + i*3+3;
      b1.y = sizeOfSet + (i+1)*3+3;
      b1.z = sizeOfSet + (i+2)*3+3;

      c1.x = sizeOfSet + i*3+6;
      c1.y = sizeOfSet + (i+1)*3+6;
      c1.z = sizeOfSet + (i+2)*3+6;

      // Unten 1
      shadows.indices.push_back(b.x);shadows.indices.push_back(b.y);shadows.indices.push_back(b.z);
      shadows.indices.push_back(b1.x);shadows.indices.push_back(b1.y);shadows.indices.push_back(b1.z);
      shadows.indices.push_back(c.x);shadows.indices.push_back(c.y);shadows.indices.push_back(c.z);
      // Unten 2
      shadows.indices.push_back(c.x);shadows.indices.push_back(c.y);shadows.indices.push_back(c.z);
      shadows.indices.push_back(b1.x);shadows.indices.push_back(b1.y);shadows.indices.push_back(b1.z);
      shadows.indices.push_back(c1.x);shadows.indices.push_back(c1.y);shadows.indices.push_back(c1.z);
      // Vorne 1
      shadows.indices.push_back(c.x);shadows.indices.push_back(c.y);shadows.indices.push_back(c.z);
      shadows.indices.push_back(a.x);shadows.indices.push_back(a.y);shadows.indices.push_back(a.z);
      shadows.indices.push_back(a1.x);shadows.indices.push_back(a1.y);shadows.indices.push_back(a1.z);
      // Vorne 2
      shadows.indices.push_back(c.x);shadows.indices.push_back(c.y);shadows.indices.push_back(c.z);
      shadows.indices.push_back(c1.x);shadows.indices.push_back(c1.y);shadows.indices.push_back(c1.z);
      shadows.indices.push_back(a1.x);shadows.indices.push_back(a1.y);shadows.indices.push_back(a1.z);
      // Hinten 1
      shadows.indices.push_back(b.x);shadows.indices.push_back(b.y);shadows.indices.push_back(b.z);
      shadows.indices.push_back(a.x);shadows.indices.push_back(a.y);shadows.indices.push_back(a.z);
      shadows.indices.push_back(a1.x);shadows.indices.push_back(a1.y);shadows.indices.push_back(a1.z);
      // Hinten 2
      shadows.indices.push_back(b.x);shadows.indices.push_back(b.y);shadows.indices.push_back(b.z);
      shadows.indices.push_back(b1.x);shadows.indices.push_back(b1.y);shadows.indices.push_back(b1.z);
      shadows.indices.push_back(a1.x);shadows.indices.push_back(a1.y);shadows.indices.push_back(a1.z);
      // DECKEL 012 -> 021
      shadows.indices.push_back(a1.x);shadows.indices.push_back(a1.y);shadows.indices.push_back(a1.z);
      shadows.indices.push_back(c1.x);shadows.indices.push_back(c1.y);shadows.indices.push_back(c1.z);
      shadows.indices.push_back(b1.x);shadows.indices.push_back(b1.y);shadows.indices.push_back(b1.z);
    }
  // TODO: save the index count of your shadow volume object in 'mIndexCount_shadow' //
      mIndexCount_shadow = shadows.indices.size();
  // TODO: setup VAO, VBO and IBO for shadow volume //

  // - use the predefined class members mVAO_shadow, mVBO_shadow_position and mIBO_shadow //
      unsigned int vertexDataSize = shadows.vertex_position.size();
      GLfloat* vertexPosition = new GLfloat[vertexDataSize];
      std::copy(shadows.vertex_position.begin(),shadows.vertex_position.end(),vertexPosition);
      GLuint* vertexIndices = new GLuint[mIndexCount_shadow];
      std::copy(shadows.indices.begin(),shadows.indices.end(),vertexIndices);
      if(mVAO_shadow == 0 ){
    	  glGenVertexArrays(1, &mVAO_shadow);
      }
      glBindVertexArray(mVAO_shadow);

      if(mVBO_shadow_position ==0){
    	  glGenBuffers(1,&mVBO_shadow_position);
      }
      glBindBuffer(GL_ARRAY_BUFFER, mVBO_shadow_position);
      glBufferData(GL_ARRAY_BUFFER, vertexDataSize*sizeof(GLfloat),vertexPosition,GL_STATIC_DRAW);

      if(mIBO_shadow == 0){
         glGenBuffers(1,&mIBO_shadow);
      }
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mIBO_shadow);
      glBufferData(GL_ELEMENT_ARRAY_BUFFER, mIndexCount_shadow*sizeof(GLuint),vertexIndices,GL_STATIC_DRAW);

      glBindVertexArray(0);

      if(mIndexCount_shadow > 0){
      delete[] vertexIndices;
      }
      if(vertexDataSize > 0){
      delete[] vertexPosition;
      }

}

// TODO: render the shadow volume by calling the vertex array object //
void MeshObj::renderShadowVolume() {
  if(mVAO_shadow != 0 ){
	 glBindVertexArray(mVAO_shadow);
	 glDrawElements(GL_TRIANGLES,mIndexCount_shadow,GL_UNSIGNED_INT,(void*)0);
	 glBindVertexArray(0);
  }
  
}

#include "MeshObj.h"
#include <iostream>
#include <limits>
#include <string.h>

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
	GLfloat* vert;
	GLfloat* norms;
	GLuint*  ind;

	vert = (GLfloat*) malloc(sizeof(GLfloat) * meshData.vertex_position.size());
	norms = (GLfloat*) malloc(sizeof(GLfloat) * meshData.vertex_normal.size());
	ind = (GLuint*) malloc(sizeof(GLuint) * mIndexCount);
	
	// TODO: copy data into local arrays //
	memcpy(vert, meshData.vertex_position.data(), sizeof(GLfloat) * meshData.vertex_position.size());
	memcpy(norms, meshData.vertex_normal.data(), sizeof(GLfloat) * meshData.vertex_normal.size());
	memcpy(ind, meshData.indices.data(), sizeof(GLuint) * meshData.indices.size());

	// TODO: create VAO //
	glGenVertexArrays(1, &mVAO);
	glBindVertexArray(mVAO);

	// TODO: create and bind VBOs and upload data (one VBO per vertex attribute -> position, normal) //
	glGenBuffers(1, &mVBO_position);
	glBindBuffer(GL_ARRAY_BUFFER, mVBO_position);
	glBufferData(GL_ARRAY_BUFFER, meshData.vertex_position.size() * sizeof(GLfloat), 

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

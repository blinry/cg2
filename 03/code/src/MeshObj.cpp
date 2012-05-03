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
	glBufferData(GL_ARRAY_BUFFER, meshData.vertex_position.size() * sizeof(GLfloat), vert, GL_STATIC_DRAW);
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
	glEnableVertexAttribArray(0);

	glGenBuffers(1, &mVBO_normal);
	glBindBuffer(GL_ARRAY_BUFFER, mVBO_normal);
	glBufferData(GL_ARRAY_BUFFER, meshData.vertex_normal.size() * sizeof(GLfloat), norms, GL_STATIC_DRAW);
	glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, 0);
	glEnableVertexAttribArray(1);

	// TODO: init and bind a IBO //
	glGenBuffers(1, &mIBO);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mIBO);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, mIndexCount * sizeof(GLuint), ind, GL_STATIC_DRAW);

	// unbind buffers //
	glBindVertexArray(0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

	// TODO: make sure to clean up temporarily allocated data, if neccessary //
	free(vert);
	free(norms);
	free(ind);
}

void MeshObj::render(void) {
	if (mVAO != 0) {
		// TODO: render your VAO //
		glBindVertexArray(mVAO);
		glDrawElements(GL_TRIANGLES, mIndexCount ,GL_UNSIGNED_INT, 0);

		glBindVertexArray(0);
	}
}

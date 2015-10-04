#ifndef __MESH_OBJ__
#define __MESH_OBJ__

#include <GL/glew.h>
#include <GL/freeglut.h>

#include <vector>
#include <stack>

#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/matrix_inverse.hpp>
#include <glm/gtx/rotate_vector.hpp>
#include <glm/gtx/string_cast.hpp>

struct MeshData {
  // data vectors //
  std::vector<GLfloat> vertex_position;
  std::vector<GLfloat> vertex_normal;
  std::vector<GLfloat> vertex_texcoord;
  std::vector<GLfloat> vertex_tangent;
  std::vector<GLfloat> vertex_binormal;
  // index list //
  std::vector<GLuint> indices;
};

class MeshObj {
  public:
    MeshObj();
    ~MeshObj();

    void setData(const MeshData &data);
    void render(void);

    void initShadowVolume(glm::vec3 lightPos);
    void renderShadowVolume();

  private:
    GLuint mVAO;

    GLuint mVBO_position;
    GLuint mVBO_normal;
    GLuint mVBO_texcoord;
    GLuint mVBO_tangent;
    GLuint mVBO_binormal;

    GLuint mIBO;
    GLuint mIndexCount;

    // #INFO# local copy of the original mesh data    //
    //  - needed to compute shadow volumes on the fly //
    MeshData mMeshData;

    // #INFO# vertex buffer object for shadow volume //
    GLuint mVAO_shadow;
    GLuint mVBO_shadow_position;
    GLuint mIBO_shadow;
    GLuint mIndexCount_shadow;
};

#endif

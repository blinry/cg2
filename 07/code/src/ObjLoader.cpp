#include "ObjLoader.h"

#include <iostream>
#include <fstream>
#include <sstream>
#include <cmath>

ObjLoader::ObjLoader() {
}

ObjLoader::~ObjLoader() {
  for (std::map<std::string, MeshObj*>::iterator iter = mMeshMap.begin(); iter != mMeshMap.end(); ++iter) {
    delete iter->second;
    iter->second = NULL;
  }
  mMeshMap.clear();
}

MeshObj* ObjLoader::loadObjFile(std::string fileName, std::string ID) {
  // sanity check for identfier -> must not be empty //
  if (ID.length() == 0) {
    return NULL;
  }
  // try to load the MeshObj for ID //
  MeshObj* meshObj = getMeshObj(ID);
  if (meshObj != NULL) {
    // if found, return it instead of loading a new one from file //
    return meshObj;
  }
  // ID is not known yet -> try to load mesh from file //
  
  // import mesh from given file //
  // setup variables used for parsing //
  std::string key;
  float x, y, z;

  // local lists //
  // these lists are used to store the imported information
  // before putting the data into the MeshData container for the MeshObj
  std::vector<glm::vec3> localVertexPosition;
  std::vector<glm::vec3> localVertexNormal;
  std::vector<glm::vec2> localVertexTexcoord;
  std::vector<std::vector<glm::vec3> > localFace;
  
  // setup tools for parsing a line correctly //
  std::string line;
  std::stringstream sstr;

  // open file //
  unsigned int lineNumber = 0;
  std::ifstream file(fileName.c_str());
  if (file.is_open()) {
    while (file.good()) {
      key = "";
      getline(file, line);
      sstr.clear();
      sstr.str(line);
      sstr >> key;
      if (!key.compare("v")) {
        // read in vertex //
        sstr >> x >> y >> z;
	localVertexPosition.push_back(glm::vec3(x, y, z));
      }
      // TODO: implement parsing of vertex normal and texture coordinate //
      if (!key.compare("vn")) {
        // read in vertex normal //
	sstr >> x >> y >> z;
	localVertexNormal.push_back(glm::vec3(x, y, z));
        
      }
      if (!key.compare("vt")) {
        // read in vertex normal //
	sttr >> x >> y >> z;
	localVertexTexcoord.push_back(glm::vec3(x, y, z));
        
      }
      // TODO: implement parsing of a face definition //
      // note: faces using normals and tex-coords are defines as "f vi0/ti0/ni0 ... viN/tiN/niN"
      //       vi0 .. viN : vertex index of vertex 0..N
      //       ti0 .. tiN : texture coordinate index of vertex 0..N
      //       ni0 .. niN : vertex normal index of vertex 0..N
      //       faces without normals and texCoords are defined as  "f vi0// ... viN//"
      //       faces without texCoords are defined as              "f vi0//ni0 ... viN//niN"
      //       make your parser robust against ALL possible combinations
      //       also allow to import QUADS as faces. directly split them up into two triangles!
      // put every face definition into the 'localFace' vector
      // -> a face is represented as set of index triplets (vertexId, normalId, texCoordId)
      //    thus is can be stored in a std::vector<glm::vec3>
      if (!key.compare("f")) {
	// read in vertex indices for a face //
	
        
      }
      ++lineNumber;
    }
    file.close();
    
    std::cout << "Imported " << localFace.size() << " faces from \"" << fileName << "\"" << std::endl;
    
    // TODO: create an indexed vertex for every triplet of vertexId, normalId and texCoordId //
    //  every face is able to use a different set of vertex normals and texture coordinates
    //  when using a single vertex for multiple faces, however, this conflicts multiple normals
    //  rearrange and complete the imported data in the following way:
    //  - if a vertex uses multiple normals and/or texture coordinates, create copies of that vertex
    //  - every triplet (vertexId, texCoordId, normalId) is unique and indexed by meshData.indices
    // one vertex definition per index-triplet (vertexId, texCoordId, normalId) //
    // this vertex definition is distributed over the separate vertex attribute arrays
    //  - meshData.vertex_position
    //  - meshData.vertex_normal
    //  - meshData.vertex_texcoord
    // add a new set of values to these array, whenever adding a new vertex for a new triplet
    // when adding this new vertex defintion, assign a new index to put into meshData.indices
    // when reuisng a vertex definition of an already known triplet, reuse the index for that triplet and put it into meshData.indices
    // hint: you might want to use a std::map to remember already known id-triplets and their indices
    MeshData meshData;
    
    
    // create new MeshObj and set imported geoemtry data //
    meshObj = new MeshObj();
    // assign imported data to this new MeshObj //
    meshObj->setData(meshData);
    
    // insert MeshObj into map //
    mMeshMap.insert(std::make_pair(ID, meshObj));
    
    // return newly created MeshObj //
    return meshObj;
  } else {
    std::cout << "(ObjLoader::loadObjFile) : Could not open file: \"" << fileName << "\"" << std::endl;
    return NULL;
  }
}

MeshObj* ObjLoader::getMeshObj(std::string ID) {
  // sanity check for ID //
  if (ID.length() > 0) {
    std::map<std::string, MeshObj*>::iterator mapLocation = mMeshMap.find(ID);
    if (mapLocation != mMeshMap.end()) {
      // mesh with given ID already exists in meshMap -> return this mesh //
      return mapLocation->second;
    }
  }
  // no MeshObj found for ID -> return NULL //
  return NULL;
}

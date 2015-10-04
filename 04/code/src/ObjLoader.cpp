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

  // TODO: import mesh from given file //
  // setup variables used for parsing //
  std::string key;
  float x, y, z;
  unsigned int i, j, k;

  // setup local lists //
  MeshData meshData;

  // setup tools for parsing a line correctly //
  std::string line;
  std::stringstream sstr;

  // open file //
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
	meshData.vertex_position.push_back(x);
	meshData.vertex_position.push_back(y);
	meshData.vertex_position.push_back(z);
      }
      if (!key.compare("vn")) {
        // read in vertex normal //
        sstr >> x >> y >> z;
	meshData.vertex_normal.push_back(x);
	meshData.vertex_normal.push_back(y);
	meshData.vertex_normal.push_back(z);
      }
      if (!key.compare("f")) {
        // read in vertex indices for a face //
        sstr >> i >> j >> k;
        meshData.indices.push_back(i - 1);
        meshData.indices.push_back(j - 1);
        meshData.indices.push_back(k - 1);
      }
    }
    file.close();
    std::cout << "Imported " << meshData.indices.size() / 3 << " faces from \"" << fileName << "\"" << std::endl;

    // create new MeshObj and set imported geoemtry data //
    meshObj = new MeshObj();
    // TODO: assign imported data to this new MeshObj //
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

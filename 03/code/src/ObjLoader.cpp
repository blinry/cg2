#include "ObjLoader.h"

#include <iostream>
#include <fstream>
#include <sstream>
#include <cmath>
#include <string.h>

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
  // setup temporary data container //
  MeshData meshData;
  
  std::fstream file ;//(fileName, std::fstream::in);
  file.open(fileName.c_str() , std::fstream::in );
  char temp[50];
  GLfloat x,y,z;
  while(file.getline(temp,50) && !file.eof()){
	  
	  
	  if(strncmp(temp,"v ",2) == 0){
	    sscanf(temp,"v %f %f %f", &x,&y,&z);
		meshData.vertex_position.push_back(x);
		meshData.vertex_position.push_back(y);
		meshData.vertex_position.push_back(z);
	  }

	  if(strncmp(temp,"vn ",3) == 0){
	    sscanf(temp,"vn %f %f %f", &x, &y, &z);
		meshData.vertex_normal.push_back(x);
		meshData.vertex_normal.push_back(y);
		meshData.vertex_normal.push_back(z);
	  }

	  if(strncmp(temp,"f ",2) == 0 ){
	    sscanf(temp,"f %f %f %f", &x,&y,&z);
		meshData.indices.push_back(x);
		meshData.indices.push_back(y);
		meshData.indices.push_back(z);
	  
	  }

  }
  
  // setup variables used for parsing //
    
  // create new MeshObj and set imported geoemtry data //
  meshObj = new MeshObj();
  // TODO: assign imported data to this new MeshObj //
  meshObj->setData(meshData);
  // insert MeshObj into map //
  mMeshMap.insert(std::make_pair(ID, meshObj));
  
  // return newly created MeshObj //
  return meshObj;
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

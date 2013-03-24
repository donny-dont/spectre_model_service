/*
  Copyright (C) 2013 Spectre Authors

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/

part of assimp;

/// The root structure of the imported data.
///
/// This maps to the aiScene structure within assimp.
class Scene {
  //-------------------------------------------------------------------
  // Member variables
  //-------------------------------------------------------------------

  List<Mesh> _meshes = new List<Mesh>();

  /// Creates an instance of the [Scene] class from JSON data.
  Scene.fromJson(Map json) {


    // Load the meshes
    List<Map> meshJsons = json['meshes'];

    meshJsons.forEach((meshJson) {
      Mesh mesh = new Mesh.fromJson(meshJson);

      _meshes.add(mesh);

      print('Name: ${mesh.name}');
      print('Vertices  : ${mesh.vertices}');
      print('Normals   : ${mesh.normals}');
      print('Tangents  : ${mesh.tangents}');
      print('Bitangents: ${mesh.bitangents}');
    });
  }

  List<Mesh> get meshes => _meshes;
}

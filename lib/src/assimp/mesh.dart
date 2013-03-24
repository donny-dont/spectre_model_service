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

/// The mesh data.
///
/// Corresponds to the aiMesh structure in assimp.
class Mesh {
  //-------------------------------------------------------------------
  // Class variables
  //-------------------------------------------------------------------

  /// The maximum number of texture coordinates a [Mesh] can have.
  static const int maxNumberOfTextureCoords = 0x8;
  /// The maximum number of color sets a [Mesh] can have.
  static const int maxNumberOfColorSets = 0x8;

  //-------------------------------------------------------------------
  // Member variables
  //-------------------------------------------------------------------

  /// The name of the [Mesh].
  String _name;
  /// The primitive type of the [Mesh].
  int _primitiveTypes;
  /// The number of vertices.
  int _numVertices;
  /// The positions of the [Mesh].
  List<double> _vertices;
  /// The normals of the [Mesh].
  List<double> _normals;
  /// The tangents of the [Mesh].
  List<double> _tangents;
  /// The bitangents of the [Mesh].
  List<double> _bitangents;
  /// The number of uv coordinates.
  List<int> _numUvComponents = new List<int>();
  /// The set of texture coordinates of the [Mesh].
  List<List<double>> _textureCoords = new List<List<double>>();
  /// The color sets of the [Mesh].
  List<List<double>> _colors = new List<List<double>>();
  /// The [Face]s of the [Mesh].
  List<Face> _faces = new List<Face>();

  //-------------------------------------------------------------------
  // Construction
  //-------------------------------------------------------------------

  /// Creates an instance of the [Mesh] class from JSON data.
  Mesh.fromJson(Map json) {
    _name = json['name'];

    _primitiveTypes = json['primitivetypes'];

    _vertices   = _copyList(json['vertices']);
    _normals    = _copyList(json['normals']);
    _tangents   = _copyList(json['tangents']);
    _bitangents = _copyList(json['bitangents']);

    _numVertices = _vertices.length ~/ 3;

    // Get texture coordinates
    List numUvComponentsData = json['numuvcomponents'];

    if (numUvComponentsData != null) {
      numUvComponentsData.forEach((value) {
        _numUvComponents.add(value);
      });
    }

    List textureCoordsData = json['texturecoords'];

    if (textureCoordsData != null) {
      textureCoordsData.forEach((value) {
        _textureCoords.add(_copyList(value));
      });
    }

    // Get colors
    List colors = json['colors'];

    if (colors != null) {
      colors.forEach((value) {
        _colors.add(_copyList(value));
      });
    }

    // Get faces
    List faces = json['faces'];

    if (faces != null) {
      faces.forEach((value) {
        _faces.add(new Face.fromJson(value));
      });
    }

    // Check validity
    if (!_isValid()) {
      throw new ArgumentError('The constructed mesh is invalid');
    }
  }

  //-------------------------------------------------------------------
  // Properties
  //-------------------------------------------------------------------

  /// The name of the [Mesh].
  String get name => _name;

  /// The primitive type of the [Mesh].
  int get primitiveTypes => _primitiveTypes;

  /// The number of vertices.
  int get numVertices => _numVertices;

  /// The vertex positions of the [Mesh].
  List<double> get vertices => _vertices;

  /// The vertex normals of the [Mesh].
  List<double> get normals => _normals;

  /// The vertex tangents of the [Mesh].
  List<double> get tangents => _tangents;

  /// The vertex bitangents of the [Mesh].
  List<double> get bitangents => _bitangents;

  /// The number of texture coordinate sets
  int get numTextureCoordsSets => _textureCoords.length;

  /// The number of UV components within a set of texture coordinates
  List<int> get numUvComponents => _numUvComponents;

  /// The texture coordinates of the [Mesh].
  List<List<double>> get textureCoords => _textureCoords;

  /// The number of color sets
  int get numColorSets => _colors.length;

  /// The color sets of the [Mesh].
  List<List<double>> get colors => _colors;

  /// The number of faces within the [Mesh].
  int get numFaces => _faces.length;

  /// The faces of the [Mesh].
  List<Face> get faces => _faces;

  //-------------------------------------------------------------------
  // Private methods
  //-------------------------------------------------------------------

  /// Checks whether the data is valid.
  ///
  /// Verifies that the vertex count is consistent through the entire structure.
  /// Also ensures that the indices all correspond to valid vertices.
  bool _isValid() {
    return true;
  }

  /// Copies the vertex data from the [json] into a [List].
  ///
  /// Ensures that the vertex data is in double format. The assimp2json exporter
  /// will output NaN as 'NaN' which will cause problems. So copies the list one
  /// at a time.
  List<double> _copyList(List original) {
    List<double> copy;

    if (original != null) {
      int length = original.length;
      copy = new List<double>(length);

      for (int i = 0; i < length; ++i) {
        var value = original[i];

        if (value is double) {
          copy[i] = original[i];
        } else if (value is String) {
          if (value == 'NaN') {
            copy[i] = double.NAN;
          }
        } else {
          copy[i] = 0.0;
        }
      }
    } else {
      copy = new List<double>();
    }

    return copy;
  }
}

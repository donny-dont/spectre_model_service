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

part of spectre_exporter;

/// Exports a [Mesh] into a format readable by Spectre.
class MeshExporter {
  //-------------------------------------------------------------------
  // Class variables
  //-------------------------------------------------------------------

  /// The name of the primitive type key.
  static const String _primitiveTypeName = 'primitiveType';
  /// The name of the vertex buffer key.
  static const String _vertexBuffersName = 'vertexBuffers';
  /// The name of the layout key.
  static const String _vertexLayoutName = 'layout';
  /// The name of the stride key.
  static const String _strideName = 'stride';
  /// The name of the buffer key.
  static const String _bufferName = 'buffer';
  /// The name of the vertices key.
  static const String _verticesName = 'vertices';
  /// The name of the index size key.
  static const String _indexSizeName = 'indexSize';
  /// The name of the indices key.
  static const String _indicesName = 'indices';
  /// The size of a floating point value in bytes.
  static const int _floatSize = 4;

  //-------------------------------------------------------------------
  // Public methods
  //-------------------------------------------------------------------

  /// Exports the [Mesh] data.
  static Map export(List<Mesh> meshes, VertexLayout layout) {
    if (!_isMeshDataValid(meshes)) {
      throw new ArgumentError('The meshes do not have the same elements');
    }

    List<Map> buffers = new List<Map>();

    // Output the vertex buffers
    int vertexCount = _getVertexCount(meshes);
    int bufferCount = layout.bufferCount;

    print('Vertex count $vertexCount');

    for (int i = 0; i < bufferCount; ++i) {
      List<String> bufferElements = layout.buffers[i];
      bool simdAligned = layout.simdAligned[i];
      Mesh mesh = meshes[0];

      // Compute the stride
      int stride = _getVertexLayoutStride(mesh, bufferElements, simdAligned);

      // Check to see if any vertex data should be outputted
      if (stride != 0) {
        List<Map> layoutData = new List<Map>();

        // Create the array to hold the values
        Float32List vertices = new Float32List(vertexCount * stride);

        int offset = 0;

        // Output positions if requested
        if (_outputPositions(mesh, bufferElements)) {
          layoutData.add(_outputLayout(VertexLayout._positionName, VertexLayout._positionElements, offset));

          offset += _copyPositionData(vertices, meshes, offset, stride, simdAligned);
        }

        // Output normals if requested
        if (_outputNormals(mesh, bufferElements)) {
          layoutData.add(_outputLayout(VertexLayout._normalName, VertexLayout._normalElements, offset));

          offset += _copyNormalData(vertices, meshes, offset, stride, simdAligned);
        }

        // Output tangents if requested
        if (_outputTangents(mesh, bufferElements)) {
          layoutData.add(_outputLayout(VertexLayout._tangentName, VertexLayout._tangentElements, offset));

          offset += _copyTangentData(vertices, meshes, offset, stride, simdAligned);
        }

        // Output bitangents if requested
        if (_outputBitangents(mesh, bufferElements)) {
          layoutData.add(_outputLayout(VertexLayout._bitangentName, VertexLayout._bitangentElements, offset));

          offset += _copyBitangentData(vertices, meshes, offset, stride, simdAligned);
        }

        // Output texture coordinates if requested
        int numTexCoordsSets = mesh.numTextureCoordsSets;

        for (int i = 0; i < numTexCoordsSets; ++i) {
          if (_outputTextureCoordsSet(mesh, i, bufferElements)) {
            layoutData.add(_outputLayout(VertexLayout._getTexCoordName(i), mesh.numUvComponents[i], offset));

            offset += _copyTextureCoordsData(vertices, meshes, i, offset, stride, simdAligned);
          }
        }

        // Output colors if requested
        int numColorSets = mesh.numColorSets;

        for (int i = 0; i < numColorSets; ++i) {
          if (_outputColorsSet(mesh, i, bufferElements)) {
            layoutData.add(_outputLayout(VertexLayout._getTexCoordName(i), VertexLayout._colorElements, offset));

            offset += _copyColorsData(vertices, meshes, i, offset, stride, simdAligned);
          }
        }

        // Create the map data for the buffer
        Map bufferData = new Map();
        bufferData[_strideName] = stride * _floatSize;
        bufferData[_vertexLayoutName] = layoutData;
        bufferData[_verticesName] = vertices;

        buffers.add(bufferData);
      }
    }

    // Create the map data for the mesh
    Map meshData = new Map();

    String primitiveType;

    switch (meshes[0].primitiveTypes) {
      case PrimitiveType.Point   : primitiveType = 'Points'   ; break;
      case PrimitiveType.Line    : primitiveType = 'Lines'    ; break;
      case PrimitiveType.Triangle: primitiveType = 'Triangles'; break;
    }

    meshData[_primitiveTypeName] = primitiveType;
    meshData[_vertexBuffersName] = buffers;

    // Create the index buffer if necessary
    int indexCount = _getIndexCount(meshes);

    if (indexCount != 0) {
      List<int> indices;

      // Account for index size
      if (vertexCount < 65535) {
        meshData[_indexSizeName] = 'Short';
        indices = new Uint16List(indexCount);
      } else {
        meshData[_indexSizeName] = 'Integer';
        indices = new Uint32List(indexCount);
      }

      // Add the indices
      int vertexOffset = 0;
      int meshCount = meshes.length;
      int index = 0;

      for (int k = 0; k < meshCount; ++k) {
        Mesh mesh = meshes[k];
        List<Face> faces = mesh.faces;
        int faceCount = mesh.numFaces;

        for (int j = 0; j < faceCount; ++j) {
          Face face = faces[j];
          int indexCount = face.numIndices;

          for (int i = 0; i < indexCount; ++i) {
            indices[index++] = face.indices[i] + vertexOffset;
          }
        }

        vertexOffset += mesh.numVertices;
      }

      meshData[_indicesName] = indices;
    }

    return meshData;
  }

  //-------------------------------------------------------------------
  // Private methods
  //-------------------------------------------------------------------

  /// Gets the total number of vertices contained in the [meshses].
  static int _getVertexCount(List<Mesh> meshes) {
    int count = 0;
    int meshCount = meshes.length;

    for (int i = 0; i < meshCount; ++i) {
      count += meshes[i].numVertices;
    }

    return count;
  }

  /// Gets the stride for a given set of elements.
  ///
  /// This is used to get the size of the Float32Array to use.
  static int _getVertexLayoutStride(Mesh mesh, List<String> bufferElements, bool simdAligned) {
    int packed = 0;
    int elements = 0;

    // Compute the stride for the standard attributes
    if (_outputPositions(mesh, bufferElements)) {
      packed += VertexLayout._positionElements;
      elements++;
    }

    if (_outputNormals(mesh, bufferElements)) {
      packed += VertexLayout._normalElements;
      elements++;
    }

    if (_outputTangents(mesh, bufferElements)) {
      packed += VertexLayout._tangentElements;
      elements++;
    }

    if (_outputBitangents(mesh, bufferElements)) {
      packed += VertexLayout._bitangentElements;
      elements++;
    }

    // Compute the stride for texture coordinates
    int numTexCoordSets = mesh.numTextureCoordsSets;

    for (int i = 0; i < numTexCoordSets; ++i) {
      if (_outputTextureCoordsSet(mesh, i, bufferElements)) {
        packed += mesh.numUvComponents[i];
        elements++;
      }
    }

    // Compute the stride for colors
    int numColorSets = mesh.numColorSets;

    for (int i = 0; i < numColorSets; ++i) {
      if (_outputColorsSet(mesh, i, bufferElements)) {
        packed += VertexLayout._colorElements;
        elements++;
      }
    }

    return (simdAligned) ? elements * 4 : packed;
  }

  /// Gets the total number of indices contained in the [meshes].
  static int _getIndexCount(List<Mesh> meshes) {
    int count = 0;
    int meshCount = meshes.length;

    for (int i = 0; i < meshCount; ++i) {
      Mesh mesh = meshes[i];

      count += mesh.numFaces * mesh.faces[0].numIndices;
    }

    return count;
  }

  /// Sanity checking for the [Mesh] data.
  ///
  /// Verifies that each mesh has the same elements.
  static bool _isMeshDataValid(List<Mesh> meshes) {
    return true;
  }

  /// Whether the position data should be outputted.
  static bool _outputPositions(Mesh mesh, List<String> bufferElements) {
    return bufferElements.contains(VertexLayout._positionName);
  }

  /// Whether the normal data should be outputted.
  static bool _outputNormals(Mesh mesh, List<String> bufferElements) {
    return (mesh.normals.length != 0) && (bufferElements.contains(VertexLayout._normalName));
  }

  /// Whether the tangent data should be outputted.
  static bool _outputTangents(Mesh mesh, List<String> bufferElements) {
    return (mesh.tangents.length != 0) && (bufferElements.contains(VertexLayout._tangentName));
  }

  /// Whether the bitangent data should be outputted.
  static bool _outputBitangents(Mesh mesh, List<String> bufferElements) {
    return (mesh.bitangents.length != 0) && (bufferElements.contains(VertexLayout._bitangentName));
  }

  /// Whether the texture coordinate data at the given [index] should be outputted.
  static bool _outputTextureCoordsSet(Mesh mesh, int index, List<String> bufferElements) {
    if (index >= mesh.numTextureCoordsSets) {
      return false;
    }

    return bufferElements.contains(VertexLayout._getTexCoordName(index));
  }

  /// Whether the color data at the given [index] should be outputted.
  static bool _outputColorsSet(Mesh mesh, int index, List<String> bufferElements) {
    if (index >= mesh.numColorSets) {
      return false;
    }

    return bufferElements.contains(VertexLayout._getColorName(index));
  }

  /// Outputs a layout element to a [Map].
  static Map _outputLayout(String name, int elements, int offset) {
    Map layoutData = new Map();

    layoutData['name'] = name;
    layoutData['type'] = 'Float${elements}';
    layoutData['offset'] = offset * _floatSize;

    return layoutData;
  }

  /// Copies positional data from the [meshes] into the [vertices].
  static int _copyPositionData(Float32List vertices, List<Mesh> meshes, int offset, int stride, bool simdAligned) {
    int meshCount = meshes.length;
    List<List<double>> positions = new List<List<double>>(meshCount);

    // Add all the positions
    for (int i = 0; i < meshCount; ++i) {
      positions[i] = meshes[i].vertices;
    }

    return _copyIntoArray(vertices, positions, offset, stride, VertexLayout._positionElements, simdAligned, 1.0);
  }

  // Copies normal data from the [meshes] into the [vertices].
  static int _copyNormalData(Float32List vertices, List<Mesh> meshes, int offset, int stride, bool simdAligned) {
    int meshCount = meshes.length;
    List<List<double>> normals = new List<List<double>>(meshCount);

    // Add all the positions
    for (int i = 0; i < meshCount; ++i) {
      normals[i] = meshes[i].normals;
    }

    return _copyIntoArray(vertices, normals, offset, stride, VertexLayout._normalElements, simdAligned, 0.0);
  }

  // Copies tangent data from the [meshes] into the [vertices].
  static int _copyTangentData(Float32List vertices, List<Mesh> meshes, int offset, int stride, bool simdAligned) {
    int meshCount = meshes.length;
    List<List<double>> tangents = new List<List<double>>(meshCount);

    // Add all the positions
    for (int i = 0; i < meshCount; ++i) {
      tangents[i] = meshes[i].normals;
    }

    return _copyIntoArray(vertices, tangents, offset, stride, VertexLayout._tangentElements, simdAligned, 0.0);
  }

  // Copies normal data from the [meshes] into the [vertices].
  static int _copyBitangentData(Float32List vertices, List<Mesh> meshes, int offset, int stride, bool simdAligned) {
    int meshCount = meshes.length;
    List<List<double>> bitangents = new List<List<double>>(meshCount);

    // Add all the positions
    for (int i = 0; i < meshCount; ++i) {
      bitangents[i] = meshes[i].normals;
    }

    return _copyIntoArray(vertices, bitangents, offset, stride, VertexLayout._bitangentElements, simdAligned, 0.0);
  }

  // Copies texture coordinate data from the [meshes] into the [vertices].
  static int _copyTextureCoordsData(Float32List vertices, List<Mesh> meshes, int index, int offset, int stride, bool simdAligned) {
    int meshCount = meshes.length;
    List<List<double>> textureCoords = new List<List<double>>(meshCount);

    // Add all the positions
    for (int i = 0; i < meshCount; ++i) {
      textureCoords[i] = meshes[i].textureCoords[index];
    }

    return _copyIntoArray(vertices, textureCoords, offset, stride, meshes[0].numUvComponents[index], simdAligned, 0.0);
  }

  // Copies texture coordinate data from the [meshes] into the [vertices].
  static int _copyColorsData(Float32List vertices, List<Mesh> meshes, int index, int offset, int stride, bool simdAligned) {
    int meshCount = meshes.length;
    List<List<double>> colors = new List<List<double>>(meshCount);

    // Add all the positions
    for (int i = 0; i < meshCount; ++i) {
      colors[i] = meshes[i].colors[index];
    }

    return _copyIntoArray(vertices, colors, offset, stride, VertexLayout._colorElements, simdAligned, 0.0);
  }

  static int _copyIntoArray(Float32List vertices, List<List<double>> values, int offset, int stride, int elements, bool simdAligned, double paddingValue) {
    int meshCount = values.length;
    int actualElements = (simdAligned) ? 4 : elements;

    // Update the stride to account for the values being written
    stride -= actualElements;

    for (int j = 0; j < meshCount; ++j) {
      List<double> toCopy = values[j];
      int i = 0;
      int copyCount = toCopy.length;

      // See if padding has to be taken into account
      if (elements == actualElements) {
        while (i < copyCount) {
          for (int x = 0; x < elements; ++x) {
            vertices[offset++] = toCopy[i++];
          }

          offset += stride;
        }
      } else {
        int padding = actualElements - elements;

        while (i < copyCount) {
          for (int x = 0; x < elements; ++x) {
            vertices[offset++] = toCopy[i++];
          }

          for (int x = 0; x < padding; ++x) {
            vertices[offset++] = paddingValue;
          }

          offset += stride;
        }
      }
    }

    return actualElements;
  }
}

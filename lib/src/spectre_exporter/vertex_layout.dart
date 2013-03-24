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

/// Describes the vertex layout to output.
class VertexLayout {
  //-------------------------------------------------------------------
  // Class variables
  //-------------------------------------------------------------------

  /// The name of the position attribute.
  static const String _positionName = 'vPosition';
  /// The name of the normal attribute.
  static const String _normalName = 'vNormal';
  /// The name of the tangent attribute.
  static const String _tangentName = 'vTangent';
  /// The name of the bitangent attribute.
  static const String _bitangentName = 'vBitangent';
  /// The base name of a texture coordinate attribute.
  static const String _texCoordBaseName = 'vTexCoord';
  /// The base name of a color attribute.
  static const String _colorBaseName = 'vColor';

  /// The number of elements in a position attribute.
  static const int _positionElements = 3;
  /// The number of elements in a normal attribute.
  static const int _normalElements = 3;
  /// The number of elements in a tangent attribute.
  static const int _tangentElements = 3;
  /// The number of elements in a bitangent attribute.
  static const int _bitangentElements = 3;
  /// The number of elements in a color attribute.
  static const int _colorElements = 4;

  /// The buffers associated with this [VertexLayout].
  ///
  /// Used to describe the layout of vertices in memory.
  List<List<String>> _buffers = new List<List<String>>();
  /// Whether the buffer is aligned for SIMD.
  List<bool> _simdAligned = new List<bool>();

  //-------------------------------------------------------------------
  // Construction
  //-------------------------------------------------------------------

  /// Creates an instance of the [VertexLayout] class.
  VertexLayout();

  /// Creates an instance of the [VertexLayout] class where all elements are interleaved.
  VertexLayout.interleaveAll() {
    // Add the standard attributes
    List<String> interleaved = [
        _positionName,
        _normalName,
        _tangentName,
        _bitangentName
    ];

    // Add texture coordinates
    for (int i = 0; i < Mesh.maxNumberOfTextureCoords; ++i) {
      interleaved.add(_getTexCoordName(i));
    }

    // Add colors
    for (int i = 0; i < Mesh.maxNumberOfColorSets; ++i) {
      interleaved.add(_getColorName(i));
    }

    _buffers.add(interleaved);
    _simdAligned.add(false);
  }

  /// Creates an instance of the [VertexLayout] class where no elements are interleaved.
  VertexLayout.interleaveNone() {
    // Add the standard attributes
    _buffers.add([ _positionName ]);
    _buffers.add([ _normalName ]);
    _buffers.add([ _tangentName ]);
    _buffers.add([ _bitangentName ]);

    _simdAligned.add(false);
    _simdAligned.add(false);
    _simdAligned.add(false);
    _simdAligned.add(false);

    // Add texture coordinates
    for (int i = 0; i < Mesh.maxNumberOfTextureCoords; ++i) {
      _buffers.add([ _getTexCoordName(i) ]);
      _simdAligned.add(false);
    }

    // Add colors
    for (int i = 0; i < Mesh.maxNumberOfColorSets; ++i) {
      _buffers.add([ _getColorName(i) ]);
      _simdAligned.add(false);
    }
  }

  /// Creates an instance of the [VertexLayout] class for skinned meshes animated on the CPU.
  ///
  /// CPU animated meshes can benefit from SIMD. Using this vertex layout ensures that
  /// animated vertex elements are aligned to 128-bit boundaries.
  ///
  /// Bundles the animatable attributes, position, normal, tangent, bintangent, into one
  /// buffer that is SIMD aligned. The texture coordinates and colors are bundled into a
  /// separate buffer that is packed without padding.
  VertexLayout.cpuSkinning() {
    // Bundle the animatable attributes together
    List<String> animatable = [
        _positionName,
        _normalName,
        _tangentName,
        _bitangentName
    ];

    // Bundle the rest into a separate buffer
    List<String> constant = new List<String>();

    // Add texture coordinates
    for (int i = 0; i < Mesh.maxNumberOfTextureCoords; ++i) {
      constant.add(_getTexCoordName(i));
    }

    // Add colors
    for (int i = 0; i < Mesh.maxNumberOfColorSets; ++i) {
      constant.add(_getColorName(i));
    }

    // Set the buffers
    _buffers.add(animatable);
    _buffers.add(constant);

    // Set SIMD values
    _simdAligned.add(true);
    _simdAligned.add(false);
  }

  //-------------------------------------------------------------------
  // Properties
  //-------------------------------------------------------------------

  /// The number of buffers associated with this [VertexLayout].
  int get bufferCount => _buffers.length;

  /// The buffers associated with this [VertexLayout].
  ///
  /// Used to describe the layout of vertices in memory.
  List<List<String>> get buffers => _buffers;

  /// Whether the buffer is aligned for SIMD.
  List<bool> get simdAligned => _simdAligned;

  //-------------------------------------------------------------------
  // Private methods
  //-------------------------------------------------------------------

  /// Gets the name of a texture coordinate attribute at the given [index].
  static String _getTexCoordName(int index) {
    return '${_texCoordBaseName}${index}';
  }

  /// Gets the name of a color attribute at the given [index].
  static String _getColorName(int index) {
    return '${_colorBaseName}${index}';
  }
}

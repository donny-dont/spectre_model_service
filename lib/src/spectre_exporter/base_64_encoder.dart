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

/// Encodes a raw base64 string.
///
/// Base64 is an encoding scheme that represents binary data as an ASCII
/// string. This is used to transfer binary data within text. As an example an image
/// can be embedded within a HTML page by Base64 encoding it.
class Base64Encoder {
  /// The table used to encode the string.
  List<int> _encodingTable = [
    // A-Z [65-90]
    65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90,
    // a-z [97-122]
    97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122,
    // 0-9 [48-57]
    48, 49, 50, 51, 52, 53, 54, 55, 56, 57,
    // +
    43,
    // /
    47
  ];

  /// Creates an instance of the Base64Encoder class.
  Base64Encoder();

  /// Encodes the [buffer] into a base64 encoded [String].
  String encode(TypedData data) {
    // \TODO REMOVE There seems to be a bug in the view constructor when a length is not specified.
    ByteBuffer buffer = data.buffer;
    Uint8List dataBytes = new Uint8List.view(buffer, 0, buffer.lengthInBytes);

    // Create the encoded buffer
    Uint8List encoded = new Uint8List(_getEncodedBufferSize(dataBytes.length));

    // Declare temporary values
    int octetA;
    int octetB;
    int octetC;

    int index0;
    int index1;
    int index2;
    int index3;

    // Get the number of values to iterate over
    int dataLength = dataBytes.length;
    int dataLengthMinus2 = dataLength - 2;

    int i = 0;
    int j = 0;

    while (i < dataLengthMinus2) {
      octetA = dataBytes[i++];
      octetB = dataBytes[i++];
      octetC = dataBytes[i++];

      index0 = (octetA >> 2) & 0x3f;
      index1 = ((octetA & 0x3) << 4) | ((octetB >> 4) & 0xf);
      index2 = ((octetB & 0xf) << 2) | ((octetC >> 6) & 0x3);
      index3 = octetC & 0x3f;

      encoded[j++] = _encodingTable[index0];
      encoded[j++] = _encodingTable[index1];
      encoded[j++] = _encodingTable[index2];
      encoded[j++] = _encodingTable[index3];
    }

    // See how much padding is required
    if (i + 2 == dataLength) {
      octetA = dataBytes[i++];
      octetB = dataBytes[i];

      // c is zero so simplify the equations
      index0 = (octetA >> 2) & 0x3f;
      index1 = ((octetA & 0x3) << 4) | ((octetB >> 4) & 0xf);
      index2 = (octetB & 0xf) << 2;

      encoded[j++] = _encodingTable[index0];
      encoded[j++] = _encodingTable[index1];
      encoded[j++] = _encodingTable[index2];
      encoded[j  ] = 61;
    } else if (i + 1 == dataLength) {
      octetA = dataBytes[i];

      // b and c is zero so simplify the equations
      index0 = (octetA >> 2) & 0x3f;
      index1 = (octetA & 0x3) << 4;

      encoded[j++] = _encodingTable[index0];
      encoded[j++] = _encodingTable[index1];
      encoded[j++] = 61;
      encoded[j  ] = 61;
    }

    return new String.fromCharCodes(encoded);
  }

  /// Computes the size needed to store the encoded data.
  ///
  /// Base64 encodes 4 bytes for each 3 bytes in the original data. Additionally
  /// '=' is used as a padding character when the total number of bytes is not
  /// a multiple of 3.
  static int _getEncodedBufferSize(int rawSize) {
    return 4 * ((rawSize + 2) ~/ 3);
  }
}

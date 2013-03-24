library test_model;

import 'dart:io';
import 'dart:json' as Json;
import 'dart:typeddata';
import 'package:spectre_model_service/assimp.dart';
import 'package:spectre_model_service/spectre_exporter.dart';

part 'cube.dart';
part 'hellknight.dart';

Base64Encoder _encoder = new Base64Encoder();

void encodeTypedData(var json) {
  if (json is List) {
    List list = json as List;

    list.forEach((value) {
      encodeTypedData(value);
    });
  } else if (json is Map) {
    Map map = json as Map;

    map.keys.forEach((key) {
      dynamic value = map[key];

      // Check for typed data to convert to base64
      if (value is TypedData) {
        map[key] = _encoder.encode(value);
      } else {
        encodeTypedData(value);
      }
    });
  }
}

void main() {
  Map json = Json.parse(hellknightMesh);

  Scene scene = new Scene.fromJson(json);

  Map output = MeshExporter.export(scene.meshes, new VertexLayout.cpuSkinning());

  File file0 = new File("output.json");
  file0.writeAsStringSync(Json.stringify(output));

  encodeTypedData(output);

  File file1 = new File("output_encoded.json");
  file1.writeAsStringSync(Json.stringify(output));
}

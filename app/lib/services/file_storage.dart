import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

Future<String> _fetchExternalDocumentPath() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
  final directory = Directory("/storage/emulated/0/Download/Astra-Recorder/");

  final exPath = directory.path;
  await Directory(exPath).create(recursive: true);
  return exPath;
}

Future<void> storeFileInExternalDocuments(File file, String recordingId) async {
  final filename = (file.uri.pathSegments.last);
  final wholeFileName = "$recordingId-$filename";
  String filePath = "${await _fetchExternalDocumentPath()}$wholeFileName";

  try {
    file.copy(filePath);
    return;
  } catch (e) {
    print('Error saving image: $e');
  }
}

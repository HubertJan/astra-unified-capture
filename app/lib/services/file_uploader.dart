import 'dart:io';
import 'package:http/http.dart' as http;

const _fileUploadUrl = "192.168.2.1:8000";

Future<void> uploadFileToService(File file, String recordingId) async {
  HttpClient httpClient = HttpClient();
  final filename = (file.uri.pathSegments.last);
  final uri = Uri.http(_fileUploadUrl, "$recordingId-$filename");
  try {
    var request = http.Request('PUT', uri)
      ..headers['content-type'] = 'application/octet-stream'
      ..bodyBytes = await file.readAsBytes();

    var response = await http.Client().send(request);
    print('Response status: ${response.statusCode}');
  } finally {
    httpClient.close();
  }
}
